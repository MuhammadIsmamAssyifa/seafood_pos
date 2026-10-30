import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../payment/models/payment_model.dart';

class PaymentHistoryCard extends StatelessWidget {
  final List<PaymentModel> payments;

  const PaymentHistoryCard({
    super.key,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 20),
            const SizedBox(width: 10),
            Text(
              'Belum ada riwayat pembayaran.',
              style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final totalPaid = payments.fold<double>(0.0, (sum, p) => sum + p.amount);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.payments_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Riwayat Pembayaran (${payments.length})',
                    style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (payments.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Split Payment',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 20),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (_, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final p = payments[index];
              final isCash = p.isCash;
              final timeStr = p.createdAt != null
                  ? AppFormatter.formatDateTime(p.createdAt!)
                  : '-';

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Index / Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCash
                          ? AppColors.success.withAlpha(20)
                          : const Color(0xFF0284C7).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        isCash ? Icons.money_rounded : Icons.qr_code_rounded,
                        size: 20,
                        color: isCash ? AppColors.success : const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Detail
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payments.length > 1
                              ? 'Pembayaran #${index + 1} • ${p.methodLabel}'
                              : p.methodLabel,
                          style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeStr,
                          style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                        ),
                        if (isCash && ((p.cashReceived != null && p.cashReceived! > p.amount) || (p.changeAmount != null && p.changeAmount! > 0)))
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              'Diterima: ${AppFormatter.formatCurrency(p.cashReceived ?? (p.amount + (p.changeAmount ?? 0)))} • Kembali: ${AppFormatter.formatCurrency(p.changeAmount ?? 0)}',
                              style: AppTextStyle.caption.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Amount
                  Text(
                    AppFormatter.formatCurrency(p.amount),
                    style: AppTextStyle.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              );
            },
          ),

          const Divider(height: 20),

          // Total Paid Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Terbayar',
                style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                AppFormatter.formatCurrency(totalPaid),
                style: AppTextStyle.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
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
