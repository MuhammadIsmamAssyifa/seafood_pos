import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seafood_pos/app/routes/app_routes.dart';
import 'package:seafood_pos/app/routes/auth_middleware.dart';
import 'package:seafood_pos/app/theme/app_theme.dart';
import 'package:seafood_pos/core/api/api_response.dart';
import 'package:seafood_pos/core/api/dio_client.dart';
import 'package:seafood_pos/core/storage/secure_storage.dart';
import 'package:seafood_pos/features/auth/controllers/auth_controller.dart';
import 'package:seafood_pos/features/auth/models/user_model.dart';
import 'package:seafood_pos/features/auth/repositories/auth_repository.dart';
import 'package:seafood_pos/features/auth/widgets/password_field.dart';
import 'package:seafood_pos/features/auth/widgets/login_form.dart';
import 'package:seafood_pos/shared/enums/app_enums.dart';

class FakeAuthRepository extends AuthRepository {
  bool shouldSucceed = true;
  String? mockErrorMessage;

  FakeAuthRepository({
    required super.dioClient,
    required super.storageService,
  });

  @override
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
    String deviceName = 'pos',
  }) async {
    if (!shouldSucceed) {
      return ApiResponse<UserModel>.failure(
        message: mockErrorMessage ?? 'Invalid credential',
        statusCode: 401,
      );
    }

    final user = UserModel(
      id: 1,
      name: 'Kasir Satu',
      username: 'kasir1',
      email: email,
      roles: ['cashier'],
      token: 'mock-valid-token',
    );
    await storageService.saveToken(user.token!);
    await storageService.saveUserData(user.toJson());

    return ApiResponse<UserModel>.success(data: user);
  }

  @override
  Future<ApiResponse<UserModel>> staffLogin({
    required String username,
    required String pin,
    String deviceName = 'pos',
  }) async {
    if (!shouldSucceed) {
      return ApiResponse<UserModel>.failure(
        message: mockErrorMessage ?? 'Invalid credential',
        statusCode: 401,
      );
    }

    final user = UserModel(
      id: 2,
      name: 'Staff Kasir',
      username: username,
      roles: ['cashier'],
      token: 'mock-staff-token',
    );
    await storageService.saveToken(user.token!);
    await storageService.saveUserData(user.toJson());

    return ApiResponse<UserModel>.success(data: user);
  }

  @override
  Future<ApiResponse<UserModel>> getProfile() async {
    final cached = await getCachedUser();
    if (cached != null) {
      return ApiResponse<UserModel>.success(data: cached);
    }
    return ApiResponse<UserModel>.failure(message: 'User not found');
  }

  @override
  Future<void> logout() async {
    await storageService.deleteToken();
    await storageService.clearAll();
  }

  @override
  Future<bool> hasValidToken() async {
    return await storageService.hasToken();
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final data = await storageService.getUserData();
    if (data != null) return UserModel.fromJson(data);
    return null;
  }
}

