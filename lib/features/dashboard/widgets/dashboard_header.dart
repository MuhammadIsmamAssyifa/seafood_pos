import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/formatter.dart';
import '../controllers/dashboard_controller.dart';

class DashboardHeader extends StatelessWidget {
  final DashboardController controller;

  const DashboardHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Outlet & Restaurant Branding
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Obx(() {
              final outlet = controller.outlet.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    outlet?.restaurantName ?? 'Seafood POS',
                    style: AppTextStyle.titleLarge.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${outlet?.name ?? 'Cabang Utama'} • ${AppFormatter.formatDate(DateTime.now())}',
                    style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            }),
          ),

          // Online / Offline Status Badge
          Obx(() {
            final isOnline = connectivityService.isOnline.value;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success.withAlpha(20) : AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isOnline ? AppColors.success.withAlpha(80) : AppColors.error.withAlpha(80),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: isOnline ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: AppTextStyle.caption.copyWith(
                      color: isOnline ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Segarkan Data',
            onPressed: () => controller.loadDashboardData(),
          ),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Logout',
            onPressed: () => controller.showLogoutDialog(context),
          ),
        ],
      ),
    );
  }
}

