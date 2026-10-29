import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seafood_pos/core/api/api_response.dart';
import 'package:seafood_pos/core/api/dio_client.dart';
import 'package:seafood_pos/features/history/controllers/history_controller.dart';
import 'package:seafood_pos/features/history/models/history_filter.dart';
import 'package:seafood_pos/features/history/models/history_order_model.dart';
import 'package:seafood_pos/features/history/models/history_summary.dart';
import 'package:seafood_pos/features/history/repositories/history_repository.dart';
import 'package:seafood_pos/features/history/widgets/date_filter.dart';
import 'package:seafood_pos/features/history/widgets/history_status_badge.dart';
import 'package:seafood_pos/features/history/widgets/order_history_card.dart';
import 'package:seafood_pos/features/history/widgets/payment_history_card.dart';
import 'package:seafood_pos/features/order_adjustment/models/adjustment_model.dart';
import 'package:seafood_pos/features/order_adjustment/models/adjustment_status.dart';
import 'package:seafood_pos/features/order_adjustment/models/adjustment_type.dart';
import 'package:seafood_pos/features/payment/models/payment_model.dart';

class FakeHistoryRepository implements HistoryRepository {
  List<HistoryOrderModel> fakeOrders = [];
  List<PaymentModel> fakePayments = [];
  List<AdjustmentModel> fakeAdjustments = [];

  @override
  DioClient get dioClient => throw UnimplementedError();

  @override
  Future<ApiResponse<List<HistoryOrderModel>>> getHistory(
    HistoryFilter filter, {
    int page = 1,
    int perPage = 20,
  }) async {
    var result = List<HistoryOrderModel>.from(fakeOrders);
    if (filter.status != null && filter.status!.isNotEmpty) {
      result = result.where((o) => o.status.toLowerCase() == filter.status!.toLowerCase()).toList();
    }
    if (filter.searchQuery.isNotEmpty) {
      result = result
          .where((o) =>
              o.orderNumber.toLowerCase().contains(filter.searchQuery.toLowerCase()) ||
              o.customerName.toLowerCase().contains(filter.searchQuery.toLowerCase()))
          .toList();
    }
    return ApiResponse<List<HistoryOrderModel>>.success(data: result);
  }

  @override
  Future<ApiResponse<HistoryOrderModel>> getOrder(int orderId) async {
    final order = fakeOrders.firstWhere((o) => o.id == orderId);
    return ApiResponse<HistoryOrderModel>.success(data: order);
  }

  @override
  Future<ApiResponse<List<PaymentModel>>> getPayments(int orderId) async {
    return ApiResponse<List<PaymentModel>>.success(data: fakePayments);
  }

