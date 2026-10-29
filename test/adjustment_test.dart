import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seafood_pos/core/api/api_exception.dart';
import 'package:seafood_pos/core/api/api_response.dart';
import 'package:seafood_pos/core/api/dio_client.dart';
import 'package:seafood_pos/features/order/models/order_item_model.dart';
import 'package:seafood_pos/features/order/models/order_model.dart';
import 'package:seafood_pos/features/order_adjustment/controllers/order_adjustment_controller.dart';
import 'package:seafood_pos/features/order_adjustment/models/adjustment_model.dart';
import 'package:seafood_pos/features/order_adjustment/models/adjustment_status.dart';
import 'package:seafood_pos/features/order_adjustment/models/adjustment_type.dart';
import 'package:seafood_pos/features/order_adjustment/repositories/order_adjustment_repository.dart';
import 'package:seafood_pos/features/order_adjustment/widgets/adjustment_card.dart';
import 'package:seafood_pos/features/order_adjustment/widgets/adjustment_status_badge.dart';
import 'package:seafood_pos/features/order_adjustment/widgets/quantity_compare.dart';

class FakeAdjustmentRepository implements OrderAdjustmentRepository {
  List<AdjustmentModel> fakeList = [];
  bool shouldFail = false;

  @override
  DioClient get dioClient => throw UnimplementedError();

  @override
  Future<ApiResponse<List<AdjustmentModel>>> getAdjustment({
    int? orderId,
    String? status,
  }) async {
    if (shouldFail) {
      throw ApiException(message: 'Network Error');
    }
    return ApiResponse<List<AdjustmentModel>>.success(data: fakeList);
  }

  @override
  Future<ApiResponse<AdjustmentModel>> approve(int changeId) async {
    if (shouldFail) {
      throw ApiException(message: 'Item sudah diproses dan tidak dapat diubah');
    }
    final existing = fakeList.firstWhere((a) => a.id == changeId);
    final updated = AdjustmentModel(
      id: existing.id,
      orderItemId: existing.orderItemId,
      type: existing.type,
      status: AdjustmentStatus.approved,
      reason: existing.reason,
      oldQuantity: existing.oldQuantity,
      oldPrice: existing.oldPrice,
      newQuantity: existing.newQuantity,
      newPrice: existing.newPrice,
      orderItem: existing.orderItem,
      createdAt: existing.createdAt,
    );
    return ApiResponse<AdjustmentModel>.success(
      data: updated,
      message: 'Perubahan pesanan disetujui',
    );
  }

  @override
  Future<ApiResponse<AdjustmentModel>> reject(int changeId) async {
    if (shouldFail) {
      throw ApiException(message: 'Gagal menolak perubahan');
    }
    final existing = fakeList.firstWhere((a) => a.id == changeId);
    final updated = AdjustmentModel(
      id: existing.id,
      orderItemId: existing.orderItemId,
      type: existing.type,
      status: AdjustmentStatus.rejected,
      reason: existing.reason,
      oldQuantity: existing.oldQuantity,
      oldPrice: existing.oldPrice,
      newQuantity: existing.newQuantity,
      newPrice: existing.newPrice,
      orderItem: existing.orderItem,
      createdAt: existing.createdAt,
    );
    return ApiResponse<AdjustmentModel>.success(
      data: updated,
      message: 'Perubahan pesanan ditolak',
    );
  }

  @override
  Future<ApiResponse<OrderItemModel>> replace({
    required int orderItemId,
    required int menuVariantId,
    required double quantity,
    required String reason,
  }) async {
    return ApiResponse<OrderItemModel>.success(
      data: OrderItemModel(
        id: 99,
        menuVariantId: menuVariantId,
        menuName: 'Cumi Crispy',
        variantName: 'Goreng Tepung',
        quantity: quantity,
        price: 45000,
        subtotal: quantity * 45000,
      ),
      message: 'Item berhasil diganti',
    );
  }

  @override
  Future<ApiResponse<AdjustmentModel>> createAdjustment({
    required int orderItemId,
    required String type,
    double? quantity,
    double? price,
    required String reason,
  }) async {
    final newAdj = AdjustmentModel(
      id: 88,
      orderItemId: orderItemId,
      type: AdjustmentType.fromString(type),
      status: AdjustmentStatus.pendingCustomer,
      reason: reason,
      oldQuantity: 1.0,
      oldPrice: 50000,
    );
    return ApiResponse<AdjustmentModel>.success(data: newAdj);
  }

