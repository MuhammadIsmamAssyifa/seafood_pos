import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/app_loading.dart';
import '../../release/controllers/release_controller.dart';
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
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Get.back()),
              ],
            ),
            const Divider(),

            // Thermal Paper Receipt Simulator
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Restaurant Header
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              'SEAFOOD RESTO POS',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Jl. Pelabuhan Ikan No. 88\nTelp: 0812-3456-7890',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '------------------------------------------',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'monospace', color: Colors.grey),
                      ),
                      const SizedBox(height: 6),

                      // Order Meta
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('No: ${order.orderNumber}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                          Text(order.tableNumber != null ? 'Meja: ${order.tableNumber}' : '-', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Customer: ${order.customerName}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                          Text('${order.guestCount} Tamu', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                        ],
                      ),
                      if (order.createdAt != null)
                        Text(
                          'Waktu: ${AppFormatter.formatReceiptDateTime(order.createdAt!)}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black54),
                        ),

                      const SizedBox(height: 6),
                      const Text(
                        '------------------------------------------',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'monospace', color: Colors.grey),
                      ),
                      const SizedBox(height: 6),

                      // Items Table
                      ...order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.displayName,
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '  ${AppFormatter.formatQuantity(item.quantity, item.unit)} x ${AppFormatter.formatCurrency(item.price)}',
                                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black54),
                                  ),
                                  Text(
                                    AppFormatter.formatCurrency(item.subtotal),
                                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 6),
                      const Text(
                        '------------------------------------------',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'monospace', color: Colors.grey),
                      ),
                      const SizedBox(height: 6),

                      // Financial summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                          Text(AppFormatter.formatCurrency(order.subtotal), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                        ],
                      ),
                      if (order.discount > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Diskon:', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.red)),
                            Text('- ${AppFormatter.formatCurrency(order.discount)}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.red)),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL:', style: TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(AppFormatter.formatCurrency(order.grandTotal), style: const TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      const SizedBox(height: 6),
                      const Text(
                        '------------------------------------------',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'monospace', color: Colors.grey),
                      ),
                      const SizedBox(height: 6),

                      // Payments on receipt
                      ...order.payments.map((p) {
                        final isCash = p.isCash;
                        final tendered = p.cashReceived ?? (p.changeAmount != null && p.changeAmount! > 0 ? p.amount + p.changeAmount! : p.amount);
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(isCash ? 'Cash (Tunai)' : p.methodLabel, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                                Text(AppFormatter.formatCurrency(isCash ? tendered : p.amount), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                              ],
                            ),
                            if (p.changeAmount != null && p.changeAmount! > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Kembalian', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                                    Text(AppFormatter.formatCurrency(p.changeAmount!), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }),

                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          '*** TERIMA KASIH ***\nSelamat Menikmati Hidangan Kami',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'monospace', fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
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
