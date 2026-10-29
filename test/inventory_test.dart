import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seafood_pos/core/api/api_response.dart';
import 'package:seafood_pos/core/api/dio_client.dart';
import 'package:seafood_pos/features/inventory/controllers/inventory_controller.dart';
import 'package:seafood_pos/features/inventory/models/stock_info_model.dart';
import 'package:seafood_pos/features/inventory/models/stock_status.dart';
import 'package:seafood_pos/features/inventory/repositories/inventory_repository.dart';
import 'package:seafood_pos/features/inventory/widgets/market_check_badge.dart';
import 'package:seafood_pos/features/inventory/widgets/stock_badge.dart';
import 'package:seafood_pos/features/inventory/widgets/stock_indicator.dart';
import 'package:seafood_pos/features/inventory/widgets/stock_information_tile.dart';
import 'package:seafood_pos/features/inventory/widgets/stock_warning_card.dart';
import 'package:seafood_pos/features/order/models/menu_model.dart';
import 'package:seafood_pos/features/order/widgets/menu_card.dart';
import 'package:seafood_pos/features/order/widgets/variant_selection_dialog.dart';

class FakeInventoryRepository implements InventoryRepository {
  List<StockInfoModel> mockItems;
  bool shouldSucceed;

  FakeInventoryRepository({
    this.mockItems = const [],
    this.shouldSucceed = true,
  });

  @override
  DioClient get dioClient => throw UnimplementedError();

  @override
  Future<ApiResponse<List<StockInfoModel>>> getMenuInventory({bool forceRefresh = false}) async {
    if (!shouldSucceed) {
      return ApiResponse<List<StockInfoModel>>.failure(message: 'Error fetching inventory');
    }
    return ApiResponse<List<StockInfoModel>>.success(data: mockItems);
  }

