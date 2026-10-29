import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';

class OrderSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double grandTotal;
  final int totalItemCount;
  final VoidCallback? onContinue;
  final bool isDraft;

  const OrderSummaryWidget({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.totalItemCount,
    this.onContinue,
    this.isDraft = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Pesanan',
                style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDraft ? AppColors.warning.withAlpha(30) : AppColors.success.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isDraft ? 'DRAFT' : 'PROCESSED',
                  style: AppTextStyle.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDraft ? AppColors.warning : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total Items & Subtotal
          _buildSummaryRow(
            'Total Item',
            '$totalItemCount item',
          ),
          const SizedBox(height: 6),
          _buildSummaryRow(
            'Subtotal',
            AppFormatter.formatCurrency(subtotal),
          ),

          if (discount > 0) ...[
            const SizedBox(height: 6),
            _buildSummaryRow(
              'Diskon',
              '- ${AppFormatter.formatCurrency(discount)}',
              valueColor: AppColors.success,
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: AppTextStyle.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                AppFormatter.formatCurrency(grandTotal),
                style: AppTextStyle.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Continue / Status Action
          if (onContinue != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: totalItemCount > 0 ? onContinue : null,
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: const Text(
                'Lanjutkan (Sprint 06: Kitchen)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyle.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

