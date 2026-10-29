// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/splash_page.dart';
import '../../features/dashboard/views/dashboard_page.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashPage(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      binding: AuthBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const DashboardPage(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
