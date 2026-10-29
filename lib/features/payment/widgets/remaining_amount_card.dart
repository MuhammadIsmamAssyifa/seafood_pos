import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/payment_summary_model.dart';

class RemainingAmountCard extends StatelessWidget {
  final PaymentSummaryModel? summary;
  final double defaultGrandTotal;

  const RemainingAmountCard({
    super.key,
    this.summary,
    this.defaultGrandTotal = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final grandTotal = summary?.grandTotal ?? defaultGrandTotal;
    final paid = summary?.paid ?? 0.0;
    final remaining = summary?.remaining ?? (grandTotal - paid);
    final isLunas = remaining <= 0;
    final progress = summary?.paymentProgress ?? (grandTotal > 0 ? (paid / grandTotal).clamp(0.0, 1.0) : 0.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLunas ? Colors.green.shade50 : AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLunas ? Colors.green.shade300 : AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isLunas ? Icons.check_circle_rounded : Icons.pending_rounded,
                    color: isLunas ? Colors.green.shade700 : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sisa Pembayaran',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLunas ? Colors.green.shade600 : AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isLunas ? 'LUNAS' : (paid > 0 ? 'SEBAGIAN' : 'BELUM BAYAR'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppFormatter.formatCurrency(remaining),
            style: AppTextStyle.h2.copyWith(
              fontWeight: FontWeight.w800,
              color: isLunas ? Colors.green.shade800 : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.black.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                isLunas ? Colors.green.shade600 : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terbayar: ${AppFormatter.formatCurrency(paid)}',
                style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyle.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLunas ? Colors.green.shade700 : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
