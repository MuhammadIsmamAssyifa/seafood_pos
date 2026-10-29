import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/helpers.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_model.dart';
import '../models/dashboard_menu_item.dart';
import '../models/outlet_model.dart';
import '../repositories/dashboard_repository.dart';
import '../widgets/logout_dialog.dart';

class DashboardController extends GetxController {
  final DashboardRepository dashboardRepository;

  DashboardController({required this.dashboardRepository});

  final Rxn<UserModel> user = Rxn<UserModel>();
  final Rxn<OutletModel> outlet = Rxn<OutletModel>();
  final RxList<DashboardMenuItem> menuList = <DashboardMenuItem>[].obs;
  final RxBool isLoading = false.obs;

  late final ConnectivityService _connectivityService;

  bool get isOnline => _connectivityService.isOnline.value;

  @override
  void onInit() {
    super.onInit();
    _connectivityService = Get.find<ConnectivityService>();
    _initShortcutMenus();
    loadDashboardData();
  }

  void _initShortcutMenus() {
    menuList.assignAll([
      const DashboardMenuItem(
        id: 'order',
        title: 'Order Baru',
        subtitle: 'Buat pesanan & kasir',
        icon: Icons.add_shopping_cart_rounded,
        color: AppColors.primary,
        route: AppRoutes.ORDER,
        badge: 'Utama',
      ),
      const DashboardMenuItem(
        id: 'tables',
        title: 'Daftar Meja',
        subtitle: 'Status & layout meja',
        icon: Icons.table_restaurant_rounded,
        color: Color(0xFF0284C7), // Sky Blue
        route: AppRoutes.TABLES,
        badge: 'Sprint 04',
      ),
      const DashboardMenuItem(
        id: 'history',
        title: 'Riwayat Order',
        subtitle: 'Laporan transaksi kasir',
        icon: Icons.receipt_long_rounded,
        color: Color(0xFF0D9488), // Teal
        route: AppRoutes.HISTORY,
        badge: 'Sprint 11',
      ),
      const DashboardMenuItem(
        id: 'menu',
        title: 'Katalog Menu',
        subtitle: 'Daftar hidangan & harga',
        icon: Icons.restaurant_menu_rounded,
        color: Color(0xFFD97706), // Amber
        route: AppRoutes.MENU,
        badge: 'Sprint 06',
      ),
      const DashboardMenuItem(
        id: 'kitchen',
        title: 'Dapur (KDS)',
        subtitle: 'Monitor antrean pesanan',
        icon: Icons.kitchen_rounded,
        color: Color(0xFF7C3AED), // Purple
        route: AppRoutes.KITCHEN,
        badge: 'KDS',
      ),
      const DashboardMenuItem(
        id: 'adjustment',
        title: 'Penyesuaian (Adjustment)',
        subtitle: 'Konfirmasi perubahan',
        icon: Icons.rule_rounded,
        color: Color(0xFFE11D48), // Rose
        route: AppRoutes.ADJUSTMENT,
        badge: 'Sprint 08',
      ),
      const DashboardMenuItem(
        id: 'profile',
        title: 'Profil Kasir',
        subtitle: 'Informasi akun & shift',
        icon: Icons.account_circle_rounded,
        color: Color(0xFF475569), // Slate
        route: AppRoutes.PROFILE,
      ),
    ]);
  }

  /// Load user profile and outlet info
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      // 1. Get User Profile
      final profileResponse = await dashboardRepository.getUserProfile();
      if (profileResponse.success && profileResponse.data != null) {
        user.value = profileResponse.data;
        // Keep global AuthController user in sync
        if (Get.isRegistered<AuthController>()) {
          Get.find<AuthController>().currentUser.value = profileResponse.data;
        }
      }

      // 2. Get Outlet Information
      final outletInfo = await dashboardRepository.getOutletInfo();
      outlet.value = outletInfo;
    } catch (_) {
      // If profile request fails, check if user session already in AuthController
      if (Get.isRegistered<AuthController>()) {
        user.value = Get.find<AuthController>().currentUser.value;
      }
      outlet.value = OutletModel.defaultOutlet();
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to shortcut page
  void navigateTo(DashboardMenuItem item) {
    if (!item.isEnabled) {
      AppHelpers.showInfo(
        message: '${item.title} sedang dalam pengembangan (${item.badge ?? ''})',
        title: 'Segera Hadir',
      );
      return;
    }
    Get.toNamed(item.route);
  }

  /// Show logout confirmation dialog
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LogoutDialog(
        onConfirm: () {
          Navigator.of(context).pop();
          logout();
        },
      ),
    );
  }

  /// Execute logout
  Future<void> logout() async {
    if (Get.isRegistered<AuthController>()) {
      await Get.find<AuthController>().logout();
    } else {
      await dashboardRepository.logout();
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}

