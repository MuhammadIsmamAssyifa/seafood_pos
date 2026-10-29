import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../controllers/order_adjustment_controller.dart';
import '../models/adjustment_model.dart';
import '../models/adjustment_status.dart';
import '../widgets/adjustment_card.dart';
import '../widgets/adjustment_history.dart';
import 'approval_dialog.dart';

class AdjustmentPage extends GetView<OrderAdjustmentController> {
  const AdjustmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() {
            final order = controller.activeOrder.value;
            if (order != null && order.tableNumber != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Penyesuaian Pesanan'),
                  Text(
                    'Meja ${order.tableNumber} • #${order.orderNumber}',
                    style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              );
            }
            return const Text('Penyesuaian Pesanan (Adjustment)');
          }),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Perbarui Data',
              onPressed: () => controller.loadAdjustment(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Daftar Penyesuaian'),
              Tab(text: 'Riwayat Perubahan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Adjustment List with status filters
            _buildAdjustmentsTab(context),

            // Tab 2: Adjustment History Timeline
            _buildHistoryTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentsTab(BuildContext context) {
    return Column(
      children: [
        // Filter Chips (All, Pending, Approved, Rejected)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
          ),
          child: Obx(() {
            final currentStatus = controller.filterStatus.value;
            final pendingCount = controller.pendingCount;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // All
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: currentStatus == null,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: currentStatus == null ? Colors.white : AppColors.textPrimary,
                      fontWeight: currentStatus == null ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => controller.setFilterStatus(null),
                  ),
                  const SizedBox(width: 8),

                  // Pending Customer
                  ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Menunggu Customer'),
                        if (pendingCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: currentStatus == AdjustmentStatus.pendingCustomer
                                  ? Colors.white
                                  : AppColors.warning,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              pendingCount.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: currentStatus == AdjustmentStatus.pendingCustomer
                                    ? AppColors.primary
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: currentStatus == AdjustmentStatus.pendingCustomer,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: currentStatus == AdjustmentStatus.pendingCustomer ? Colors.white : AppColors.textPrimary,
                      fontWeight: currentStatus == AdjustmentStatus.pendingCustomer ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => controller.setFilterStatus(AdjustmentStatus.pendingCustomer),
                  ),
                  const SizedBox(width: 8),

                  // Approved
                  ChoiceChip(
                    label: const Text('Disetujui'),
                    selected: currentStatus == AdjustmentStatus.approved,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: currentStatus == AdjustmentStatus.approved ? Colors.white : AppColors.textPrimary,
                      fontWeight: currentStatus == AdjustmentStatus.approved ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => controller.setFilterStatus(AdjustmentStatus.approved),
                  ),
                  const SizedBox(width: 8),

                  // Rejected
                  ChoiceChip(
                    label: const Text('Ditolak'),
                    selected: currentStatus == AdjustmentStatus.rejected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: currentStatus == AdjustmentStatus.rejected ? Colors.white : AppColors.textPrimary,
                      fontWeight: currentStatus == AdjustmentStatus.rejected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => controller.setFilterStatus(AdjustmentStatus.rejected),
                  ),
                ],
              ),
            );
          }),
        ),

        // List View
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const AppLoading(message: 'Memuat data penyesuaian pesanan...');
            }

            if (controller.errorMessage.isNotEmpty) {
              return AppErrorWidget(
                message: controller.errorMessage.value,
                onRetry: () => controller.loadAdjustment(),
              );
            }

            final items = controller.filteredAdjustments;

            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak Ada Permintaan Penyesuaian',
                        style: AppTextStyle.h3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Semua pesanan berjalan sesuai dan tidak ada perubahan dari kitchen.',
                        style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.loadAdjustment(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Obx(() {
                    return AdjustmentCard(
                      adjustment: item,
                      isProcessing: controller.isActionLoading.value,
                      onTap: () {
                        controller.selectAdjustment(item);
                        Get.toNamed(AppRoutes.ADJUSTMENT_DETAIL, arguments: item);
                      },
                      onApprove: () => _handleApprove(context, item),
                      onReject: () => _handleReject(context, item),
                    );
                  });
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const AppLoading(message: 'Memuat riwayat perubahan...');
      }

      final allAdjustments = controller.adjustments;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AdjustmentHistoryWidget(history: allAdjustments),
      );
    });
  }

  void _handleApprove(BuildContext context, AdjustmentModel item) {
    ApprovalDialog.show(
      context: context,
      adjustment: item,
      onApprove: () => controller.approveAdjustment(item.id),
      onReject: () => controller.rejectAdjustment(item.id),
    );
  }

  void _handleReject(BuildContext context, AdjustmentModel item) {
    controller.rejectAdjustment(item.id);
  }
}
