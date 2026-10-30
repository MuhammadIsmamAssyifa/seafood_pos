import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ReleaseConnectivityService extends GetxService {
  final Connectivity _connectivity;
  final RxBool isConnected = true.obs;
  final RxBool wasOffline = false.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ReleaseConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  void onInit() {
    super.onInit();
    checkConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return isConnected.value;
    } catch (_) {
      isConnected.value = true;
      return true;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool online = results.any((result) => result != ConnectivityResult.none);
    if (!online) {
      wasOffline.value = true;
    }
    isConnected.value = online;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

