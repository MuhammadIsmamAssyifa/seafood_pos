import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;

  bool get isLoggedIn => currentUser.value != null;

  /// Check token & user session on app start (Splash screen logic)
  Future<void> checkAuthAndNavigate() async {
    // Artificial splash delay for smooth branding experience
    await Future.delayed(AppConstants.splashDelay);

    try {
      final hasToken = await authRepository.hasValidToken();
      if (!hasToken) {
        Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }

      // Check cached user first
      final cachedUser = await authRepository.getCachedUser();
      if (cachedUser != null) {
        currentUser.value = cachedUser;
      }

      // Verify token with backend
      try {
        final profileResponse = await authRepository.getProfile();
        if (profileResponse.success && profileResponse.data != null) {
          currentUser.value = profileResponse.data;
        }
      } catch (_) {
        // If profile fetch fails but token exists, fallback to cached user or login
        if (currentUser.value == null) {
          Get.offAllNamed(AppRoutes.LOGIN);
          return;
        }
      }

      // Token is valid -> redirect to dashboard
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } catch (_) {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await authRepository.logout();
    } finally {
      currentUser.value = null;
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
