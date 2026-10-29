import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seafood_pos/app/theme/app_theme.dart';
import 'package:seafood_pos/core/api/api_response.dart';
import 'package:seafood_pos/core/api/dio_client.dart';
import 'package:seafood_pos/core/services/pusher_service.dart';
import 'package:seafood_pos/core/storage/secure_storage.dart';
import 'package:seafood_pos/features/order/controllers/order_controller.dart';
import 'package:seafood_pos/features/order/models/order_batch_model.dart';
import 'package:seafood_pos/features/order/models/order_item_model.dart';
import 'package:seafood_pos/features/order/models/menu_model.dart';
import 'package:seafood_pos/features/order/models/order_model.dart';
import 'package:seafood_pos/features/order/repositories/order_repository.dart';
import 'package:seafood_pos/features/order/widgets/batch_card.dart';
import 'package:seafood_pos/features/order/widgets/kitchen_progress.dart';
import 'package:seafood_pos/features/order/widgets/order_status_badge.dart';
import 'package:seafood_pos/features/order/widgets/submit_button.dart';
import 'package:seafood_pos/features/order/widgets/submit_dialog.dart';

class FakeSprint06Repository extends OrderRepository {
  bool shouldSucceed = true;
  OrderModel? mockOrder;
  int submitBatchCallCount = 0;

  FakeSprint06Repository({required super.dioClient});

  @override
  Future<ApiResponse<List<MenuModel>>> getMenus() async {
    return ApiResponse<List<MenuModel>>.success(data: []);
  }

  @override
  Future<ApiResponse<OrderModel>> getOrder(int orderId) async {
    if (!shouldSucceed || mockOrder == null) {
      return ApiResponse<OrderModel>.failure(message: 'Order not found');
    }
    return ApiResponse<OrderModel>.success(data: mockOrder!);
  }

  @override
  Future<ApiResponse<OrderBatchModel>> submitBatch(int batchId) async {
    submitBatchCallCount++;
    if (!shouldSucceed) {
      return ApiResponse<OrderBatchModel>.failure(message: 'Submit batch failed');
    }

    final currentBatches = List<OrderBatchModel>.from(mockOrder?.batches ?? []);
    final index = currentBatches.indexWhere((b) => b.id == batchId);

    late OrderBatchModel updatedBatch;
    if (index != -1) {
      updatedBatch = currentBatches[index].copyWith(
        status: 'sent',
        sentToKitchenAt: DateTime.now(),
      );
      currentBatches[index] = updatedBatch;
    } else {
      updatedBatch = OrderBatchModel(
        id: batchId,
        orderId: mockOrder?.id ?? 1,
        batchNumber: 1,
        status: 'sent',
        sentToKitchenAt: DateTime.now(),
      );
      currentBatches.add(updatedBatch);
    }

    mockOrder = mockOrder?.copyWith(
      batches: currentBatches,
      status: 'submitted',
    );

    return ApiResponse<OrderBatchModel>.success(
      data: updatedBatch,
      message: 'Pesanan berhasil dikirim ke dapur.',
    );
  }
}

class FakePusherService extends PusherService {
  final StreamController<PusherKdsEvent> _testEventController = StreamController<PusherKdsEvent>.broadcast();

  @override
  Stream<PusherKdsEvent> get onKdsEvent => _testEventController.stream;

  @override
  void emitEventForTest(PusherKdsEvent event) {
    _testEventController.add(event);
  }

  @override
  void onClose() {
    _testEventController.close();
    super.onClose();
  }
}

