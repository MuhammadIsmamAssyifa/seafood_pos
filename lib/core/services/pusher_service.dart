import 'dart:async';
import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../config/env_config.dart';

class PusherKdsEvent {
  final String eventName;
  final String channelName;
  final dynamic data;
  final DateTime receivedAt;

  PusherKdsEvent({
    required this.eventName,
    required this.channelName,
    required this.data,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  int? get orderId {
    if (data is Map) {
      if (data['order_id'] != null) {
        return int.tryParse(data['order_id'].toString());
      }
      if (data['order'] is Map && data['order']['id'] != null) {
        return int.tryParse(data['order']['id'].toString());
      }
    }
    return null;
  }

  int? get batchId {
    if (data is Map) {
      if (data['id'] != null && (eventName.contains('batch'))) {
        return int.tryParse(data['id'].toString());
      }
      if (data['order_batch_id'] != null) {
        return int.tryParse(data['order_batch_id'].toString());
      }
    }
    return null;
  }

  String? get status {
    if (data is Map && data['status'] != null) {
      return data['status'].toString();
    }
    return null;
  }

  @override
  String toString() => 'PusherKdsEvent($eventName, orderId: $orderId, status: $status)';
}

class PusherService extends GetxService {
  final Logger _logger = Logger();
  PusherChannelsClient? _client;
  Channel? _channel;
  final List<StreamSubscription> _subscriptions = [];

  final RxBool isConnected = false.obs;
  final StreamController<PusherKdsEvent> _eventController = StreamController<PusherKdsEvent>.broadcast();

  Stream<PusherKdsEvent> get onKdsEvent => _eventController.stream;

  @override
  void onInit() {
    super.onInit();
    initPusher();
  }

  Future<void> initPusher() async {
    try {
      final client = PusherChannelsClient.websocket(
        options: PusherChannelsOptions.fromCluster(
          scheme: 'wss',
          cluster: EnvConfig.pusherCluster,
          key: EnvConfig.pusherAppKey,
          port: 443,
        ),
        connectionErrorHandler: (exception, trace, refresh) {
          _logger.w('[PUSHER] Connection error: $exception');
          isConnected.value = false;
        },
      );

      _client = client;

      client.lifecycleStream.listen((lifecycle) {
        if (lifecycle == PusherChannelsClientLifeCycleState.establishedConnection) {
          isConnected.value = true;
          _logger.i('[PUSHER] Connected successfully');
        } else if (lifecycle == PusherChannelsClientLifeCycleState.disconnected ||
            lifecycle == PusherChannelsClientLifeCycleState.connectionError) {
          isConnected.value = false;
        }
      });

      await client.connect();

      final channelName = EnvConfig.pusherKdsChannel;
      final channel = client.publicChannel(channelName);
      _channel = channel;
      channel.subscribeIfNotUnsubscribed();

      _listenToEvent(channel, 'kds.batch.submitted');
      _listenToEvent(channel, 'kds.batch.updated');
      _listenToEvent(channel, 'kds.item.updated');
      _listenToEvent(channel, 'kds.item.changed');
    } catch (e) {
      _logger.e('[PUSHER] Failed to initialize: $e');
      isConnected.value = false;
    }
  }

  void _listenToEvent(Channel channel, String eventName) {
    final sub = channel.bind(eventName).listen((event) {
      dynamic parsedData = event.data;
      if (parsedData is String) {
        try {
          parsedData = jsonDecode(parsedData);
        } catch (_) {}
      }

      final kdsEvent = PusherKdsEvent(
        eventName: eventName,
        channelName: channel.name,
        data: parsedData,
      );

      _logger.i('[PUSHER EVENT] Received: $kdsEvent');
      _eventController.add(kdsEvent);
    });
    _subscriptions.add(sub);
  }

  /// Manually inject event for testing or simulation
  void emitEventForTest(PusherKdsEvent event) {
    _eventController.add(event);
  }

  @override
  void onClose() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
    _channel?.unsubscribe();
    _client?.disconnect();
    _client?.dispose();
    _eventController.close();
    super.onClose();
  }
}
