import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/helpers.dart';
import '../../order/models/order_model.dart';
import '../../release/controllers/release_controller.dart';
import '../../release/models/receipt_config_model.dart';
import '../../release/services/printer_service.dart';
import '../../release/widgets/custom_receipt_dialog.dart';
import '../../release/widgets/thermal_receipt_widget.dart';
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
    final double? cashReceived = (args?['cashReceived'] as num?)?.toDouble();
    final List<PaymentModel> paymentList = (args?['payments'] as List<PaymentModel>?) ?? [];

    final grandTotal = summary?.grandTotal ?? order?.grandTotal ?? 0.0;

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
                  order?.isCompleted == true
                      ? 'Order berhasil dilunasi dan status order telah selesai.'
                      : 'Pembayaran lunas! Pesanan sedang diproses di dapur.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Preview Struk Kasir', style: AppTextStyle.h3),
                    TextButton.icon(
                      onPressed: () => CustomReceiptDialog.show(context),
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: const Text('Kustom Struk'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Receipt Card Preview (Matches exact thermal receipt layout)
                Obx(() {
                  final config = Get.isRegistered<PrinterService>()
                      ? Get.find<PrinterService>().receiptConfig.value
                      : const ReceiptConfigModel();

                  return ThermalReceiptWidget(
                    orderNumber: order?.orderNumber ?? '-',
                    tableNumber: order?.tableNumber,
                    customerName: order?.customerName,
                    guestCount: order?.guestCount ?? 1,
                    createdAt: order?.createdAt ?? DateTime.now(),
                    items: order?.items ?? const [],
                    subtotal: order?.subtotal ?? grandTotal,
                    discount: order?.discount ?? 0.0,
                    grandTotal: grandTotal,
                    payments: paymentList.isNotEmpty
                        ? paymentList
                        : (lastPayment != null ? [lastPayment] : null),
                    changeAmount: change,
                    cashReceived: cashReceived,
                    config: config,
                  );
                }),

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    // Print Receipt
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
                          if (order != null) {
                            if (Get.isRegistered<ReleaseController>()) {
                              Get.find<ReleaseController>().printReceipt(
                                order,
                                summary: summary,
                                payments: paymentList,
                                change: change,
                                cashReceived: cashReceived,
                              );
                            } else {
                              AppHelpers.showSuccess(
                                message: 'Struk order berhasil dicetak.',
                              );
                            }
                          } else {
                            AppHelpers.showWarning(message: 'Data order tidak ditemukan untuk dicetak.');
                          }
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
}