void main() {
  late SecureStorageService storageService;
  late DioClient dioClient;
  late FakeSprint06Repository orderRepository;
  late FakePusherService pusherService;
  late OrderController orderController;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    storageService = SecureStorageService(isTest: true);
    dioClient = DioClient(storageService: storageService);
    orderRepository = FakeSprint06Repository(dioClient: dioClient);
    pusherService = FakePusherService();

    final batch1 = OrderBatchModel(
      id: 501,
      orderId: 100,
      batchNumber: 1,
      status: 'waiting',
      items: const [
        OrderItemModel(
          id: 1,
          orderBatchId: 501,
          menuVariantId: 10,
          menuName: 'Ikan Gurame Bakar',
          quantity: 2,
          price: 50000.0,
          subtotal: 100000.0,
        ),
      ],
    );

    orderRepository.mockOrder = OrderModel(
      id: 100,
      orderNumber: '#ORD-100',
      tableNumber: 'A1',
      customerName: 'Budi',
      guestCount: 2,
      status: 'draft',
      subtotal: 100000.0,
      grandTotal: 100000.0,
      items: batch1.items,
      batches: [batch1],
    );
  });

  tearDown(() {
    pusherService.onClose();
  });

  group('Sprint 06 - Models & Serialization Tests', () {
    test('OrderBatchModel parses json and computes correct getters', () {
      final json = {
        'id': 10,
        'order_id': 100,
        'batch_number': 2,
        'status': 'cooking',
        'sent_to_kitchen_at': '2026-10-29T12:00:00Z',
        'items': [
          {
            'id': 1,
            'menu_variant_id': 5,
            'menu_name': 'Udang Bakar',
            'quantity': 3,
            'price': 30000,
            'subtotal': 90000,
          }
        ]
      };

      final batch = OrderBatchModel.fromJson(json);
      expect(batch.id, 10);
      expect(batch.batchNumber, 2);
      expect(batch.isCooking, isTrue);
      expect(batch.isWaiting, isFalse);
      expect(batch.itemCount, 3);
      expect(batch.displayName, 'Batch 2');
      expect(batch.statusLabel, 'Sedang Dimasak');
    });

    test('OrderModel parses batches and computes waiting batch correctly', () {
      final order = orderRepository.mockOrder!;
      expect(order.batches.length, 1);
      expect(order.hasWaitingBatch, isTrue);
      expect(order.waitingBatch?.id, 501);
      expect(order.statusLabel, 'Draft');
    });
  });

  group('Sprint 06 - OrderController Batch & Realtime Tests', () {
    test('Submit batch calls repository, updates order status to submitted and refreshes order', () async {
      orderController = OrderController(
        orderRepository: orderRepository,
        pusherService: pusherService,
      );
      orderController.orderId.value = 100;
      await orderController.initData();

      expect(orderController.order.value?.status, 'draft');
      expect(orderController.hasWaitingBatch, isTrue);

      await orderController.submitBatch(501);

      expect(orderRepository.submitBatchCallCount, 1);
      expect(orderController.order.value?.status, 'submitted');
      expect(orderController.batches.first.isSent, isTrue);
      expect(orderController.hasWaitingBatch, isFalse);
    });

    test('Realtime Pusher event automatically refreshes order without polling', () async {
      orderController = OrderController(
        orderRepository: orderRepository,
        pusherService: pusherService,
      );
      orderController.orderId.value = 100;
      orderController.onInit();
      await orderController.initData();

      // Simulate Kitchen updating batch status to 'cooking' on backend
      final updatedBatch = orderRepository.mockOrder!.batches.first.copyWith(
        status: 'cooking',
      );
      orderRepository.mockOrder = orderRepository.mockOrder!.copyWith(
        status: 'preparing',
        batches: [updatedBatch],
      );

      // Emit Pusher Event: kds.batch.updated
      pusherService.emitEventForTest(PusherKdsEvent(
        eventName: 'kds.batch.updated',
        channelName: 'pos-seafood-kds-development',
        data: {
          'id': 501,
          'order_id': 100,
          'status': 'cooking',
        },
      ));

      // Allow microtasks/event loop to process stream event
      await Future.delayed(const Duration(milliseconds: 100));

      expect(orderController.order.value?.status, 'preparing');
      expect(orderController.batches.first.isCooking, isTrue);
    });
  });

  group('Sprint 06 - UI Widgets Tests', () {
    testWidgets('OrderStatusBadge renders correct labels and icons for all statuses', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                OrderStatusBadge(status: 'draft'),
                OrderStatusBadge(status: 'submitted'),
                OrderStatusBadge(status: 'preparing'),
                OrderStatusBadge(status: 'ready'),
                OrderStatusBadge(status: 'completed'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('DRAFT'), findsOneWidget);
      expect(find.text('TERKIRIM'), findsOneWidget);
      expect(find.text('DIMASAK'), findsOneWidget);
      expect(find.text('SIAP SAJI'), findsOneWidget);
      expect(find.text('SELESAI'), findsOneWidget);
    });

    testWidgets('KitchenProgressWidget highlights current step correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KitchenProgressWidget(status: 'cooking'),
          ),
        ),
      );

      expect(find.text('Menunggu'), findsOneWidget);
      expect(find.text('Dimasak'), findsOneWidget);
      expect(find.text('Siap'), findsOneWidget);
      expect(find.text('Disajikan'), findsOneWidget);
    });

    testWidgets('BatchCard renders batch information and submit button for waiting batch', (tester) async {
      bool submitted = false;
      final waitingBatch = orderRepository.mockOrder!.batches.first;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: BatchCard(
              batch: waitingBatch,
              onSubmit: () => submitted = true,
            ),
          ),
        ),
      );

      expect(find.text('Batch 1'), findsWidgets);
      expect(find.text('Ikan Gurame Bakar'), findsOneWidget);
      expect(find.text('Kirim Batch 1 ke Dapur'), findsOneWidget);

      await tester.tap(find.text('Kirim Batch 1 ke Dapur'));
      expect(submitted, isTrue);
    });

    testWidgets('SubmitBatchButton triggers onSubmit callback', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SubmitBatchButton(
              batchNumber: 2,
              itemCount: 3,
              isSubmitting: false,
              onSubmit: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Kirim Batch 2 ke Dapur (3 Item)'), findsOneWidget);
      await tester.tap(find.byType(SubmitBatchButton));
      expect(pressed, isTrue);
    });

    testWidgets('SubmitOrderDialog renders warning text and confirms submission', (tester) async {
      bool confirmed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  SubmitOrderDialog.show(
                    context: context,
                    batchNumber: 1,
                    itemCount: 2,
                    onConfirm: () => confirmed = true,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Kirim Batch 1 ke Dapur?'), findsOneWidget);
      expect(find.text('2 Item siap dimasak'), findsOneWidget);

      await tester.tap(find.text('Kirim ke Dapur'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });
  });
}
