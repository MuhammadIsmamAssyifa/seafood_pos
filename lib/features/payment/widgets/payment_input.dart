import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../controllers/payment_controller.dart';
import 'payment_method_button.dart';

class PaymentInputWidget extends StatelessWidget {
  final PaymentController controller;

  const PaymentInputWidget({
    super.key,
    required this.controller,
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
            // Title
            Text(
              'Metode Pembayaran',
              style: AppTextStyle.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Method selection buttons
            Obx(() => Row(
                  children: [
                    PaymentMethodButton(
                      method: 'cash',
                      title: 'Tunai',
                      subtitle: 'Uang Cash',
                      icon: Icons.payments_rounded,
                      isSelected: controller.selectedMethod.value == 'cash',
                      onTap: () => controller.selectMethod('cash'),
                    ),
                    const SizedBox(width: 12),
                    PaymentMethodButton(
                      method: 'transfer',
                      title: 'Transfer',
                      subtitle: 'Bank / QRIS',
                      icon: Icons.account_balance_rounded,
                      isSelected: controller.selectedMethod.value == 'transfer',
                      onTap: () => controller.selectMethod('transfer'),
                    ),
                  ],
                )),

            const SizedBox(height: 20),

            // Amount Input Label
            Obx(() => Text(
                  controller.selectedMethod.value == 'cash'
                      ? 'Uang Diterima dari Pelanggan'
                      : 'Nominal Transfer',
                  style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                )),
            const SizedBox(height: 8),

            // Amount TextField
            TextField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyle.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              decoration: InputDecoration(
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    'Rp',
                    style: AppTextStyle.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                hintText: '0',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    controller.setAmount(0);
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (val) {
                final numVal = double.tryParse(val) ?? 0.0;
                if (controller.selectedMethod.value == 'cash') {
                  controller.setCashReceived(numVal);
                } else {
                  controller.setAmount(numVal);
                }
              },
            ),

            const SizedBox(height: 14),

            // Quick Nominals
            Obx(() {
              final nominals = controller.quickNominals;
              if (nominals.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilihan Cepat:',
                    style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: nominals.map((nominal) {
                      final isExact = nominal == controller.remainingAmount;
                      final label = isExact ? 'Uang Pas' : AppFormatter.formatCurrency(nominal);

                      return ActionChip(
                        label: Text(label),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isExact ? FontWeight.bold : FontWeight.w600,
                          color: isExact ? Colors.white : AppColors.primary,
                        ),
                        backgroundColor: isExact ? AppColors.primary : AppColors.primary.withOpacity(0.08),
                        side: BorderSide(
                          color: isExact ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        onPressed: () {
                          if (controller.selectedMethod.value == 'cash') {
                            controller.setCashReceived(nominal);
                          } else {
                            controller.setAmount(nominal);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              );
            }),

            const SizedBox(height: 16),

            // Kembalian calculation for Cash
            Obx(() {
              if (controller.selectedMethod.value != 'cash') {
                return const SizedBox.shrink();
              }

              final change = controller.changeAmount;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: change > 0 ? Colors.amber.shade50 : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: change > 0 ? Colors.amber.shade300 : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.currency_exchange_rounded,
                          size: 20,
                          color: change > 0 ? Colors.amber.shade800 : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kembalian',
                          style: AppTextStyle.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: change > 0 ? Colors.amber.shade900 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      AppFormatter.formatCurrency(change),
                      style: AppTextStyle.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: change > 0 ? Colors.amber.shade900 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // Pay Button
            Obx(() {
              final isSubmitting = controller.isSubmitting.value;
              final isPaid = controller.isPaid;

              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPaid ? Colors.green.shade700 : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: (isSubmitting || isPaid)
                      ? null
                      : () => controller.submitPayment(),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(
                          isPaid ? Icons.check_circle_rounded : Icons.payment_rounded,
                          size: 20,
                        ),
                  label: Text(
                    isSubmitting
                        ? 'Memproses Pembayaran...'
                        : (isPaid ? 'Pesanan Sudah Lunas' : 'Bayar Sekarang'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
