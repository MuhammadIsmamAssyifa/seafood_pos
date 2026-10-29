import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/adjustment_model.dart';

class ReplacementItemWidget extends StatelessWidget {
  final AdjustmentModel adjustment;

  const ReplacementItemWidget({
    super.key,
    required this.adjustment,
  });

  @override
  Widget build(BuildContext context) {
    final oldItem = adjustment.orderItem;
    final repItem = adjustment.replacementItem;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Penggantian Menu',
                style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 16),

          // Old Item
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menu Semula (Dibatalkan)',
                      style: AppTextStyle.caption.copyWith(color: AppColors.error),
                    ),
                    Text(
                      oldItem?.displayName ?? adjustment.itemName,
                      style: AppTextStyle.bodyMedium.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${AppFormatter.formatQuantity(adjustment.oldQuantity, adjustment.unit)} • ${AppFormatter.formatCurrency(adjustment.oldSubtotal)}',
                style: AppTextStyle.bodySmall.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Replacement Item
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menu Pengganti Baru',
                      style: AppTextStyle.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      repItem?.displayName ?? 'Menu Pengganti',
                      style: AppTextStyle.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                repItem != null
                    ? '${AppFormatter.formatQuantity(repItem.quantity, repItem.unit)} • ${AppFormatter.formatCurrency(repItem.subtotal)}'
                    : AppFormatter.formatCurrency(adjustment.newSubtotal),
                style: AppTextStyle.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

