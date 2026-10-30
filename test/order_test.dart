import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seafood_pos/app/theme/app_theme.dart';
import 'package:seafood_pos/core/api/api_response.dart';
import 'package:seafood_pos/core/api/dio_client.dart';
import 'package:seafood_pos/core/storage/secure_storage.dart';
import 'package:seafood_pos/features/order/controllers/order_controller.dart';
import 'package:seafood_pos/features/order/models/menu_category.dart';
import 'package:seafood_pos/features/order/models/menu_model.dart';
import 'package:seafood_pos/features/order/models/order_item_model.dart';
import 'package:seafood_pos/features/order/models/order_model.dart';
import 'package:seafood_pos/features/order/repositories/order_repository.dart';
import 'package:seafood_pos/features/order/widgets/category_chip.dart';
import 'package:seafood_pos/features/order/widgets/menu_card.dart';
import 'package:seafood_pos/features/order/widgets/order_summary.dart';
import 'package:seafood_pos/features/order/widgets/quantity_selector.dart';
import 'package:seafood_pos/features/order/widgets/search_bar.dart';
import 'package:seafood_pos/features/order/views/order_page.dart';

class FakeOrderRepository extends OrderRepository {
  bool shouldSucceed = true;
  List<MenuModel> mockMenus = [];
  OrderModel? mockOrder;

  FakeOrderRepository({required super.dioClient});

  @override
  Future<ApiResponse<List<MenuModel>>> getMenus({bool forceRefresh = false}) async {
    if (!shouldSucceed) {
      return ApiResponse<List<MenuModel>>.failure(message: 'Error fetching menus');
    }
    return ApiResponse<List<MenuModel>>.success(data: mockMenus);
  }

  @override
  Future<ApiResponse<OrderModel>> getOrder(int orderId) async {
    if (!shouldSucceed || mockOrder == null) {
      return ApiResponse<OrderModel>.failure(message: 'Order not found');
    }
    return ApiResponse<OrderModel>.success(data: mockOrder!);
  }

  @override
  Future<ApiResponse<OrderModel>> addItem({
    required int orderId,
    required int menuVariantId,
    required double quantity,
  }) async {
    if (!shouldSucceed || mockOrder == null) {
      return ApiResponse<OrderModel>.failure(message: 'Failed to add item');
    }

    // Simulate backend recalculation
    final existingItems = List<OrderItemModel>.from(mockOrder?.items ?? []);
    final newItem = OrderItemModel(
      id: existingItems.length + 1,
      menuVariantId: menuVariantId,
      menuName: 'Ikan Etong Bakar',
      variantName: 'Bakar',
      quantity: quantity,
      unit: 'kg',
      price: 70000.0,
      subtotal: 70000.0 * quantity,
    );
    existingItems.add(newItem);

    final subtotal = existingItems.fold(0.0, (sum, i) => sum + i.subtotal);
    mockOrder = mockOrder?.copyWith(
      items: existingItems,
      subtotal: subtotal,
      grandTotal: subtotal,
    );

    return ApiResponse<OrderModel>.success(data: mockOrder!);
  }

  @override
  Future<ApiResponse<OrderModel>> updateItem({
    required int orderItemId,
    required double quantity,
  }) async {
    if (!shouldSucceed || mockOrder == null) {
      return ApiResponse<OrderModel>.failure(message: 'Failed to update item');
    }

    final existingItems = List<OrderItemModel>.from(mockOrder?.items ?? []);
    final index = existingItems.indexWhere((i) => i.id == orderItemId);
    if (index != -1) {
      final old = existingItems[index];
      existingItems[index] = old.copyWith(
        quantity: quantity,
        subtotal: old.price * quantity,
      );
    }

    final subtotal = existingItems.fold(0.0, (sum, i) => sum + i.subtotal);
    mockOrder = mockOrder?.copyWith(
      items: existingItems,
      subtotal: subtotal,
      grandTotal: subtotal,
    );

    return ApiResponse<OrderModel>.success(data: mockOrder!);
  }

