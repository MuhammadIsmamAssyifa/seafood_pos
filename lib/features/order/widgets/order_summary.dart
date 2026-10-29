import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import 'order_status_badge.dart';

class OrderSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double grandTotal;
  final int totalItemCount;
  final String orderStatus;
  final bool hasWaitingBatch;
  final int waitingItemCount;
  final bool isSubmitting;
  final VoidCallback? onSubmitBatch;
  final VoidCallback? onContinue;

  const OrderSummaryWidget({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.totalItemCount,
    this.orderStatus = 'draft',
    this.hasWaitingBatch = false,
    this.waitingItemCount = 0,
    this.isSubmitting = false,
    this.onSubmitBatch,
    this.onContinue,
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
              OrderStatusBadge(status: orderStatus),
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

          // Action Button
          if (hasWaitingBatch && onSubmitBatch != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isSubmitting ? null : onSubmitBatch,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.soup_kitchen_rounded, size: 20),
              label: Text(
                isSubmitting
                    ? 'Mengirim ke Dapur...'
                    : 'Kirim ke Dapur ($waitingItemCount Item)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            )
          else if (onContinue != null && totalItemCount > 0)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onContinue,
              icon: const Icon(Icons.payment_rounded, size: 20),
              label: const Text(
                'Lanjut ke Pembayaran',
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
