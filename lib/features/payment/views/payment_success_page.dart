import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/helpers.dart';
import '../../order/models/order_model.dart';
import '../models/payment_model.dart';
import '../models/payment_summary_model.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final OrderModel? order = args?['order'] as OrderModel?;
    final PaymentSummaryModel? summary = args?['summary'] as PaymentSummaryModel?;
    final PaymentModel? lastPayment = args?['lastPayment'] as PaymentModel?;
    final double change = (args?['change'] as num?)?.toDouble() ?? 0.0;
    final List<PaymentModel> paymentList = (args?['payments'] as List<PaymentModel>?) ?? [];

    final grandTotal = summary?.grandTotal ?? order?.grandTotal ?? 0.0;
    final totalPaid = summary?.paid ?? grandTotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pembayaran Berhasil'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Celebration Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade300, width: 2),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 64,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Transaksi Selesai!',
                  style: AppTextStyle.h2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Order berhasil dilunasi dan status order telah selesai.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 24),

                // Receipt Card Preview
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Restaurant Header
                        Text(
                          'RESTO SEAFOOD NUSANTARA',
                          style: AppTextStyle.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Struk Pembayaran Kasir',
                          style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        const Divider(thickness: 1),
                        const SizedBox(height: 8),

                        // Order Info
                        _buildReceiptRow('No. Pesanan', order?.orderNumber ?? '-'),
                        _buildReceiptRow('Meja', 'Meja ${order?.tableNumber ?? '-'}'),
                        _buildReceiptRow(
                          'Pelanggan',
                          order?.customerName?.isNotEmpty == true
                              ? order!.customerName!
                              : 'Umum',
                        ),
                        _buildReceiptRow(
                          'Waktu',
                          AppFormatter.formatDateTime(DateTime.now()),
                        ),

                        const SizedBox(height: 8),
                        const Divider(thickness: 1),
                        const SizedBox(height: 8),

                        // Itemized Order Preview
                        if (order?.items.isNotEmpty == true) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Rincian Pesanan:',
                              style: AppTextStyle.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...order!.items.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.quantity.toInt()}x ${item.variantName}',
                                        style: AppTextStyle.bodySmall,
                                      ),
                                    ),
                                    Text(
                                      AppFormatter.formatCurrency(item.subtotal),
                                      style: AppTextStyle.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 8),
                          const Divider(thickness: 1),
                          const SizedBox(height: 8),
                        ],

                        // Totals
                        _buildReceiptRow(
                          'Total Tagihan',
                          AppFormatter.formatCurrency(grandTotal),
                          isBold: true,
                        ),
                        _buildReceiptRow(
                          'Total Dibayar',
                          AppFormatter.formatCurrency(totalPaid),
                          isBold: true,
                          color: Colors.green.shade700,
                        ),

                        // Payments Breakdown
                        if (paymentList.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          ...paymentList.map((p) => _buildReceiptRow(
                                '  • ${p.methodLabel}',
                                AppFormatter.formatCurrency(p.amount),
                              )),
                        ] else if (lastPayment != null) ...[
                          _buildReceiptRow(
                            'Metode',
                            lastPayment.methodLabel,
                          ),
                        ],

                        // Change
                        if (change > 0) ...[
                          const SizedBox(height: 4),
                          _buildReceiptRow(
                            'Kembalian',
                            AppFormatter.formatCurrency(change),
                            isBold: true,
                            color: Colors.amber.shade900,
                          ),
                        ],

                        const SizedBox(height: 12),
                        const Divider(thickness: 1),
                        const SizedBox(height: 8),
                        Text(
                          'Terima Kasih Atas Kunjungan Anda!',
                          style: AppTextStyle.caption.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    // Print Receipt Simulation
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: AppColors.primary),
                        ),
                        onPressed: () {
                          AppHelpers.showSuccess(
                            message: 'Simulasi cetak struk: Struk terkirim ke printer thermal.',
                          );
                        },
                        icon: const Icon(Icons.print_rounded, size: 20),
                        label: const Text('Cetak Struk'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Back to Table
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Get.offAllNamed(AppRoutes.TABLES);
                        },
                        icon: const Icon(Icons.table_restaurant_rounded, size: 20),
                        label: const Text('Kembali ke Meja'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyle.bodySmall.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyle.bodySmall.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
