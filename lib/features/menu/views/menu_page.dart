import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/widgets/app_error.dart';
import '../../inventory/models/stock_status.dart';
import '../../inventory/widgets/stock_badge.dart';
import '../../order/models/menu_model.dart';
import '../controllers/menu_catalog_controller.dart';

class MenuPage extends GetView<MenuCatalogController> {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Katalog Menu & Stok'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Menu',
            onPressed: () => controller.refreshMenus(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.menus.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value != null && controller.menus.isEmpty) {
          return AppErrorWidget(
            message: controller.errorMessage.value!,
            onRetry: () => controller.refreshMenus(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshMenus(),
          child: Column(
            children: [
              // 1. Stock Status Summary Metrics
              _buildMetricsHeader(),

              // 2. Search & Category Filter Section
              _buildSearchAndFilters(),

              // 3. Menu List
              Expanded(
                child: _buildMenuList(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetricsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          _buildMetricChip(
            label: 'Menipis',
            count: controller.lowStockCount,
            color: const Color(0xFFF59E0B),
            status: StockStatus.lowStock,
          ),
          const SizedBox(width: 8),
          _buildMetricChip(
            label: 'Cek Pasar',
            count: controller.needMarketCheckCount,
            color: const Color(0xFF3B82F6),
            status: StockStatus.needMarketCheck,
          ),
          const SizedBox(width: 8),
          _buildMetricChip(
            label: 'Habis',
            count: controller.outOfStockCount,
            color: const Color(0xFFEF4444),
            status: StockStatus.outOfStock,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required int count,
    required Color color,
    required StockStatus status,
  }) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedStockFilter.value == status;
        return InkWell(
          onTap: () => controller.toggleStockFilter(status),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(40) : color.withAlpha(18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? color : color.withAlpha(50),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search input
          TextField(
            onChanged: (val) => controller.searchQuery.value = val,
            decoration: InputDecoration(
              hintText: 'Cari nama hidangan, saus, atau bahan...',
              prefixIcon: const Icon(Icons.search_rounded, size: 22),
              suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () => controller.searchQuery.value = '',
                    )
                  : const SizedBox.shrink()),
              filled: true,
              fillColor: AppColors.background,
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
          const SizedBox(height: 10),

          // Category Pills
          Obx(() {
            final types = controller.availableTypes;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: types.map((type) {
                  final isSelected = controller.selectedType.value == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(controller.getTypeLabel(type)),
                      selected: isSelected,
                      onSelected: (_) => controller.selectedType.value = type,
                      selectedColor: AppColors.primary.withAlpha(30),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    return Obx(() {
      final menus = controller.filteredMenus;

      if (menus.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.textSecondary.withAlpha(100),
              ),
              const SizedBox(height: 12),
              Text(
                'Tidak ada menu yang sesuai',
                style: AppTextStyle.h3.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                'Coba ubah kata kunci atau filter status stok',
                style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: menus.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final menu = menus[index];
          return _buildMenuCard(menu);
        },
      );
    });
  }

  Widget _buildMenuCard(MenuModel menu) {
    final iconData = menu.type.toLowerCase() == 'seafood'
        ? Icons.set_meal_rounded
        : menu.type.toLowerCase() == 'beverage'
            ? Icons.local_drink_rounded
            : Icons.restaurant_rounded;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon, Menu Name, Category & Overall Stock Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(iconData, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.name,
                        style: AppTextStyle.h3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.getTypeLabel(menu.type),
                        style: AppTextStyle.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Overall Stock Badge
                StockBadge(
                  status: menu.stockStatus,
                  quantity: menu.stockQuantity,
                  isCompact: true,
                ),
              ],
            ),

            if (menu.variants.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: AppColors.border.withAlpha(120)),
              const SizedBox(height: 8),

              // Title Varian / Saus
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Varian Saus / Olahan (${menu.variants.length}):',
                  style: AppTextStyle.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              // Variants List
              ...menu.variants.map((v) => _buildVariantRow(v)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVariantRow(MenuVariantModel variant) {
    final unit = variant.salesUnit == 'gram' || variant.salesUnit == 'kg'
        ? '/ ${variant.salesUnit}'
        : '/ porsi';

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withAlpha(80)),
      ),
      child: Row(
        children: [
          // Variant Name & cooking method/station
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.name,
                  style: AppTextStyle.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (variant.cookingMethod != null || variant.station != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [variant.cookingMethod, variant.station]
                        .where((e) => e != null && e.isNotEmpty)
                        .join(' • '),
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${AppFormatter.formatCurrency(variant.price)} $unit',
              style: AppTextStyle.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),

          // Variant Stock Badge
          StockBadge(
            status: variant.stockStatus,
            quantity: variant.stockQuantity,
            salesUnit: variant.salesUnit,
            isCompact: true,
          ),
        ],
      ),
    );
  }
}