  @override
  Future<ApiResponse<OrderModel>> refreshOrder(int orderId) async {
    return ApiResponse<OrderModel>.success(
      data: OrderModel(id: orderId, orderNumber: 'ORD-101', grandTotal: 75000),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sprint 08 - Models & Serialization Tests', () {
    test('Parses AdjustmentModel correctly from JSON with decimal quantities', () {
      final json = {
        'id': 10,
        'order_item_id': 5,
        'type': 'quantity_change',
        'status': 'pending_customer',
        'reason': 'Ukuran ikan etong 0.7kg habis, hanya ada 1.0kg',
        'old_quantity': 0.7,
        'old_price': 50000.0,
        'new_quantity': 1.0,
        'new_price': 50000.0,
        'order_item': {
          'id': 5,
          'menu_name': 'Ikan Etong Bakar',
          'variant_name': 'Bakar Madu',
          'quantity': 0.7,
          'unit': 'kg',
          'price': 50000.0,
          'subtotal': 35000.0,
          'status': 'waiting',
        },
      };

      final model = AdjustmentModel.fromJson(json);

      expect(model.id, 10);
      expect(model.orderItemId, 5);
      expect(model.type, AdjustmentType.quantityChange);
      expect(model.status, AdjustmentStatus.pendingCustomer);
      expect(model.isPending, true);
      expect(model.oldQuantity, 0.7);
      expect(model.effectiveNewQuantity, 1.0);
      expect(model.oldSubtotal, 35000.0);
      expect(model.newSubtotal, 50000.0);
      expect(model.unit, 'kg');
      expect(model.itemName, 'Ikan Etong Bakar (Bakar Madu)');
    });

    test('AdjustmentType and AdjustmentStatus handle fallback gracefully', () {
      expect(AdjustmentType.fromString('invalid'), AdjustmentType.quantityChange);
      expect(AdjustmentStatus.fromString('invalid'), AdjustmentStatus.pendingCustomer);
      expect(AdjustmentType.fromString('cancel'), AdjustmentType.cancel);
      expect(AdjustmentType.fromString('replace'), AdjustmentType.replace);
    });
  });

  group('Sprint 08 - OrderAdjustmentController Tests', () {
    late FakeAdjustmentRepository fakeRepo;
    late OrderAdjustmentController controller;

    setUp(() {
      Get.reset();
      Get.testMode = true;
      fakeRepo = FakeAdjustmentRepository();
      fakeRepo.fakeList = [
        AdjustmentModel(
          id: 1,
          orderItemId: 101,
          type: AdjustmentType.quantityChange,
          status: AdjustmentStatus.pendingCustomer,
          reason: 'Ikan 0.7kg tidak tersedia',
          oldQuantity: 0.7,
          oldPrice: 50000,
          newQuantity: 1.0,
          newPrice: 50000,
        ),
        AdjustmentModel(
          id: 2,
          orderItemId: 102,
          type: AdjustmentType.cancel,
          status: AdjustmentStatus.approved,
          reason: 'Customer batal',
          oldQuantity: 1.0,
          oldPrice: 20000,
        ),
      ];
      controller = OrderAdjustmentController(repository: fakeRepo);
    });

    test('Loads adjustments and filters correctly', () async {
      await controller.loadAdjustment();

      expect(controller.adjustments.length, 2);
      expect(controller.pendingCount, 1);

      controller.setFilterStatus(AdjustmentStatus.pendingCustomer);
      expect(controller.filteredAdjustments.length, 1);
      expect(controller.filteredAdjustments.first.id, 1);

      controller.setFilterStatus(AdjustmentStatus.approved);
      expect(controller.filteredAdjustments.length, 1);
      expect(controller.filteredAdjustments.first.id, 2);
    });

    test('Approve adjustment updates status and refreshes', () async {
      await controller.loadAdjustment();
      final success = await controller.approveAdjustment(1);

      expect(success, true);
    });

    test('Reject adjustment updates status', () async {
      await controller.loadAdjustment();
      final success = await controller.rejectAdjustment(1);

      expect(success, true);
    });

    test('Replace item succeeds', () async {
      final success = await controller.replaceItem(
        orderItemId: 101,
        menuVariantId: 4,
        quantity: 1.0,
        reason: 'Ganti menu cumi',
      );

      expect(success, true);
    });
  });

  group('Sprint 08 - UI Widgets Tests', () {
    testWidgets('AdjustmentStatusBadge displays correct labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AdjustmentStatusBadge(status: AdjustmentStatus.pendingCustomer),
                AdjustmentStatusBadge(status: AdjustmentStatus.approved),
                AdjustmentStatusBadge(status: AdjustmentStatus.rejected),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Pending Customer'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
    });

    testWidgets('QuantityCompareWidget renders decimal quantity and prices', (tester) async {
      const adjustment = AdjustmentModel(
        id: 1,
        orderItemId: 10,
        type: AdjustmentType.quantityChange,
        status: AdjustmentStatus.pendingCustomer,
        reason: 'Hanya ada ukuran 1.0kg',
        oldQuantity: 0.7,
        oldPrice: 50000,
        newQuantity: 1.0,
        newPrice: 50000,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuantityCompareWidget(adjustment: adjustment),
          ),
        ),
      );

      expect(find.text('0.7 portion'), findsOneWidget);
      expect(find.text('1 portion'), findsOneWidget);
      expect(find.text('Pesanan Semula'), findsOneWidget);
      expect(find.text('Perubahan Kitchen'), findsOneWidget);
    });

    testWidgets('AdjustmentCard renders card details and buttons', (tester) async {
      bool approved = false;
      bool rejected = false;

      const adjustment = AdjustmentModel(
        id: 1,
        orderItemId: 10,
        type: AdjustmentType.quantityChange,
        status: AdjustmentStatus.pendingCustomer,
        reason: 'Hanya ada ukuran 1.0kg',
        oldQuantity: 0.7,
        oldPrice: 50000,
        newQuantity: 1.0,
        newPrice: 50000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdjustmentCard(
              adjustment: adjustment,
              onApprove: () => approved = true,
              onReject: () => rejected = true,
            ),
          ),
        ),
      );

      expect(find.text('Setujui'), findsOneWidget);
      expect(find.text('Tolak'), findsOneWidget);
      expect(find.text('Quantity Change'), findsOneWidget);

      await tester.tap(find.text('Setujui'));
      expect(approved, true);

      await tester.tap(find.text('Tolak'));
      expect(rejected, true);
    });
  });
}
