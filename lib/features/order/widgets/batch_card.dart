import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/order_batch_model.dart';
import '../models/order_item_model.dart';
import 'cart_item_card.dart';
import 'kitchen_progress.dart';
import 'order_status_badge.dart';

class BatchCard extends StatelessWidget {
  final OrderBatchModel batch;
  final bool isSubmitting;
  final VoidCallback? onSubmit;
  final Function(OrderItemModel item, double newQty)? onUpdateQty;
  final Function(OrderItemModel item)? onDeleteItem;
  final VoidCallback? onDeleteBatch;
  final int? mutatingItemId;

  const BatchCard({
    super.key,
    required this.batch,
    this.isSubmitting = false,
    this.onSubmit,
    this.onUpdateQty,
    this.onDeleteItem,
    this.onDeleteBatch,
    this.mutatingItemId,
  });

  @override
  Widget build(BuildContext context) {
    final isWaiting = batch.isWaiting;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isWaiting ? AppColors.warning.withAlpha(120) : AppColors.border,
          width: isWaiting ? 1.5 : 1,
        ),
      ),
      elevation: 0,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Batch Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: isWaiting
                ? AppColors.warning.withAlpha(20)
                : AppColors.surfaceMuted,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isWaiting ? AppColors.warning : AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        batch.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${batch.itemCount} Item',
                      style: AppTextStyle.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (batch.sentToKitchenAt != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '• ${AppFormatter.formatTime(batch.sentToKitchenAt!)}',
                        style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OrderStatusBadge(status: batch.effectiveStatus),
                    if (isWaiting && onDeleteBatch != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onDeleteBatch,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.shade200, width: 0.8),
                          ),
                          child: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Kitchen Progress Tracker (for sent/cooking/ready/served)
          if (!isWaiting)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: KitchenProgressWidget(status: batch.effectiveStatus),
            ),

          // Batch Items
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...batch.items.map((item) {
                  if (isWaiting && onUpdateQty != null && onDeleteItem != null) {
                    // Waiting batch items can be adjusted/deleted
                    return CartItemCard(
                      item: item,
                      isMutating: mutatingItemId == item.id,
                      onIncrement: () => onUpdateQty!(item, item.quantity + 1),
                      onDecrement: () => onUpdateQty!(item, item.quantity - 1),
                      onDelete: () => onDeleteItem!(item),
                    );
                  }

                  // Locked item row for submitted batch
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.displayName,
                                style: AppTextStyle.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${AppFormatter.formatCurrency(item.price)} / ${item.unit}',
                                style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border, width: 0.8),
                              ),
                              child: Text(
                                '${item.quantity.toInt()} ${item.unit}',
                                style: AppTextStyle.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              AppFormatter.formatCurrency(item.subtotal),
                              style: AppTextStyle.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                // Submit button if waiting
                if (isWaiting && onSubmit != null) ...[
                  const SizedBox(height: 6),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: isSubmitting ? null : onSubmit,
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      isSubmitting ? 'Mengirim ke Dapur...' : 'Kirim ${batch.displayName} ke Dapur',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

