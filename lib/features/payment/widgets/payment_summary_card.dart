import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../order/models/order_model.dart';
import '../models/payment_summary_model.dart';

class PaymentSummaryCard extends StatelessWidget {
  final OrderModel? order;
  final PaymentSummaryModel? summary;

  const PaymentSummaryCard({
    super.key,
    this.order,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = order?.subtotal ?? summary?.grandTotal ?? 0.0;
    final discount = order?.discount ?? 0.0;
    final grandTotal = summary?.grandTotal ?? order?.grandTotal ?? 0.0;
    final paid = summary?.paid ?? 0.0;
    final remaining = summary?.remaining ?? (grandTotal - paid);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order?.customerName?.isNotEmpty == true
                            ? order!.customerName!
                            : 'Pelanggan Umum',
                        style: AppTextStyle.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Meja ${order?.tableNumber ?? '-'} • ${order?.orderNumber ?? '-'}',
                        style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Financial summary lines
            _buildRow('Subtotal', AppFormatter.formatCurrency(subtotal)),
            if (discount > 0) ...[
              const SizedBox(height: 8),
              _buildRow('Diskon', '- ${AppFormatter.formatCurrency(discount)}',
                  valueColor: Colors.red.shade600),
            ],
            const SizedBox(height: 8),
            _buildRow('Total Tagihan', AppFormatter.formatCurrency(grandTotal), isBold: true),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            _buildRow('Sudah Dibayar', AppFormatter.formatCurrency(paid),
                valueColor: Colors.green.shade700),
            const SizedBox(height: 8),
            _buildRow(
              'Sisa Pembayaran',
              AppFormatter.formatCurrency(remaining),
              isBold: true,
              valueColor: remaining <= 0 ? Colors.green.shade700 : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyle.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyle.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
