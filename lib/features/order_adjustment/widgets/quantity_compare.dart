import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/adjustment_model.dart';
import '../models/adjustment_type.dart';

class QuantityCompareWidget extends StatelessWidget {
  final AdjustmentModel adjustment;

  const QuantityCompareWidget({
    super.key,
    required this.adjustment,
  });

  @override
  Widget build(BuildContext context) {
    final unit = adjustment.unit;

    if (adjustment.type == AdjustmentType.cancel) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withAlpha(40)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Item dibatalkan: ${AppFormatter.formatQuantity(adjustment.oldQuantity, unit)} (${AppFormatter.formatCurrency(adjustment.oldSubtotal)})',
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Old Values
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pesanan Semula',
                  style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatter.formatQuantity(adjustment.oldQuantity, unit),
                  style: AppTextStyle.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  AppFormatter.formatCurrency(adjustment.oldSubtotal),
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.textMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),

          // Arrow Indicator
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(20),
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),

          // New Values
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Perubahan Kitchen',
                  style: AppTextStyle.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatter.formatQuantity(adjustment.effectiveNewQuantity, unit),
                  style: AppTextStyle.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  AppFormatter.formatCurrency(adjustment.newSubtotal),
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