  @override
  Future<ApiResponse<List<StockInfoModel>>> refreshInventory() async {
    return getMenuInventory(forceRefresh: true);
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('Sprint 10 - Stock Models & Serialization Tests', () {
    test('StockStatus.fromString parses all statuses and handles fallbacks correctly', () {
      expect(StockStatus.fromString('available'), equals(StockStatus.available));
      expect(StockStatus.fromString('low_stock'), equals(StockStatus.lowStock));
      expect(StockStatus.fromString('out_of_stock'), equals(StockStatus.outOfStock));
      expect(StockStatus.fromString('need_market_check'), equals(StockStatus.needMarketCheck));
      expect(StockStatus.fromString('unknown_status'), equals(StockStatus.available));
      expect(StockStatus.fromString(null), equals(StockStatus.available));
      expect(StockStatus.fromString('any', needMarketCheck: true), equals(StockStatus.needMarketCheck));
    });

    test('StockStatus getters have non-empty labels and proper colors', () {
      for (final status in StockStatus.values) {
        expect(status.label.isNotEmpty, isTrue);
        expect(status.badgeText.isNotEmpty, isTrue);
        expect(status.color, isNotNull);
        expect(status.backgroundColor, isNotNull);
        expect(status.icon, isNotNull);
      }
    });

    test('StockInfoModel parses correctly from Menu and Variant JSON', () {
      final menuJson = {
        'id': 10,
        'name': 'Ikan Etong',
        'stock_status': 'need_market_check',
        'stock_quantity': 0.0,
        'need_market_check': true,
      };

      final menuStock = StockInfoModel.fromMenuJson(menuJson);
      expect(menuStock.menuId, equals(10));
      expect(menuStock.menuName, equals('Ikan Etong'));
      expect(menuStock.stockStatus, equals(StockStatus.needMarketCheck));
      expect(menuStock.stockQuantity, equals(0.0));
      expect(menuStock.isNeedMarketCheck, isTrue);
      expect(menuStock.canOrder, isTrue);

      final variantJson = {
        'id': 20,
        'name': 'Etong Bakar Kecap',
        'sales_unit': 'kg',
        'stock_status': 'available',
        'stock_quantity': 15.5,
        'need_market_check': false,
        'ingredient': 'Ikan Etong',
        'station': 'Bakar',
      };

      final variantStock = StockInfoModel.fromVariantJson(
        variantJson,
        menuId: 10,
        menuName: 'Ikan Etong',
      );
      expect(variantStock.variantId, equals(20));
      expect(variantStock.variantName, equals('Etong Bakar Kecap'));
      expect(variantStock.stockStatus, equals(StockStatus.available));
      expect(variantStock.stockQuantity, equals(15.5));
      expect(variantStock.ingredientName, equals('Ikan Etong'));
      expect(variantStock.isAvailable, isTrue);
      expect(variantStock.isOutOfStock, isFalse);
    });

    test('MenuModel and MenuVariantModel parse stock awareness fields correctly', () {
      final variantJson = {
        'id': 1,
        'name': 'Cumi Crispy',
        'price': 35000,
        'sales_unit': 'portion',
        'stock_status': 'low_stock',
        'stock_quantity': 3.0,
        'need_market_check': false,
      };

      final menuJson = {
        'id': 2,
        'name': 'Cumi Goreng',
        'type': 'seafood',
        'stock_status': 'low_stock',
        'stock_quantity': 3.0,
        'need_market_check': false,
        'variants': [variantJson],
      };

      final menu = MenuModel.fromJson(menuJson);
      expect(menu.stockStatus, equals(StockStatus.lowStock));
      expect(menu.stockQuantity, equals(3.0));
      expect(menu.isLowStock, isTrue);
      expect(menu.canOrder, isTrue);
      expect(menu.variants.first.isLowStock, isTrue);
    });
  });

  group('Sprint 10 - InventoryController Logic Tests', () {
    late FakeInventoryRepository repository;
    late InventoryController controller;

    final mockStockList = [
      const StockInfoModel(
        menuId: 1,
        menuName: 'Ikan Gurame',
        stockStatus: StockStatus.available,
        stockQuantity: 20.0,
        salesUnit: 'kg',
      ),
      const StockInfoModel(
        menuId: 2,
        menuName: 'Cumi Calamari',
        stockStatus: StockStatus.lowStock,
        stockQuantity: 2.0,
        salesUnit: 'portion',
      ),
      const StockInfoModel(
        menuId: 3,
        menuName: 'Kepiting Asam Manis',
        stockStatus: StockStatus.needMarketCheck,
        stockQuantity: 0.0,
        salesUnit: 'portion',
        needMarketCheck: true,
      ),
      const StockInfoModel(
        menuId: 4,
        menuName: 'Es Teh Manis',
        stockStatus: StockStatus.outOfStock,
        stockQuantity: 0.0,
        salesUnit: 'portion',
      ),
    ];

    setUp(() {
      repository = FakeInventoryRepository(
        mockItems: mockStockList,
      );
      controller = InventoryController(repository: repository);
    });

    test('loadInventoryInfo loads data and sets metric counts accurately', () async {
      await controller.loadInventoryInfo();
      expect(controller.stockInfo.length, equals(4));
      expect(controller.lowStockCount, equals(1));
      expect(controller.outOfStockCount, equals(1));
      expect(controller.needMarketCheckCount, equals(1));
      expect(controller.isLoading.value, isFalse);
    });

    test('getStockStatus retrieves correct status by menuId', () async {
      await controller.loadInventoryInfo();
      expect(controller.getStockStatus(1), equals(StockStatus.available));
      expect(controller.getStockStatus(2), equals(StockStatus.lowStock));
      expect(controller.getStockStatus(3), equals(StockStatus.needMarketCheck));
      expect(controller.getStockStatus(4), equals(StockStatus.outOfStock));
    });

    test('filtering and search operate correctly on stockInfo', () async {
      await controller.loadInventoryInfo();

      // Search by query
      controller.searchQuery.value = 'Gurame';
      expect(controller.filteredStockInfo.length, equals(1));
      expect(controller.filteredStockInfo.first.menuName, equals('Ikan Gurame'));

      // Filter by status
      controller.searchQuery.value = '';
      controller.filterStatus.value = StockStatus.lowStock;
      expect(controller.filteredStockInfo.length, equals(1));
      expect(controller.filteredStockInfo.first.menuName, equals('Cumi Calamari'));

      controller.filterStatus.value = null;
      expect(controller.filteredStockInfo.length, equals(4));
    });

    test('refreshInventory triggers re-load with forceRefresh', () async {
      await controller.refreshInventory();
      expect(controller.stockInfo.length, equals(4));
    });
  });

  group('Sprint 10 - UI Widgets Tests', () {
    testWidgets('StockBadge renders correct badge text for all statuses', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StockBadge(status: StockStatus.available),
                StockBadge(status: StockStatus.lowStock),
                StockBadge(status: StockStatus.needMarketCheck),
                StockBadge(status: StockStatus.outOfStock),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Low Stock'), findsOneWidget);
      expect(find.text('Perlu Cek Pasar'), findsOneWidget);
      expect(find.text('Out of Stock'), findsOneWidget);
    });

    testWidgets('StockIndicator renders cleanly with status color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StockIndicator(status: StockStatus.available, size: 12),
          ),
        ),
      );

