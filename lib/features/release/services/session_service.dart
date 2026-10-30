import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/helpers.dart';
import '../../auth/controllers/auth_controller.dart';

class SessionService extends GetxService {
  final SecureStorageService storageService;
  final RxBool isSessionExpired = false.obs;
  bool _isHandlingExpiry = false;

  SessionService({required this.storageService});

  /// Check whether the current session has a valid stored token
  Future<bool> isSessionValid() async {
    final token = await storageService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Handle 401 Unauthorized or expired token
  Future<void> handleSessionExpired() async {
    if (_isHandlingExpiry) return;
    _isHandlingExpiry = true;
    isSessionExpired.value = true;

    try {
      // Clear all stored credentials and token
      await storageService.deleteToken();
      await storageService.clearAll();

      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        authController.currentUser.value = null;
      }

      AppHelpers.showWarning(
        message: 'Sesi Anda telah berakhir. Silakan login kembali.',
        title: 'Sesi Berakhir',
      );

      // Redirect immediately to login screen if navigator is active
      if (Get.key.currentState != null && Get.currentRoute != AppRoutes.LOGIN) {
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isHandlingExpiry = false;
      });
    }
  }

  /// Reset session state after successful login
  void resetSession() {
    isSessionExpired.value = false;
    _isHandlingExpiry = false;
  }
}
