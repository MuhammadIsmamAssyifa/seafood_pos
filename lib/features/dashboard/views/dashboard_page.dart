import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/widgets/app_loading.dart';
import '../../release/controllers/release_controller.dart';
import '../../release/widgets/offline_banner.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/menu_card.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Dashboard Header
            DashboardHeader(controller: controller),

            // Offline Connectivity Banner
            if (Get.isRegistered<ReleaseController>())
              Obx(() {
                final releaseCtrl = Get.find<ReleaseController>();
                if (!releaseCtrl.isConnected.value) {
                  return OfflineBanner(
                    onRetry: () => releaseCtrl.refreshAll(),
                  );
                }
                return const SizedBox.shrink();
              }),

            // Content Area
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.user.value == null) {
                  return const AppLoading(message: 'Memuat data dashboard...');
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadDashboardData(),
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menu Utama POS',
                              style: AppTextStyle.h3.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Pilih modul operasional',
                              style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Responsive Grid of Shortcut Menus
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            mainAxisExtent: 135,
                          ),
                          itemCount: controller.menuList.length,
                          itemBuilder: (context, index) {
                            final item = controller.menuList[index];
                            return MenuCard(
                              item: item,
                              onTap: () => controller.navigateTo(item),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
