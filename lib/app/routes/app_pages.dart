// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/splash_page.dart';
import '../../features/dashboard/bindings/dashboard_binding.dart';
import '../../features/dashboard/views/dashboard_page.dart';
import '../../features/history/views/history_page.dart';
import '../../features/kitchen/views/kitchen_page.dart';
import '../../features/menu/views/menu_page.dart';
import '../../features/order/bindings/order_binding.dart';
import '../../features/order/views/order_page.dart';
import '../../features/order_adjustment/bindings/order_adjustment_binding.dart';
import '../../features/order_adjustment/views/adjustment_detail_page.dart';
import '../../features/order_adjustment/views/adjustment_page.dart';
import '../../features/payment/bindings/payment_binding.dart';
import '../../features/payment/views/payment_page.dart';
import '../../features/payment/views/payment_success_page.dart';
import '../../features/profile/views/profile_page.dart';
import '../../features/tables/bindings/table_binding.dart';
import '../../features/tables/views/tables_page.dart';
import 'app_routes.dart';
import 'auth_middleware.dart';

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
      middlewares: [GuestGuard()],
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.TABLES,
      page: () => const TablesPage(),
      binding: TableBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ORDER,
      page: () => const OrderPage(),
      binding: OrderBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.HISTORY,
      page: () => const HistoryPage(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.MENU,
      page: () => const MenuPage(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.KITCHEN,
      page: () => const KitchenPage(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfilePage(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PAYMENT,
      page: () => const PaymentPage(),
      binding: PaymentBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PAYMENT_SUCCESS,
      page: () => const PaymentSuccessPage(),
      middlewares: [AuthGuard()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.ADJUSTMENT,
      page: () => const AdjustmentPage(),
      binding: OrderAdjustmentBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.ADJUSTMENT_DETAIL,
      page: () => const AdjustmentDetailPage(),
      binding: OrderAdjustmentBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
  ];
}
