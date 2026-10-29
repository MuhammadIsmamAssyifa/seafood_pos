import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/payment_summary_model.dart';

class PaymentChart extends StatelessWidget {
  final PaymentSummaryModel paymentSummary;

  const PaymentChart({
    super.key,
    required this.paymentSummary,
  });

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return const Color(0xFF10B981); // Emerald
      case 'transfer':
        return const Color(0xFF3B82F6); // Blue
      case 'qris':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF8B5CF6); // Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = paymentSummary.methodBreakdown;
    final total = paymentSummary.totalCollected;

    if (breakdown.isEmpty || total <= 0) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Text(
          'Belum ada data transaksi pembayaran pada periode ini.',
          style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Komposisi Metode Pembayaran',
                style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'Total: ${AppFormatter.formatCurrency(total)}',
                style: AppTextStyle.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Multi-color Segmented Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: breakdown.map((item) {
                  final flex = (item.percentage * 10).toInt();
                  if (flex <= 0) return const SizedBox.shrink();
                  return Expanded(
                    flex: flex,
                    child: Container(
                      color: _getMethodColor(item.method),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Breakdown list
          ...breakdown.map((item) {
            final color = _getMethodColor(item.method);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.methodLabel,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${item.percentage.toStringAsFixed(1)}%',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppFormatter.formatCurrency(item.totalAmount),
                    style: AppTextStyle.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

