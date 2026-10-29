import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  bool get isAuthenticated => currentUser.value != null;

  /// Check token & user session on app start
  Future<void> checkSession() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final hasToken = await authRepository.hasValidToken();
      if (!hasToken) {
        currentUser.value = null;
        return;
      }

      // Read cached user first for immediate offline UX
      final cachedUser = await authRepository.getCachedUser();
      if (cachedUser != null) {
        currentUser.value = cachedUser;
      }

      // Validate session with backend profile endpoint
      try {
        final profileResponse = await authRepository.getProfile();
        if (profileResponse.success && profileResponse.data != null) {
          currentUser.value = profileResponse.data;
        }
      } catch (e) {
        // If 401 Unauthorized or invalid session, clear and logout
        if (e is ApiException && e.type == ApiExceptionType.unauthorized) {
          await authRepository.logout();
          currentUser.value = null;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Entry point called by Splash screen
  Future<void> checkAuthAndNavigate() async {
    await Future.delayed(AppConstants.splashDelay);
    await checkSession();

    if (isAuthenticated) {
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  /// Login using Email and Password (Web / Admin / Owner)
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await authRepository.login(
        email: email.trim(),
        password: password,
      );

      if (response.success && response.data != null) {
        currentUser.value = response.data;
        AppHelpers.showSuccess(
          message: 'Selamat datang kembali, ${response.data!.name}',
          title: 'Login Berhasil',
        );
        Get.offAllNamed(AppRoutes.DASHBOARD);
        return true;
      } else {
        errorMessage.value = response.message;
        AppHelpers.showError(message: response.message, title: 'Login Gagal');
        return false;
      }
    } on ApiException catch (e) {
      final msg = e.firstValidationError ?? e.message;
      errorMessage.value = msg;
      AppHelpers.showError(message: msg, title: 'Login Gagal');
      return false;
    } catch (e) {
      final msg = 'Terjadi kesalahan tidak terduga: ${e.toString()}';
      errorMessage.value = msg;
      AppHelpers.showError(message: msg, title: 'Login Gagal');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Login using Staff Username and PIN (Cashier / Waiter / Kitchen)
  Future<bool> staffLogin({
    required String username,
    required String pin,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await authRepository.staffLogin(
        username: username.trim(),
        pin: pin.trim(),
      );

      if (response.success && response.data != null) {
        currentUser.value = response.data;
        AppHelpers.showSuccess(
          message: 'Halo, ${response.data!.name} (${response.data!.primaryRole.displayName})',
          title: 'Login Staff Berhasil',
        );
        Get.offAllNamed(AppRoutes.DASHBOARD);
        return true;
      } else {
        errorMessage.value = response.message;
        AppHelpers.showError(message: response.message, title: 'Login Gagal');
        return false;
      }
    } on ApiException catch (e) {
      final msg = e.firstValidationError ?? e.message;
      errorMessage.value = msg;
      AppHelpers.showError(message: msg, title: 'Login Gagal');
      return false;
    } catch (e) {
      final msg = 'Terjadi kesalahan tidak terduga: ${e.toString()}';
      errorMessage.value = msg;
      AppHelpers.showError(message: msg, title: 'Login Gagal');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout current session
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await authRepository.logout();
      AppHelpers.showInfo(
        message: 'Anda telah berhasil keluar dari sistem.',
        title: 'Logout',
      );
    } finally {
      currentUser.value = null;
      errorMessage.value = null;
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
