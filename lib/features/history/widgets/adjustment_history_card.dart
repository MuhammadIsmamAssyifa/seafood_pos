import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../order_adjustment/models/adjustment_model.dart';
import '../../order_adjustment/models/adjustment_type.dart';
import '../../order_adjustment/widgets/adjustment_status_badge.dart';

class AdjustmentHistoryCard extends StatelessWidget {
  final List<AdjustmentModel> adjustments;

  const AdjustmentHistoryCard({
    super.key,
    required this.adjustments,
  });

  @override
  Widget build(BuildContext context) {
    if (adjustments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Text(
              'Tidak ada riwayat penyesuaian pesanan.',
              style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Riwayat Penyesuaian (${adjustments.length})',
                style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: adjustments.length,
            separatorBuilder: (_, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final a = adjustments[index];
              final timeStr = a.createdAt != null
                  ? AppFormatter.formatDateTime(a.createdAt!)
                  : '-';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        a.itemName,
                        style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AdjustmentStatusBadge(status: a.status, isCompact: true),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeStr,
                    style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),

                  // Detail comparison or replacement
                  if (a.type == AdjustmentType.replace) ...[
                    Text(
                      'Diganti menu: ${a.replacementItem?.displayName ?? 'Menu Pengganti'}',
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else if (a.type == AdjustmentType.cancel) ...[
                    Text(
                      'Item dibatalkan: ${AppFormatter.formatQuantity(a.oldQuantity, a.unit)} (${AppFormatter.formatCurrency(a.oldSubtotal)})',
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '${AppFormatter.formatQuantity(a.oldQuantity, a.unit)} (${AppFormatter.formatCurrency(a.oldSubtotal)})  ➔  ${AppFormatter.formatQuantity(a.effectiveNewQuantity, a.unit)} (${AppFormatter.formatCurrency(a.newSubtotal)})',
                      style: AppTextStyle.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],

                  if (a.reason.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Alasan: ${a.reason}',
                      style: AppTextStyle.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

