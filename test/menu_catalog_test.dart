import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seafood_pos/app/theme/app_theme.dart';
import 'package:seafood_pos/core/api/api_response.dart';
import 'package:seafood_pos/core/api/dio_client.dart';
import 'package:seafood_pos/core/storage/secure_storage.dart';
import 'package:seafood_pos/features/inventory/models/stock_status.dart';
import 'package:seafood_pos/features/inventory/widgets/stock_badge.dart';
import 'package:seafood_pos/features/menu/controllers/menu_catalog_controller.dart';
import 'package:seafood_pos/features/menu/views/menu_page.dart';
import 'package:seafood_pos/features/order/models/menu_model.dart';
import 'package:seafood_pos/features/order/repositories/order_repository.dart';

class FakeOrderRepository extends OrderRepository {
  List<MenuModel> mockMenus = [];

  FakeOrderRepository({required super.dioClient});

  @override
  Future<ApiResponse<List<MenuModel>>> getMenus({bool forceRefresh = false}) async {
    return ApiResponse<List<MenuModel>>.success(data: mockMenus);
  }
}

void main() {
  late FakeOrderRepository fakeOrderRepository;
  late MenuCatalogController menuCatalogController;

  final sampleMenus = [
    const MenuModel(
      id: 1,
      name: 'Ikan Gurame',
      type: 'seafood',
      stockStatus: StockStatus.available,
      stockQuantity: 15.0,
      variants: [
        MenuVariantModel(
          id: 101,
          name: 'Bakar Madu',
          price: 65000,
          salesUnit: 'portion',
          stockStatus: StockStatus.available,
          stockQuantity: 15.0,
          cookingMethod: 'Bakar',
          station: 'Grill',
        ),
        MenuVariantModel(
          id: 102,
          name: 'Asam Manis',
          price: 65000,
          salesUnit: 'portion',
          stockStatus: StockStatus.lowStock,
          stockQuantity: 2.0,
          cookingMethod: 'Goreng',
          station: 'Wok',
        ),
      ],
    ),
    const MenuModel(
      id: 2,
      name: 'Kepiting Bakau',
      type: 'seafood',
      stockStatus: StockStatus.needMarketCheck,
      needMarketCheck: true,
      variants: [
        MenuVariantModel(
          id: 201,
          name: 'Saus Padang',
          price: 120000,
          salesUnit: 'portion',
          stockStatus: StockStatus.needMarketCheck,
          needMarketCheck: true,
        ),
      ],
    ),
    const MenuModel(
      id: 3,
      name: 'Es Teh Manis',
      type: 'beverage',
      stockStatus: StockStatus.available,
      stockQuantity: 50.0,
      variants: [
        MenuVariantModel(
          id: 301,
          name: 'Dingin',
          price: 5000,
          salesUnit: 'glass',
          stockStatus: StockStatus.available,
          stockQuantity: 50.0,
        ),
      ],
    ),
  ];

  setUp(() {
    Get.reset();
    Get.testMode = true;
    final storage = SecureStorageService(isTest: true);
    final dioClient = DioClient(storageService: storage);
    fakeOrderRepository = FakeOrderRepository(dioClient: dioClient);
    fakeOrderRepository.mockMenus = sampleMenus;

    menuCatalogController = MenuCatalogController(orderRepository: fakeOrderRepository);
    Get.put<MenuCatalogController>(menuCatalogController);
  });

  tearDown(() {
    Get.reset();
  });

  group('MenuCatalogController Tests', () {
    test('Loads menu catalog with variants and stock awareness', () async {
      await menuCatalogController.loadMenus();

      expect(menuCatalogController.menus.length, equals(3));
      expect(menuCatalogController.availableTypes, containsAll(['all', 'seafood', 'beverage']));
      expect(menuCatalogController.lowStockCount, equals(1));
      expect(menuCatalogController.needMarketCheckCount, equals(1));
      expect(menuCatalogController.outOfStockCount, equals(0));
    });

    test('Filters by category correctly', () async {
      await menuCatalogController.loadMenus();

      menuCatalogController.selectedType.value = 'beverage';
      expect(menuCatalogController.filteredMenus.length, equals(1));
      expect(menuCatalogController.filteredMenus.first.name, equals('Es Teh Manis'));
    });

    test('Filters by search query (menu name and sauce name)', () async {
      await menuCatalogController.loadMenus();

      // Search by variant / sauce name
      menuCatalogController.searchQuery.value = 'Padang';
      expect(menuCatalogController.filteredMenus.length, equals(1));
      expect(menuCatalogController.filteredMenus.first.name, equals('Kepiting Bakau'));

      // Search by dish name
      menuCatalogController.searchQuery.value = 'Gurame';
      expect(menuCatalogController.filteredMenus.length, equals(1));
      expect(menuCatalogController.filteredMenus.first.name, equals('Ikan Gurame'));
    });

    test('Filters by stock status correctly', () async {
      await menuCatalogController.loadMenus();

      menuCatalogController.toggleStockFilter(StockStatus.needMarketCheck);
      expect(menuCatalogController.filteredMenus.length, equals(1));
      expect(menuCatalogController.filteredMenus.first.name, equals('Kepiting Bakau'));
    });
  });

  group('MenuPage Widget Tests', () {
    testWidgets('Renders MenuPage with stock metrics, search bar, and menu cards', (tester) async {
      await menuCatalogController.loadMenus();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MenuPage(),
        ),
      );

      // Verify header and metrics
      expect(find.text('Katalog Menu & Stok'), findsOneWidget);
      expect(find.text('Menipis'), findsOneWidget);
      expect(find.text('Cek Pasar'), findsOneWidget);
      expect(find.text('Habis'), findsOneWidget);

      // Verify menu and variant content
      expect(find.text('Ikan Gurame'), findsOneWidget);
      expect(find.text('Bakar Madu'), findsOneWidget);
      expect(find.text('Asam Manis'), findsOneWidget);
      expect(find.text('Kepiting Bakau'), findsOneWidget);

      // Verify StockBadges
      expect(find.byType(StockBadge), findsWidgets);
    });
  });
}

