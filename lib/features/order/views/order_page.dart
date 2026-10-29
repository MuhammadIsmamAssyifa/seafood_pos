import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/widgets/app_loading.dart';
import '../controllers/order_controller.dart';
import 'cart_page.dart';
import 'menu_page.dart';

class OrderPage extends GetView<OrderController> {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() {
          final tbl = controller.tableNumber.value;
          final title = tbl.isNotEmpty ? 'Order Meja $tbl' : 'Menu & Order';
          return Text(title);
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: () => controller.refreshOrder(),
          ),
          // Cart shortcut for compact screens
          Obx(() {
            if (controller.totalItemCount == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Badge.count(
                  count: controller.totalItemCount,
                  backgroundColor: AppColors.secondary,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                tooltip: 'Lihat Keranjang',
                onPressed: () => _openCartBottomSheet(context),
              ),
            );
          }),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= 800;

          return Obx(() {
            if (controller.isLoading.value && controller.menus.isEmpty) {
              return const AppLoading(message: 'Memuat data pesanan...');
            }

            if (isWideScreen) {
              // POS Split View (Menu Grid on left, Cart on right)
              return Row(
                children: [
                  const Expanded(
                    flex: 65,
                    child: OrderMenuCatalogView(),
                  ),
                  Expanded(
                    flex: 35,
                    child: OrderCartView(
                      onBackToCatalog: () {},
                    ),
                  ),
                ],
              );
            }

            // Compact View (Menu Catalog + Bottom Cart Bar)
            return Column(
              children: [
                const Expanded(
                  child: OrderMenuCatalogView(),
                ),
                _buildCompactBottomCartBar(context),
              ],
            );
          });
        },
      ),
    );
  }

  /// Compact bottom cart bar for mobile / smaller screens
  Widget _buildCompactBottomCartBar(BuildContext context) {
    return Obx(() {
      final count = controller.totalItemCount;
      if (count == 0) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Badge & Items info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$count Item',
                      style: AppTextStyle.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Total info
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pesanan',
                      style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      AppFormatter.formatCurrency(controller.grandTotal),
                      style: AppTextStyle.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // View Cart Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _openCartBottomSheet(context),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _openCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          clipBehavior: Clip.antiAlias,
          child: OrderCartView(
            onBackToCatalog: () => Navigator.pop(ctx),
          ),
        );
      },
    );
  }
}
