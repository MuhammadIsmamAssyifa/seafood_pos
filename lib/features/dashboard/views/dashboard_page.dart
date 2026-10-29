import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/widgets/app_loading.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/menu_card.dart';
import '../widgets/user_card.dart';

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
                        // User & Outlet Information Card
                        UserCard(
                          user: controller.user.value,
                          outlet: controller.outlet.value,
                        ),
                        const SizedBox(height: 24),

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
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
                            final aspectRatio = constraints.maxWidth > 700 ? 1.4 : 1.25;

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: aspectRatio,
                              ),
                              itemCount: controller.menuList.length,
                              itemBuilder: (context, index) {
                                final item = controller.menuList[index];
                                return MenuCard(
                                  item: item,
                                  onTap: () => controller.navigateTo(item),
                                );
                              },
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
