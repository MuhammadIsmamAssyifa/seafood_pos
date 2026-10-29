import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seafood_pos/app/theme/app_theme.dart';
import 'package:seafood_pos/core/api/api_response.dart';
import 'package:seafood_pos/core/api/dio_client.dart';
import 'package:seafood_pos/core/services/connectivity_service.dart';
import 'package:seafood_pos/core/storage/secure_storage.dart';
import 'package:seafood_pos/features/auth/controllers/auth_controller.dart';
import 'package:seafood_pos/features/auth/models/user_model.dart';
import 'package:seafood_pos/features/auth/repositories/auth_repository.dart';
import 'package:seafood_pos/features/dashboard/controllers/dashboard_controller.dart';
import 'package:seafood_pos/features/dashboard/models/dashboard_menu_item.dart';
import 'package:seafood_pos/features/dashboard/models/outlet_model.dart';
import 'package:seafood_pos/features/dashboard/repositories/dashboard_repository.dart';
import 'package:seafood_pos/features/dashboard/widgets/dashboard_header.dart';
import 'package:seafood_pos/features/dashboard/widgets/logout_dialog.dart';
import 'package:seafood_pos/features/dashboard/widgets/menu_card.dart';
import 'package:seafood_pos/features/dashboard/widgets/user_card.dart';

class FakeDashboardRepository extends DashboardRepository {
  UserModel? mockUser;
  OutletModel? mockOutlet;

  FakeDashboardRepository({
    required super.dioClient,
    required super.storageService,
  });

  @override
  Future<ApiResponse<UserModel>> getUserProfile() async {
    return ApiResponse<UserModel>.success(
      data: mockUser ??
          const UserModel(
            id: 1,
            name: 'Kasir Satu',
            username: 'kasir1',
            roles: ['cashier'],
          ),
    );
  }

  @override
  Future<OutletModel> getOutletInfo() async {
    return mockOutlet ?? OutletModel.defaultOutlet();
  }

  @override
  Future<void> logout() async {
    await storageService.deleteToken();
    await storageService.clearAll();
  }
}

void main() {
  late SecureStorageService storageService;
  late DioClient dioClient;
  late FakeDashboardRepository dashboardRepository;
  late DashboardController dashboardController;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    storageService = SecureStorageService(isTest: true);
    dioClient = DioClient(storageService: storageService);
    dashboardRepository = FakeDashboardRepository(
      dioClient: dioClient,
      storageService: storageService,
    );

    Get.put<ConnectivityService>(ConnectivityService());
    Get.put<AuthRepository>(
      AuthRepository(dioClient: dioClient, storageService: storageService),
    );
    Get.put<AuthController>(
      AuthController(authRepository: Get.find<AuthRepository>()),
    );

    dashboardController = DashboardController(
      dashboardRepository: dashboardRepository,
    );
    Get.put<DashboardController>(dashboardController);
  });

  tearDown(() {
    Get.reset();
  });

  group('Sprint 03 - Model Tests', () {
    test('OutletModel parses and has defaults', () {
      final outlet = OutletModel.defaultOutlet();
      expect(outlet.name, equals('Cabang Utama'));
      expect(outlet.restaurantName, equals('Seafood Restaurant'));

      final json = outlet.toJson();
      final fromJson = OutletModel.fromJson(json);
      expect(fromJson.name, equals(outlet.name));
    });

    test('DashboardMenuItem correctly initializes', () {
      const item = DashboardMenuItem(
        id: 'test',
        title: 'Test Menu',
        subtitle: 'Test Subtitle',
        icon: Icons.star,
        color: Colors.blue,
        route: '/test',
        badge: 'New',
      );

      expect(item.id, equals('test'));
      expect(item.badge, equals('New'));
      expect(item.isEnabled, isTrue);
    });
  });

  group('Sprint 03 - DashboardController Tests', () {
    test('Initializes shortcut menus on start', () {
      expect(dashboardController.menuList.length, greaterThanOrEqualTo(4));
      expect(
        dashboardController.menuList.any((m) => m.title == 'Order Baru'),
        isTrue,
      );
      expect(
        dashboardController.menuList.any((m) => m.title == 'Daftar Meja'),
        isTrue,
      );
    });

    test('Loads dashboard data into state observables', () async {
      await dashboardController.loadDashboardData();

      expect(dashboardController.user.value?.name, equals('Kasir Satu'));
      expect(dashboardController.outlet.value?.name, equals('Cabang Utama'));
    });
  });

  group('Sprint 03 - UI Widgets Tests', () {
    testWidgets('DashboardHeader renders outlet name and buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: DashboardHeader(controller: dashboardController),
          ),
        ),
      );

      expect(find.text('Seafood Restaurant'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });

    testWidgets('UserCard displays cashier name and role badge', (tester) async {
      const user = UserModel(
        id: 5,
        name: 'Budi Hartono',
        username: 'budi_kasir',
        roles: ['cashier'],
      );
      final outlet = OutletModel.defaultOutlet();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: UserCard(user: user, outlet: outlet),
          ),
        ),
      );

      expect(find.text('Budi Hartono'), findsOneWidget);
      expect(find.text('Kasir'), findsOneWidget);
      expect(find.text('@budi_kasir'), findsOneWidget);
    });

    testWidgets('MenuCard renders and handles tap', (tester) async {
      bool tapped = false;
      const item = DashboardMenuItem(
        id: 'tables',
        title: 'Daftar Meja',
        subtitle: 'Status meja',
        icon: Icons.table_restaurant,
        color: Colors.blue,
        route: '/tables',
        badge: 'Sprint 04',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MenuCard(item: item, onTap: () => tapped = true),
          ),
        ),
      );

      expect(find.text('Daftar Meja'), findsOneWidget);
      expect(find.text('Sprint 04'), findsOneWidget);

      await tester.tap(find.text('Daftar Meja'));
      expect(tapped, isTrue);
    });

    testWidgets('LogoutDialog triggers confirm callback', (tester) async {
      bool loggedOut = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: LogoutDialog(onConfirm: () => loggedOut = true),
          ),
        ),
      );

      expect(find.text('Konfirmasi Logout'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Ya, Keluar'), findsOneWidget);

      await tester.tap(find.text('Ya, Keluar'));
      expect(loggedOut, isTrue);
    });
  });
}