  @override
  Future<ApiResponse<OrderModel>> deleteItem(int orderItemId) async {
    if (!shouldSucceed || mockOrder == null) {
      return ApiResponse<OrderModel>.failure(message: 'Failed to delete item');
    }

    final existingItems = List<OrderItemModel>.from(mockOrder?.items ?? [])
      ..removeWhere((i) => i.id == orderItemId);

    final subtotal = existingItems.fold(0.0, (sum, i) => sum + i.subtotal);
    mockOrder = mockOrder?.copyWith(
      items: existingItems,
      subtotal: subtotal,
      grandTotal: subtotal,
    );

    return ApiResponse<OrderModel>.success(data: mockOrder!);
  }
}

void main() {
  late SecureStorageService storageService;
  late DioClient dioClient;
  late FakeOrderRepository orderRepository;
  late OrderController orderController;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    storageService = SecureStorageService(isTest: true);
    dioClient = DioClient(storageService: storageService);
    orderRepository = FakeOrderRepository(dioClient: dioClient);

    orderRepository.mockMenus = [
      const MenuModel(
        id: 1,
        name: 'Cumi',
        type: 'seafood',
        variants: [
          MenuVariantModel(
            id: 10,
            name: 'Cumi Crispy',
            price: 35000.0,
            salesUnit: 'portion',
            station: 'Masak',
          ),
          MenuVariantModel(
            id: 11,
            name: 'Cumi Asam Manis',
            price: 35000.0,
            salesUnit: 'portion',
            station: 'Masak',
          ),
        ],
      ),
      const MenuModel(
        id: 2,
        name: 'Es Jeruk',
        type: 'drink',
        variants: [
          MenuVariantModel(
            id: 20,
            name: 'Es Jeruk Segar',
            price: 10000.0,
            salesUnit: 'glass',
            station: 'Minuman',
          ),
        ],
      ),
    ];

    orderRepository.mockOrder = const OrderModel(
      id: 100,
      orderNumber: '#ORD-100',
      tableNumber: 'A1',
      customerName: 'Budi Santoso',
      guestCount: 2,
      status: 'draft',
      subtotal: 0.0,
      grandTotal: 0.0,
      items: [],
    );
  });

  group('Order Controller Logic Tests', () {
    test('Initialization loads menus and order context properly', () async {
      orderController = OrderController(orderRepository: orderRepository);
      orderController.orderId.value = 100;
      orderController.orderId.value = 100;
      await orderController.initData();

      expect(orderController.menus.length, 2);
      expect(orderController.filteredMenus.length, 2);
      expect(orderController.order.value, isNotNull);
      expect(orderController.order.value?.orderNumber, '#ORD-100');
      expect(orderController.order.value?.tableNumber, 'A1');
    });

    test('Filter menu by category works accurately', () async {
      orderController = OrderController(orderRepository: orderRepository);
      await orderController.loadMenus();

      // Filter drink
      orderController.setCategory('drink');
      expect(orderController.filteredMenus.length, 1);
      expect(orderController.filteredMenus.first.name, 'Es Jeruk');

      // Filter all
      orderController.setCategory('all');
      expect(orderController.filteredMenus.length, 2);
    });

    test('Search menu by name and variant keyword works accurately', () async {
      orderController = OrderController(orderRepository: orderRepository);
      await orderController.loadMenus();

      // Search menu name
      orderController.searchMenu('cumi');
      expect(orderController.filteredMenus.length, 1);
      expect(orderController.filteredMenus.first.name, 'Cumi');

      // Search variant name
      orderController.searchMenu('crispy');
      expect(orderController.filteredMenus.length, 1);
      expect(orderController.filteredMenus.first.name, 'Cumi');

      // Clear search
      orderController.clearSearch();
      expect(orderController.filteredMenus.length, 2);
    });

    test('Add item updates order cart and backend totals', () async {
      orderController = OrderController(orderRepository: orderRepository);
      orderController.orderId.value = 100;
      orderController.orderId.value = 100;
      await orderController.initData();

      final variant = orderRepository.mockMenus.first.variants.first;
      await orderController.addItem(variant, quantity: 2);

      expect(orderController.cartItems.length, 1);
      expect(orderController.totalItemCount, 2);
      expect(orderController.grandTotal, 140000.0);
    });

    test('Update item quantity alters subtotal and grandTotal directly from backend', () async {
      orderController = OrderController(orderRepository: orderRepository);
      orderController.orderId.value = 100;
      orderController.orderId.value = 100;
      await orderController.initData();

      final variant = orderRepository.mockMenus.first.variants.first;
      await orderController.addItem(variant, quantity: 1);

      final item = orderController.cartItems.first;
      await orderController.updateItemQuantity(item, 3);

      expect(orderController.cartItems.first.quantity, 3.0);
      expect(orderController.grandTotal, 210000.0);
    });

    test('Delete item removes it from order and syncs backend total', () async {
      orderController = OrderController(orderRepository: orderRepository);
      orderController.orderId.value = 100;
      orderController.orderId.value = 100;
      await orderController.initData();

      final variant = orderRepository.mockMenus.first.variants.first;
      await orderController.addItem(variant, quantity: 1);
      expect(orderController.cartItems.length, 1);

      final item = orderController.cartItems.first;
      await orderController.deleteItem(item.id);

      expect(orderController.cartItems.isEmpty, true);
      expect(orderController.grandTotal, 0.0);
    });
  });

  group('Order Widgets Tests', () {
    testWidgets('CategoryChip displays name and handles selection', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              category: const MenuCategory(id: 'seafood', name: 'Seafood'),
              isSelected: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Seafood'), findsOneWidget);
      await tester.tap(find.byType(CategoryChip));
      expect(tapped, isTrue);
    });

    testWidgets('OrderSearchBar handles text input and clear button', (tester) async {
      String searched = '';
      bool cleared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrderSearchBar(
              initialValue: 'ikan',
              onChanged: (val) => searched = val,
              onClear: () => cleared = true,
            ),
          ),
        ),
      );

      expect(searched, equals(''));
      expect(find.text('ikan'), findsOneWidget);
      expect(find.byIcon(Icons.clear_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pump();
      expect(cleared, isTrue);
    });

    testWidgets('QuantitySelector increments and decrements correctly', (tester) async {
      int count = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return QuantitySelector(
                  quantity: count.toDouble(),
                  onIncrement: () => setState(() => count++),
                  onDecrement: () => setState(() => count--),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('OrderMenuCard renders menu details and handles add tap', (tester) async {
      bool added = false;
      const menu = MenuModel(
        id: 1,
        name: 'Ikan Etong Bakar',
        type: 'seafood',
        variants: [
          MenuVariantModel(
            id: 1,
            name: 'Bakar',
            price: 70000.0,
            station: 'Bakar',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: OrderMenuCard(
              menu: menu,
              cartQuantity: 1,
              onAdd: () => added = true,
            ),
          ),
        ),
      );

      expect(find.text('Ikan Etong Bakar'), findsOneWidget);
      expect(find.text('Bakar'), findsWidgets);
      await tester.tap(find.byType(OrderMenuCard));
      expect(added, isTrue);
    });

    testWidgets('OrderSummaryWidget renders subtotal and grandTotal properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: OrderSummaryWidget(
              subtotal: 150000.0,
              discount: 0.0,
              grandTotal: 150000.0,
              totalItemCount: 3,
            ),
          ),
        ),
      );

      expect(find.text('Ringkasan Pesanan'), findsOneWidget);
      expect(find.text('3 item'), findsOneWidget);
      expect(find.textContaining('150.000'), findsWidgets);
    });

    testWidgets('OrderPage compact view renders bottom bar and buttons without constraint error', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      orderController = OrderController(orderRepository: orderRepository);
      Get.put<OrderController>(orderController);

      orderRepository.mockOrder = const OrderModel(
        id: 100,
        orderNumber: '#ORD-100',
        tableNumber: 'A1',
        customerName: 'Budi',
        guestCount: 2,
        subtotal: 70000.0,
        grandTotal: 70000.0,
        items: [
          OrderItemModel(
            id: 1,
            menuVariantId: 10,
            menuName: 'Cumi',
            variantName: 'Crispy',
            quantity: 2,
            price: 35000.0,
            subtotal: 70000.0,
          ),
        ],
      );

      orderController.orderId.value = 100;
      await orderController.initData();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OrderPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Keranjang'), findsOneWidget);
      expect(find.text('Total Pesanan'), findsOneWidget);
    });
  });
}
