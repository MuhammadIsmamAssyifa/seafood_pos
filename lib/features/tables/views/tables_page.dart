import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/widgets/app_loading.dart';
import '../controllers/table_controller.dart';
import '../models/table_status.dart';
import '../widgets/table_card.dart';

class TablesPage extends GetView<TableController> {
  const TablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manajemen Meja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Meja',
            onPressed: () => controller.refreshTables(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: (val) => controller.searchTables(val),
                  decoration: InputDecoration(
                    hintText: 'Cari nomor meja atau nama pelanggan...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Status Filter Chips
                Obx(() {
                  final currentFilter = controller.selectedStatusFilter.value;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'Semua Meja (${controller.tables.length})',
                          isSelected: currentFilter == null,
                          onSelected: () => controller.filterByStatus(null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Tersedia (${controller.tables.where((t) => t.isAvailable).length})',
                          isSelected: currentFilter == TableStatus.available,
                          color: TableStatus.available.color,
                          onSelected: () => controller.filterByStatus(TableStatus.available),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Terisi (${controller.tables.where((t) => t.isOccupied).length})',
                          isSelected: currentFilter == TableStatus.occupied,
                          color: TableStatus.occupied.color,
                          onSelected: () => controller.filterByStatus(TableStatus.occupied),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Main Table Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.tables.isEmpty) {
                return const AppLoading(message: 'Memuat status meja...');
              }

              if (controller.filteredTables.isEmpty) {
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
                            Icons.table_restaurant_outlined,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak Ada Meja',
                          style: AppTextStyle.h3,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          controller.searchQuery.value.isNotEmpty
                              ? 'Tidak ditemukan meja dengan kata kunci "${controller.searchQuery.value}".'
                              : 'Belum ada data meja pada outlet ini.',
                          style: AppTextStyle.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshTables(),
                color: AppColors.primary,
                child: GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: controller.filteredTables.length,
                  itemBuilder: (context, index) {
                    final table = controller.filteredTables[index];
                    return TableCard(
                      table: table,
                      onTap: () => controller.onTableTapped(table, context),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? color,
  }) {
    final activeColor = color ?? AppColors.primary;

    return ChoiceChip(
      label: Text(
        label,
        style: AppTextStyle.caption.copyWith(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: activeColor,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? activeColor : AppColors.border,
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }
}