  @override
  Future<ApiResponse<List<AdjustmentModel>>> getAdjustments(int orderId) async {
    return ApiResponse<List<AdjustmentModel>>.success(data: fakeAdjustments);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sprint 09 - Models & Serialization Tests', () {
    test('Parses HistoryOrderModel from backend JSON correctly', () {
      final json = {
        'id': 101,
        'order_number': 'ORD-20261029-001',
        'customer_name': 'Budi Santoso',
        'guest_count': 4,
        'status': 'completed',
        'subtotal': 650000.0,
        'discount': 50000.0,
        'grand_total': 600000.0,
        'table': {'id': 5, 'number': '05'},
        'items': [
          {
            'id': 1,
            'menu_variant_id': 10,
            'menu_name': 'Ikan Etong Bakar',
            'variant_name': 'Bakar Madu',
            'quantity': 1.0,
            'unit': 'kg',
            'price': 50000.0,
            'subtotal': 50000.0,
            'status': 'served',
          }
        ],
        'payments': [
          {
            'id': 1,
            'order_id': 101,
            'method': 'cash',
            'amount': 600000.0,
            'status': 'completed',
          }
        ],
        'created_at': '2026-10-29T12:00:00Z',
      };

      final model = HistoryOrderModel.fromJson(json);

      expect(model.id, 101);
      expect(model.orderNumber, 'ORD-20261029-001');
      expect(model.customerName, 'Budi Santoso');
      expect(model.tableNumber, '05');
      expect(model.guestCount, 4);
      expect(model.isCompleted, true);
      expect(model.subtotal, 650000.0);
      expect(model.discount, 50000.0);
      expect(model.grandTotal, 600000.0);
      expect(model.items.length, 1);
      expect(model.payments.length, 1);
    });

    test('HistoryFilter builds valid query parameters', () {
      final filter = HistoryFilter(
        status: 'completed',
        searchQuery: 'Budi',
        dateRange: HistoryDateRange.today,
      );

      final params = filter.toQueryParams(page: 1, perPage: 15);

      expect(params['status'], 'completed');
      expect(params['search'], 'Budi');
      expect(params['date'], isNotEmpty);
      expect(params['page'], 1);
      expect(params['per_page'], 15);
      expect(filter.hasActiveFilter, true);
    });

    test('HistorySummary computes stats correctly', () {
      final orders = [
        const HistoryOrderModel(
          id: 1,
          orderNumber: 'ORD-1',
          customerName: 'A',
          status: 'completed',
          subtotal: 100000,
          grandTotal: 100000,
        ),
        const HistoryOrderModel(
          id: 2,
          orderNumber: 'ORD-2',
          customerName: 'B',
          status: 'cancelled',
          subtotal: 50000,
          grandTotal: 50000,
        ),
        const HistoryOrderModel(
          id: 3,
          orderNumber: 'ORD-3',
          customerName: 'C',
          status: 'ready',
          subtotal: 75000,
          grandTotal: 75000,
        ),
      ];

      final summary = HistorySummary.fromOrders(orders);

      expect(summary.totalOrders, 3);
      expect(summary.completedCount, 1);
      expect(summary.cancelledCount, 1);
      expect(summary.totalRevenue, 175000.0);
    });
  });

  group('Sprint 09 - HistoryController Tests', () {
    late FakeHistoryRepository fakeRepo;
    late HistoryController controller;

    setUp(() {
      Get.reset();
      Get.testMode = true;
      fakeRepo = FakeHistoryRepository();
      fakeRepo.fakeOrders = [
        const HistoryOrderModel(
          id: 1,
          orderNumber: 'ORD-001',
          customerName: 'Andi',
          tableNumber: '01',
          status: 'completed',
          subtotal: 200000,
          grandTotal: 200000,
        ),
        const HistoryOrderModel(
          id: 2,
          orderNumber: 'ORD-002',
          customerName: 'Budi',
          tableNumber: '02',
          status: 'ready',
          subtotal: 150000,
          grandTotal: 150000,
        ),
      ];
      fakeRepo.fakePayments = [
        PaymentModel(
          id: 1,
          orderId: 1,
          method: 'cash',
          amount: 200000,
          status: 'completed',
        ),
      ];
      fakeRepo.fakeAdjustments = [
        const AdjustmentModel(
          id: 1,
          orderItemId: 10,
          type: AdjustmentType.quantityChange,
          status: AdjustmentStatus.approved,
          reason: 'Ikan 1kg',
          oldQuantity: 0.7,
          oldPrice: 50000,
          newQuantity: 1.0,
          newPrice: 50000,
        ),
      ];

      controller = HistoryController(repository: fakeRepo);
    });

    test('Loads history on init and populates orders', () async {
      await controller.loadHistory();

      expect(controller.orders.length, 2);
      expect(controller.summary.totalOrders, 2);
    });

    test('Filter by status works', () async {
      await controller.loadHistory();
      controller.setStatusFilter('completed');
      await controller.loadHistory();

      expect(controller.orders.length, 1);
      expect(controller.orders.first.customerName, 'Andi');
    });

    test('Load detail fetches order, payments and adjustments', () async {
      await controller.loadDetail(1);

      expect(controller.selectedOrder.value, isNotNull);
      expect(controller.selectedOrder.value!.id, 1);
      expect(controller.payments.length, 1);
      expect(controller.adjustments.length, 1);
    });
  });

  group('Sprint 09 - UI Widgets Tests', () {
    testWidgets('HistoryStatusBadge renders labels correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HistoryStatusBadge(status: 'completed'),
                HistoryStatusBadge(status: 'ready'),
                HistoryStatusBadge(status: 'preparing'),
                HistoryStatusBadge(status: 'cancelled'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Siap Saji / Bayar'), findsOneWidget);
      expect(find.text('Dimasak'), findsOneWidget);
      expect(find.text('Dibatalkan'), findsOneWidget);
    });

    testWidgets('OrderHistoryCard renders order data and triggers tap', (tester) async {
      bool tapped = false;
      const order = HistoryOrderModel(
        id: 1,
        orderNumber: 'ORD-20261029-001',
        customerName: 'Budi Santoso',
        tableNumber: '05',
        guestCount: 3,
        status: 'completed',
        subtotal: 650000,
        grandTotal: 650000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrderHistoryCard(
              order: order,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('ORD-20261029-001'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Meja 05'), findsOneWidget);
      expect(find.text('3 Tamu'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);

      await tester.tap(find.byType(OrderHistoryCard));
      expect(tapped, true);
    });

    testWidgets('PaymentHistoryCard renders payments and split payment badge', (tester) async {
      final payments = [
        PaymentModel(id: 1, orderId: 10, method: 'cash', amount: 300000, status: 'completed'),
        PaymentModel(id: 2, orderId: 10, method: 'transfer', amount: 200000, status: 'completed'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentHistoryCard(payments: payments),
          ),
        ),
      );

      expect(find.text('Riwayat Pembayaran (2)'), findsOneWidget);
      expect(find.text('Split Payment'), findsOneWidget);
      expect(find.text('Pembayaran #1 • Cash (Tunai)'), findsOneWidget);
      expect(find.text('Pembayaran #2 • Transfer Bank'), findsOneWidget);
    });

    testWidgets('DateFilterChips renders all quick ranges', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateFilterChips(
              selectedRange: HistoryDateRange.today,
              onSelected: (_) {},
              onPickCustomDate: () {},
            ),
          ),
        ),
      );

      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Hari Ini'), findsOneWidget);
      expect(find.text('Kemarin'), findsOneWidget);
      expect(find.text('7 Hari Terakhir'), findsOneWidget);
    });
  });
}
