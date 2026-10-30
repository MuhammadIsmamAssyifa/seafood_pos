import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/app_loading.dart';
import '../../release/controllers/release_controller.dart';
import '../../release/models/receipt_config_model.dart';
import '../../release/services/printer_service.dart';
import '../../release/widgets/custom_receipt_dialog.dart';
import '../../release/widgets/thermal_receipt_widget.dart';
import '../controllers/history_controller.dart';
import '../models/history_order_model.dart';
import '../widgets/adjustment_history_card.dart';
import '../widgets/history_status_badge.dart';
import '../widgets/payment_history_card.dart';

class HistoryDetailPage extends GetView<HistoryController> {
  const HistoryDetailPage({super.key});

  void _showReceiptModal(BuildContext context, HistoryOrderModel order) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Top action bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Preview Struk Kasir', style: AppTextStyle.h3),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
                      tooltip: 'Kustom Header & Footer',
                      onPressed: () => CustomReceiptDialog.show(context),
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Get.back()),
                  ],
                ),
              ],
            ),
            const Divider(),

            // Thermal Paper Receipt Simulator
            Expanded(
              child: SingleChildScrollView(
                child: Obx(() {
                  final config = Get.isRegistered<PrinterService>()
                      ? Get.find<PrinterService>().receiptConfig.value
                      : const ReceiptConfigModel();

                  double change = 0.0;
                  double? cashReceived;
                  for (final p in order.payments) {
                    if (p.changeAmount != null && p.changeAmount! > 0) {
                      change = p.changeAmount!;
                    }
                    if (p.cashReceived != null && p.cashReceived! > 0) {
                      cashReceived = p.cashReceived;
                    }
                  }

                  return ThermalReceiptWidget(
                    orderNumber: order.orderNumber,
                    tableNumber: order.tableNumber,
                    customerName: order.customerName,
                    guestCount: order.guestCount,
                    createdAt: order.createdAt,
                    items: order.items,
                    subtotal: order.subtotal,
                    discount: order.discount,
                    grandTotal: order.grandTotal,
                    payments: order.payments,
                    changeAmount: change,
                    cashReceived: cashReceived,
                    config: config,
                  );
                }),
              ),
            ),

            const SizedBox(height: 14),

            // Print action button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Get.back();
                double change = 0.0;
                double? cashReceived;
                for (final p in order.payments) {
                  if (p.changeAmount != null && p.changeAmount! > 0) {
                    change = p.changeAmount!;
                  }
                  if (p.cashReceived != null && p.cashReceived! > 0) {
                    cashReceived = p.cashReceived;
                  }
                }

                if (Get.isRegistered<ReleaseController>()) {
                  Get.find<ReleaseController>().printReceipt(
                    order.toOrderModel(),
                    payments: order.payments,
                    change: change,
                    cashReceived: cashReceived,
                  );
                } else {
                  AppHelpers.showSuccess(
                    message: 'Perintah cetak ulang struk ${order.orderNumber} telah dikirim ke printer kasir.',
                    title: 'Cetak Ulang Struk',
                  );
                }
              },
              icon: const Icon(Icons.print_rounded),
              label: const Text('Cetak Struk'),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final o = controller.selectedOrder.value;
          return Text(o != null ? 'Detail ${o.orderNumber}' : 'Detail Order');
        }),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: 'Preview Struk',
            onPressed: () {
              final o = controller.selectedOrder.value;
              if (o != null) {
                _showReceiptModal(context, o);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value && controller.selectedOrder.value == null) {
          return const AppLoading(message: 'Memuat rincian transaksi...');
        }

        final order = controller.selectedOrder.value;
        if (order == null) {
          return const Center(child: Text('Data transaksi tidak ditemukan.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Order Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.orderNumber,
                          style: AppTextStyle.h3.copyWith(color: AppColors.primary),
                        ),
                        HistoryStatusBadge(status: order.status),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Customer', style: AppTextStyle.caption.copyWith(color: AppColors.textMuted)),
                              const SizedBox(height: 2),
                              Text(order.customerName, style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Meja / Tamu', style: AppTextStyle.caption.copyWith(color: AppColors.textMuted)),
                              const SizedBox(height: 2),
                              Text(
                                '${order.tableNumber != null ? 'Meja ${order.tableNumber}' : 'Tanpa Meja'} (${order.guestCount} Orang)',
                                style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (order.createdAt != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            'Waktu Order: ${AppFormatter.formatDateTime(order.createdAt!)}',
                            style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Ordered Items Card
              Container(
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
                      children: [
                        const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Daftar Item (${order.items.length})',
                          style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    if (order.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Tidak ada daftar item.',
                          style: AppTextStyle.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.items.length,
                        separatorBuilder: (_, index) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.displayName,
                                      style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${AppFormatter.formatQuantity(item.quantity, item.unit)} x ${AppFormatter.formatCurrency(item.price)}',
                                      style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                AppFormatter.formatCurrency(item.subtotal),
                                style: AppTextStyle.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                    const Divider(height: 24),

                    // Financial summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal', style: AppTextStyle.bodyMedium),
                        Text(AppFormatter.formatCurrency(order.subtotal), style: AppTextStyle.bodyMedium),
                      ],
                    ),
                    if (order.discount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Diskon', style: AppTextStyle.bodyMedium.copyWith(color: AppColors.error)),
                          Text('- ${AppFormatter.formatCurrency(order.discount)}', style: AppTextStyle.bodyMedium.copyWith(color: AppColors.error)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Grand Total', style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          AppFormatter.formatCurrency(order.grandTotal),
                          style: AppTextStyle.titleLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Payment History Card
              PaymentHistoryCard(payments: order.payments),

              const SizedBox(height: 16),

              // 4. Adjustment History Card
              AdjustmentHistoryCard(adjustments: order.adjustments),

              const SizedBox(height: 24),

              // 5. Reprint Action Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showReceiptModal(context, order),
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Lihat & Cetak Ulang Struk'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
