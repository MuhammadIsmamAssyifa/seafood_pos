import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/widgets/app_loading.dart';
import '../controllers/order_controller.dart';
import '../models/menu_model.dart';
import '../widgets/category_chip.dart';
import '../widgets/menu_card.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/search_bar.dart';
import '../widgets/variant_selection_dialog.dart';

class OrderMenuCatalogView extends GetView<OrderController> {
  final bool showHeader;

  const OrderMenuCatalogView({
    super.key,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table & Customer Header
        if (showHeader) _buildHeaderContext(),

        // Search & Category Section
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Obx(() => OrderSearchBar(
                    initialValue: controller.searchQuery.value,
                    onChanged: (val) => controller.searchMenu(val),
                    onClear: () => controller.clearSearch(),
                  )),
              const SizedBox(height: 12),

              // Categories Chips
              Obx(() {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.categories.map((cat) {
                      final isSelected = controller.selectedCategoryId.value.toLowerCase() == cat.id.toLowerCase();
                      return CategoryChip(
                        category: cat,
                        isSelected: isSelected,
                        onTap: () => controller.setCategory(cat.id),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),

        const Divider(height: 1, thickness: 1, color: AppColors.border),

        // Menu Grid
        Expanded(
          child: Obx(() {
            if (controller.isLoadingMenu.value && controller.menus.isEmpty) {
              return const AppLoading(message: 'Memuat katalog menu...');
            }

            if (controller.filteredMenus.isEmpty) {
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
                          Icons.search_off_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Menu Tidak Ditemukan',
                        style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'Tidak ada menu dengan kata kunci "${controller.searchQuery.value}".'
                            : 'Belum ada menu untuk kategori ini.',
                        style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      if (controller.searchQuery.value.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: () => controller.clearSearch(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(140, 40),
                          ),
                          child: const Text('Reset Pencarian'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.refreshOrder(),
              color: AppColors.primary,
              child: GridView.builder(
                padding: const EdgeInsets.all(14),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: 175,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.filteredMenus.length,
                itemBuilder: (context, index) {
                  final menu = controller.filteredMenus[index];
                  return Obx(() {
                    final qtyInCart = controller.getMenuQuantityInCart(menu);
                    return OrderMenuCard(
                      menu: menu,
                      cartQuantity: qtyInCart,
                      isLoading: controller.isCartMutating.value,
                      onAdd: () => _handleMenuTap(context, menu),
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

  /// Header with Table and Customer Context
  Widget _buildHeaderContext() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Obx(() {
        final tableNum = controller.tableNumber.value.isNotEmpty
            ? 'Meja ${controller.tableNumber.value}'
            : (controller.order.value?.tableNumber != null
                ? 'Meja ${controller.order.value!.tableNumber}'
                : 'Pilih Meja');
        final custName = controller.customerName.value.isNotEmpty
            ? controller.customerName.value
            : (controller.order.value?.customerName ?? '-');
        final guests = '${controller.guestCount.value} Orang';
        final orderNum = controller.order.value?.orderNumber ?? (controller.orderId.value != null ? '#ORD-${controller.orderId.value}' : '-');

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.table_restaurant_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          tableNum,
                          style: AppTextStyle.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            orderNum,
                            style: AppTextStyle.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pelanggan: $custName • $guests',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OrderStatusBadge(status: controller.orderStatus),
          ],
        );
      }),
    );
  }

  void _handleMenuTap(BuildContext context, MenuModel menu) {
    if (menu.variants.isEmpty) {
      Get.snackbar('Perhatian', 'Menu tidak memiliki varian aktif');
      return;
    }

    if (menu.variants.length == 1) {
      // Direct add primary variant
      controller.addItem(menu.variants.first, quantity: 1.0);
    } else {
      // Multi-variant dialog
      VariantSelectionDialog.show(
        context: context,
        menu: menu,
        onSelect: (variant, quantity) {
          controller.addItem(variant, quantity: quantity);
        },
      );
    }
  }
}

