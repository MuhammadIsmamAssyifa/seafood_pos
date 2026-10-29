import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/widgets/app_error.dart';
import '../controllers/inventory_controller.dart';
import '../models/stock_status.dart';
import '../widgets/stock_information_tile.dart';

class StockInformationPage extends GetView<InventoryController> {
  const StockInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Informasi Stok Menu'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Stok',
            onPressed: () => controller.refreshInventory(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.stockInfo.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value != null && controller.stockInfo.isEmpty) {
          return AppErrorWidget(
            message: controller.errorMessage.value!,
            onRetry: () => controller.refreshInventory(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshInventory(),
          child: Column(
            children: [
              // Summary Metrics Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.surface,
                child: Row(
                  children: [
                    _buildMetricCard(
                      label: 'Menipis',
                      count: controller.lowStockCount,
                      color: const Color(0xFFF59E0B),
                      status: StockStatus.lowStock,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricCard(
                      label: 'Cek Pasar',
                      count: controller.needMarketCheckCount,
                      color: const Color(0xFF3B82F6),
                      status: StockStatus.needMarketCheck,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricCard(
                      label: 'Habis',
                      count: controller.outOfStockCount,
                      color: const Color(0xFFEF4444),
                      status: StockStatus.outOfStock,
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: 'Cari nama menu / bahan...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => controller.searchQuery.value = '',
                          )
                        : const SizedBox.shrink()),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    _buildFilterChip('Semua', null),
                    const SizedBox(width: 6),
                    _buildFilterChip('Tersedia', StockStatus.available),
                    const SizedBox(width: 6),
                    _buildFilterChip('Stok Menipis', StockStatus.lowStock),
                    const SizedBox(width: 6),
                    _buildFilterChip('Perlu Cek Pasar', StockStatus.needMarketCheck),
                    const SizedBox(width: 6),
                    _buildFilterChip('Habis', StockStatus.outOfStock),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Items List
              Expanded(
                child: Builder(
                  builder: (context) {
                    final items = controller.filteredStockInfo;
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
                                  Icons.inventory_2_outlined,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum Ada Informasi Stok',
                                style: AppTextStyle.h3,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tidak ada data stok yang sesuai dengan filter atau pencarian Anda.',
                                style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return StockInformationTile(
                          stockInfo: item,
                          onTap: () {
                            if (item.stockStatus != StockStatus.available) {
                              controller.showStockWarning(
                                item.stockStatus,
                                menuName: item.variantName ?? item.menuName,
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required int count,
    required Color color,
    required StockStatus status,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (controller.filterStatus.value == status) {
            controller.filterStatus.value = null;
          } else {
            controller.filterStatus.value = status;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: controller.filterStatus.value == status ? color : color.withAlpha(50),
              width: controller.filterStatus.value == status ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count',
                style: AppTextStyle.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, StockStatus? status) {
    final isSelected = controller.filterStatus.value == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          controller.filterStatus.value = status;
        } else if (isSelected) {
          controller.filterStatus.value = null;
        }
      },
    );
  }
}
