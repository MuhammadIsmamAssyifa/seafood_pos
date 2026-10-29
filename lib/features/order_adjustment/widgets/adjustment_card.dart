import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/adjustment_model.dart';
import '../models/adjustment_type.dart';
import 'adjustment_status_badge.dart';
import 'quantity_compare.dart';
import 'replacement_item.dart';

class AdjustmentCard extends StatelessWidget {
  final AdjustmentModel adjustment;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isProcessing;

  const AdjustmentCard({
    super.key,
    required this.adjustment,
    this.onTap,
    this.onApprove,
    this.onReject,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = adjustment.createdAt != null
        ? AppFormatter.formatTime(adjustment.createdAt!)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: adjustment.isPending ? AppColors.warning.withAlpha(120) : AppColors.border,
          width: adjustment.isPending ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Item Name, Time & Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            adjustment.itemName,
                            style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  adjustment.type.label,
                                  style: AppTextStyle.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (timeStr.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '•  $timeStr',
                                  style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    AdjustmentStatusBadge(status: adjustment.status),
                  ],
                ),

                const SizedBox(height: 10),

                // Reason from Kitchen
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          adjustment.reason.isNotEmpty ? adjustment.reason : 'Tidak ada alasan khusus',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Comparison or Replacement
                if (adjustment.type == AdjustmentType.replace)
                  ReplacementItemWidget(adjustment: adjustment)
                else
                  QuantityCompareWidget(adjustment: adjustment),

                // Action Buttons for Pending Status
                if (adjustment.isPending) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Reject Button
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: isProcessing ? null : onReject,
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Approve Button
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: isProcessing ? null : onApprove,
                          icon: isProcessing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Setujui'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

