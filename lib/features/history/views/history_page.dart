import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../controllers/history_controller.dart';
import '../models/history_order_model.dart';
import '../widgets/date_filter.dart';
import '../widgets/order_history_card.dart';
import '../widgets/search_box.dart';
import 'history_filter_sheet.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        centerTitle: false,
        actions: [
          // Filter Button with active indicator
          Obx(() {
            final hasFilter = controller.filter.value.hasActiveFilter;
            return IconButton(
              icon: Badge(
                isLabelVisible: hasFilter,
                child: const Icon(Icons.filter_list_rounded),
              ),
              tooltip: 'Filter Transaksi',
              onPressed: () {
                HistoryFilterSheet.show(
                  context: context,
                  currentFilter: controller.filter.value,
                  onApply: (f) => controller.applyFilter(f),
                );
              },
            );
          }),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: () => controller.loadHistory(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar & Filter Summary Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.surface,
            child: Column(
              children: [
                HistorySearchBox(
                  initialValue: controller.searchText.value,
                  onChanged: (q) => controller.onSearchChanged(q),
                  onClear: () => controller.clearSearch(),
                ),
                const SizedBox(height: 10),
                Obx(() => DateFilterChips(
                      selectedRange: controller.filter.value.dateRange,
                      onSelected: (range) => controller.setDateRangeFilter(range),
                      onPickCustomDate: () {
                        HistoryFilterSheet.show(
                          context: context,
                          currentFilter: controller.filter.value,
                          onApply: (f) => controller.applyFilter(f),
                        );
                      },
                    )),
              ],
            ),
          ),

          // 2. Summary Bar (Total Transaksi & Revenue)
          Obx(() {
            final s = controller.summary;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.8),
                  bottom: BorderSide(color: AppColors.border, width: 0.8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '${s.totalOrders} Transaksi',
                        style: AppTextStyle.caption.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (s.completedCount > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '(${s.completedCount} Selesai)',
                          style: AppTextStyle.caption.copyWith(color: AppColors.success),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'Total: ${AppFormatter.formatCurrency(s.totalRevenue)}',
                    style: AppTextStyle.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),

          // 3. Transactions List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.orders.isEmpty) {
                return const AppLoading(message: 'Memuat riwayat transaksi...');
              }

              if (controller.errorMessage.isNotEmpty && controller.orders.isEmpty) {
                return AppErrorWidget(
                  message: controller.errorMessage.value,
                  onRetry: () => controller.loadHistory(),
                );
              }

              final list = controller.orders;

              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum Ada Transaksi',
                          style: AppTextStyle.h3,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          controller.filter.value.hasActiveFilter
                              ? 'Tidak ada transaksi yang cocok dengan filter yang dipilih.'
                              : 'Semua transaksi yang selesai atau berlangsung akan tampil di sini.',
                          style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        if (controller.filter.value.hasActiveFilter) ...[
                          const SizedBox(height: 14),
                          OutlinedButton(
                            onPressed: () => controller.resetFilter(),
                            child: const Text('Reset Filter'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadHistory(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                      controller.loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length + (controller.hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == list.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final HistoryOrderModel order = list[index];
                      return OrderHistoryCard(
                        order: order,
                        onTap: () {
                          controller.selectOrder(order);
                          Get.toNamed(AppRoutes.HISTORY_DETAIL, arguments: order);
                        },
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