      expect(find.byType(StockIndicator), findsOneWidget);
    });

    testWidgets('StockWarningCard displays message for low stock and market check', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StockWarningCard(status: StockStatus.lowStock),
                StockWarningCard(status: StockStatus.needMarketCheck),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Stok Hampir Habis'), findsOneWidget);
      expect(find.text('Perlu Cek Pasar'), findsOneWidget);
    });

    testWidgets('MarketCheckBadge displays dedicated badge and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarketCheckBadge(),
          ),
        ),
      );

      expect(find.text('Perlu Cek Pasar'), findsOneWidget);
      expect(find.byIcon(Icons.storefront_rounded), findsOneWidget);
    });

    testWidgets('StockInformationTile renders menu title, badge, and quantity', (tester) async {
      const item = StockInfoModel(
        menuId: 1,
        menuName: 'Ikan Bawal Bakar',
        stockStatus: StockStatus.available,
        stockQuantity: 10.5,
        salesUnit: 'kg',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StockInformationTile(stockInfo: item),
          ),
        ),
      );

      expect(find.text('Ikan Bawal Bakar'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('10.5 kg'), findsOneWidget);
    });

    testWidgets('OrderMenuCard disables tap when out of stock', (tester) async {
      bool tapped = false;
      const outOfStockMenu = MenuModel(
        id: 99,
        name: 'Kepiting Bakar',
        type: 'seafood',
        stockStatus: StockStatus.outOfStock,
        variants: [
          MenuVariantModel(
            id: 991,
            name: 'Kepiting Bakar Porsi',
            price: 85000,
            stockStatus: StockStatus.outOfStock,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 220,
              child: OrderMenuCard(
                menu: outOfStockMenu,
                cartQuantity: 0,
                onAdd: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Kepiting Bakar'), findsOneWidget);
      expect(find.text('Out of Stock'), findsOneWidget);
      expect(find.text('Menu tidak tersedia'), findsOneWidget);

      await tester.tap(find.byType(OrderMenuCard));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('VariantSelectionDialog disables out-of-stock variant and warns low stock', (tester) async {
      const testMenu = MenuModel(
        id: 10,
        name: 'Cumi Segar',
        type: 'seafood',
        variants: [
          MenuVariantModel(
            id: 101,
            name: 'Cumi Bakar',
            price: 40000,
            stockStatus: StockStatus.lowStock,
            stockQuantity: 2.0,
          ),
          MenuVariantModel(
            id: 102,
            name: 'Cumi Rebus',
            price: 35000,
            stockStatus: StockStatus.outOfStock,
            stockQuantity: 0.0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VariantSelectionDialog(
              menu: testMenu,
              onSelect: (variant, qty) {},
            ),
          ),
        ),
      );

      // Verify Cumi Bakar (low stock) and Cumi Rebus (out of stock) are rendered
      expect(find.text('Cumi Bakar'), findsOneWidget);
      expect(find.text('Cumi Rebus'), findsOneWidget);

      // Warning card for low stock is displayed for selected variant
      expect(find.text('Stok Hampir Habis'), findsOneWidget);

      // Out of stock variant has Out of Stock badge
      expect(find.text('Out of Stock'), findsOneWidget);
    });
  });
}
