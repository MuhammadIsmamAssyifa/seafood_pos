import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/formatter.dart';
import '../../auth/controllers/auth_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final connectivityService = Get.find<ConnectivityService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: connectivityService.isOnline.value
                    ? AppColors.success.withAlpha(25)
                    : AppColors.error.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: connectivityService.isOnline.value
                      ? AppColors.success
                      : AppColors.error,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: connectivityService.isOnline.value
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    connectivityService.isOnline.value ? 'Online' : 'Offline',
                    style: AppTextStyle.caption.copyWith(
                      color: connectivityService.isOnline.value
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Logout',
            onPressed: () {
              authController.logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary.withAlpha(30),
                        child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authController.currentUser.value?.name ?? 'Kasir Restoran',
                              style: AppTextStyle.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${authController.currentUser.value?.primaryRole.displayName ?? 'Staff'} • ${authController.currentUser.value?.email ?? authController.currentUser.value?.username ?? ''}',
                              style: AppTextStyle.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Shift Aktif • ${AppFormatter.formatDate(DateTime.now())}',
                              style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Menu Utama',
                style: AppTextStyle.h3,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildModuleCard(
                      icon: Icons.table_restaurant_rounded,
                      title: 'Manajemen Meja',
                      subtitle: 'Sprint 04',
                      color: Colors.blue,
                    ),
                    _buildModuleCard(
                      icon: Icons.restaurant_menu_rounded,
                      title: 'Katalog Menu',
                      subtitle: 'Sprint 06',
                      color: Colors.orange,
                    ),
                    _buildModuleCard(
                      icon: Icons.shopping_cart_checkout_rounded,
                      title: 'Order & Cart',
                      subtitle: 'Sprint 05 & 07',
                      color: Colors.green,
                    ),
                    _buildModuleCard(
                      icon: Icons.kitchen_rounded,
                      title: 'Dapur (KDS)',
                      subtitle: 'Sprint 08',
                      color: Colors.deepPurple,
                    ),
                    _buildModuleCard(
                      icon: Icons.payment_rounded,
                      title: 'Pembayaran',
                      subtitle: 'Sprint 10',
                      color: Colors.teal,
                    ),
                    _buildModuleCard(
                      icon: Icons.history_rounded,
                      title: 'Riwayat Transaksi',
                      subtitle: 'Sprint 11',
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          Get.snackbar(
            title,
            'Modul ini akan dibuka pada $subtitle',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyle.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
