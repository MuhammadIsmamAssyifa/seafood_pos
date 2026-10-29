import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';
import 'app_routes.dart';

/// Guard to protect routes that require authentication
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (!authController.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }
    return null;
  }
}

/// Guard to prevent authenticated users from revisiting guest pages like login
class GuestGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (authController.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.DASHBOARD);
    }
    return null;
  }
}

