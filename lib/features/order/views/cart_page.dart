import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../controllers/order_controller.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/order_summary.dart';

class OrderCartView extends GetView<OrderController> {
  final bool isStandalone;
  final VoidCallback? onBackToCatalog;

  const OrderCartView({
    super.key,
    this.isStandalone = false,
    this.onBackToCatalog,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        // Cart Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Pesanan Meja',
                    style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${controller.totalItemCount} Item',
                      style: AppTextStyle.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )),
            ],
          ),
        ),

        // Items List
        Expanded(
          child: Obx(() {
            final items = controller.cartItems;
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.remove_shopping_cart_outlined,
                          size: 48,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Keranjang Masih Kosong',
                        style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pilih item menu di sebelah kiri untuk menambah ke pesanan.',
                        style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      if (onBackToCatalog != null) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: onBackToCatalog,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(140, 42),
                          ),
                          icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
                          label: const Text('Buka Menu'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Obx(() {
                  final isItemMutating = controller.mutatingItemId.value == item.id;
                  return CartItemCard(
                    item: item,
                    isMutating: isItemMutating,
                    onIncrement: () => controller.updateItemQuantity(item, item.quantity + 1),
                    onDecrement: () => controller.updateItemQuantity(item, item.quantity - 1),
                    onDelete: () => controller.confirmDeleteItem(item),
                  );
                });
              },
            );
          }),
        ),

        // Summary and Checkout/Continue Action
        Obx(() => OrderSummaryWidget(
              subtotal: controller.subtotal,
              discount: controller.discount,
              grandTotal: controller.grandTotal,
              totalItemCount: controller.totalItemCount,
              isDraft: controller.isOrderDraft,
              onContinue: () {
                Get.snackbar(
                  'Order Draft Tersimpan',
                  'Seluruh item sudah tersimpan di backend. Lanjutkan ke Sprint 06 (KDS & Submit Kitchen).',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              },
            )),
      ],
    );

    if (isStandalone) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Obx(() => Text(
                controller.tableNumber.value.isNotEmpty
                    ? 'Pesanan Meja ${controller.tableNumber.value}'
                    : 'Pesanan Aktif',
              )),
        ),
        body: content,
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(left: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: content,
    );
  }
}

