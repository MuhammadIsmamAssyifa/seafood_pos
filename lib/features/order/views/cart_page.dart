import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/services/pusher_service.dart';
import '../controllers/order_controller.dart';
import '../widgets/batch_card.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/order_status_badge.dart';
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
        // Cart Header with Realtime status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  const SizedBox(width: 8),
                  // Pusher Realtime Live Indicator
                  _buildPusherLiveIndicator(),
                ],
              ),
              Obx(() => OrderStatusBadge(status: controller.orderStatus)),
            ],
          ),
        ),

        // Batches or Items List
        Expanded(
          child: Obx(() {
            final batches = controller.batches;
            final items = controller.cartItems;

            if (items.isEmpty && batches.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
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
                        'Pilih item menu di katalog untuk menambah ke pesanan.',
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

            // Display grouped by Batch (Sprint 06 KDS Batch Flow)
            if (batches.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: batches.length,
                itemBuilder: (context, index) {
                  final batch = batches[index];
                  return Obx(() => BatchCard(
                        batch: batch,
                        isSubmitting: controller.isSubmitting.value,
                        onSubmit: batch.isWaiting
                            ? () => controller.submitBatchPrompt(context, batch)
                            : null,
                        mutatingItemId: controller.mutatingItemId.value,
                        onUpdateQty: (item, qty) => controller.updateItemQuantity(item, qty),
                        onDeleteItem: (item) => controller.confirmDeleteItem(item),
                      ));
                },
              );
            }

            // Fallback flat item list if batches are not yet created
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

        // Summary and Submit Action
        Obx(() => OrderSummaryWidget(
              subtotal: controller.subtotal,
              discount: controller.discount,
              grandTotal: controller.grandTotal,
              totalItemCount: controller.totalItemCount,
              orderStatus: controller.orderStatus,
              hasWaitingBatch: controller.hasWaitingBatch,
              waitingItemCount: controller.waitingBatch?.itemCount ?? 0,
              isSubmitting: controller.isSubmitting.value,
              onSubmitBatch: () => controller.submitBatchPrompt(context),
              onContinue: () {
                Get.snackbar(
                  'Order Diproses',
                  'Seluruh batch sudah dikirim ke dapur. Lanjutkan ke Sprint 07 untuk pembayaran.',
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Segarkan Pesanan',
              onPressed: () => controller.refreshOrder(),
            ),
          ],
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

  Widget _buildPusherLiveIndicator() {
    if (!Get.isRegistered<PusherService>()) return const SizedBox.shrink();

    final pusher = Get.find<PusherService>();
    return Obx(() {
      final isOnline = pusher.isConnected.value;
      return Tooltip(
        message: isOnline ? 'Pusher KDS: Terhubung (Real-time)' : 'Pusher KDS: Terputus',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: (isOnline ? AppColors.success : AppColors.error).withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isOnline ? AppColors.success : AppColors.error,
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'LIVE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isOnline ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
