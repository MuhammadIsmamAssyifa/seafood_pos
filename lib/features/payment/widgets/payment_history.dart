import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/payment_model.dart';

class PaymentHistoryWidget extends StatelessWidget {
  final List<PaymentModel> payments;

  const PaymentHistoryWidget({
    super.key,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Pembayaran',
                  style: AppTextStyle.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${payments.length} transaksi',
                    style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (payments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded, size: 36, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada pembayaran yang dicatat',
                        style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final p = payments[index];
                  final isCash = p.isCash;

                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isCash ? Colors.teal : Colors.blue).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCash ? Icons.payments_rounded : Icons.account_balance_rounded,
                          color: isCash ? Colors.teal : Colors.blue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.methodLabel,
                              style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              p.createdAt != null
                                  ? AppFormatter.formatDateTime(p.createdAt!)
                                  : 'Baru saja',
                              style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppFormatter.formatCurrency(p.amount),
                        style: AppTextStyle.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
