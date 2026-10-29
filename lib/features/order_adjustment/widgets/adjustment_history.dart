import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/adjustment_model.dart';
import 'adjustment_status_badge.dart';

class AdjustmentHistoryWidget extends StatelessWidget {
  final List<AdjustmentModel> history;

  const AdjustmentHistoryWidget({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history_rounded, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 8),
              Text(
                'Belum Ada Riwayat Perubahan',
                style: AppTextStyle.titleSmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Semua perubahan ukuran, quantity, dan penggantian menu akan tercatat di sini.',
                textAlign: TextAlign.center,
                style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = history[index];
        final timeStr = item.createdAt != null ? AppFormatter.formatTime(item.createdAt!) : '-';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  timeStr,
                  style: AppTextStyle.caption.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),

              // Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.type.label}: ${item.reason}',
                      style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppFormatter.formatQuantity(item.oldQuantity, item.unit)} ➔ ${AppFormatter.formatQuantity(item.effectiveNewQuantity, item.unit)}',
                      style: AppTextStyle.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status
              AdjustmentStatusBadge(status: item.status, isCompact: true),
            ],
          ),
        );
      },
    );
  }
}