void main() {
  late SecureStorageService storageService;
  late DioClient dioClient;
  late FakeAuthRepository authRepository;
  late AuthController authController;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    storageService = SecureStorageService(isTest: true);
    dioClient = DioClient(storageService: storageService);
    authRepository = FakeAuthRepository(
      dioClient: dioClient,
      storageService: storageService,
    );
    authController = AuthController(authRepository: authRepository);
    Get.put<AuthController>(authController);
  });

  tearDown(() async {
    await storageService.clearAll();
    Get.reset();
  });

  group('Sprint 02 - UserModel & Serialization Tests', () {
    test('Parses Laravel auth response correctly', () {
      final laravelAuthResponse = {
        'token': '1|sanctum_token_abc',
        'user': {
          'id': 10,
          'name': 'Budi Santoso',
          'email': 'budi@seafood.id',
          'username': 'budi',
          'status': 'active',
          'roles': ['cashier'],
        }
      };

      final user = UserModel.fromAuthResponse(laravelAuthResponse);
      expect(user.id, equals(10));
      expect(user.name, equals('Budi Santoso'));
      expect(user.username, equals('budi'));
      expect(user.token, equals('1|sanctum_token_abc'));
      expect(user.isCashier, isTrue);
      expect(user.primaryRole, equals(UserRole.cashier));
      expect(user.isActive, isTrue);
    });
  });

  group('Sprint 02 - AuthController & Session State Tests', () {
    test('Login success updates currentUser and saves token', () async {
      authRepository.shouldSucceed = true;

      final result = await authController.login(
        email: 'kasir@resto.id',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentUser.value?.email, equals('kasir@resto.id'));

      final token = await storageService.getToken();
      expect(token, isNotNull);
    });

    test('Staff PIN login success updates user and token', () async {
      authRepository.shouldSucceed = true;

      final result = await authController.staffLogin(
        username: 'kasir1',
        pin: '1234',
      );

      expect(result, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentUser.value?.username, equals('kasir1'));
    });

    test('Login failure sets errorMessage and keeps user unauthenticated', () async {
      authRepository.shouldSucceed = false;
      authRepository.mockErrorMessage = 'Password atau email salah';

      final result = await authController.login(
        email: 'salah@resto.id',
        password: 'wrongpassword',
      );

      expect(result, isFalse);
      expect(authController.isAuthenticated, isFalse);
      expect(authController.errorMessage.value, contains('Password atau email salah'));
    });

    test('Logout clears session and resets authentication state', () async {
      // First login
      authRepository.shouldSucceed = true;
      await authController.login(email: 'kasir@resto.id', password: 'password123');
      expect(authController.isAuthenticated, isTrue);

      // Now logout
      await authController.logout();
      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentUser.value, isNull);

      final token = await storageService.getToken();
      expect(token, isNull);
    });

    test('Session check restores user from storage', () async {
      // Pre-save user and token
      await storageService.saveToken('existing-valid-token');
      await storageService.saveUserData({
        'id': 3,
        'name': 'Kasir Dua',
        'username': 'kasir2',
        'email': 'kasir2@resto.id',
        'roles': ['cashier'],
      });

      await authController.checkSession();
      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentUser.value?.name, equals('Kasir Dua'));
    });
  });

  group('Sprint 02 - Auth Middleware Guards Tests', () {
    test('AuthGuard redirects unauthenticated user to login', () {
      final guard = AuthGuard();
      authController.currentUser.value = null;

      final redirect = guard.redirect('/dashboard');
      expect(redirect?.name, equals(AppRoutes.LOGIN));
    });

    test('AuthGuard allows authenticated user through', () {
      final guard = AuthGuard();
      authController.currentUser.value = const UserModel(
        id: 1,
        name: 'Kasir',
        username: 'kasir',
        roles: ['cashier'],
      );

      final redirect = guard.redirect('/dashboard');
      expect(redirect, isNull);
    });

    test('GuestGuard redirects authenticated user away from login to dashboard', () {
      final guard = GuestGuard();
      authController.currentUser.value = const UserModel(
        id: 1,
        name: 'Kasir',
        username: 'kasir',
        roles: ['cashier'],
      );

      final redirect = guard.redirect('/login');
      expect(redirect?.name, equals(AppRoutes.DASHBOARD));
    });

    test('GuestGuard allows unauthenticated user into login', () {
      final guard = GuestGuard();
      authController.currentUser.value = null;

      final redirect = guard.redirect('/login');
      expect(redirect, isNull);
    });
  });

  group('Sprint 02 - UI Widgets Tests', () {
    testWidgets('PasswordField toggles obscureText on icon tap', (tester) async {
      final controller = TextEditingController(text: 'secret123');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: PasswordField(controller: controller),
          ),
        ),
      );

      // Verify toggle button exists
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('LoginForm renders correctly with mode switch', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SingleChildScrollView(child: LoginForm()),
          ),
        ),
      );

      // Default mode: Kasir / Staff (PIN)
      expect(find.text('Kasir / Staff (PIN)'), findsOneWidget);
      expect(find.text('Username Staff'), findsOneWidget);

      // Switch to Admin / Manager mode
      await tester.tap(find.text('Admin / Manager'));
      await tester.pump();

      expect(find.text('Email Akun'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });
  });
}
