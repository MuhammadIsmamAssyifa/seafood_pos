import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../models/table_model.dart';
import '../widgets/table_status_badge.dart';

class TableDetailPage extends StatelessWidget {
  final TableModel table;
  final VoidCallback? onNewOrder;

  const TableDetailPage({
    super.key,
    required this.table,
    this.onNewOrder,
  });

  @override
  Widget build(BuildContext context) {
    final active = table.activeOrder;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail ${table.displayName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          table.displayName,
                          style: AppTextStyle.h2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          table.isOccupied ? 'Meja sedang digunakan' : 'Meja kosong & siap pakai',
                          style: AppTextStyle.bodySmall,
                        ),
                      ],
                    ),
                    TableStatusBadge(status: table.status, fontSize: 13),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (active != null) ...[
              // Active Order Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pesanan Aktif',
                        style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      _buildRow('No. Pesanan', active.orderNumber),
                      const Divider(height: 20),
                      _buildRow('Pelanggan', active.customerName ?? '-'),
                      const Divider(height: 20),
                      _buildRow('Jumlah Tamu', '${active.guestCount} Orang'),
                      const Divider(height: 20),
                      _buildRow('Status', active.status.toUpperCase()),
                      const Divider(height: 20),
                      _buildRow(
                        'Subtotal',
                        AppFormatter.formatCurrency(active.subtotal),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Buka Halaman Order',
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                onPressed: () {
                  Get.toNamed(
                    AppRoutes.ORDER,
                    arguments: {
                      'order_id': active.id,
                      'table_id': table.id,
                      'table_number': table.number,
                      'customer_name': active.customerName,
                    },
                  );
                },
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    children: [
                      const Icon(Icons.event_seat_rounded, size: 54, color: AppColors.primary),
                      const SizedBox(height: 14),
                      Text(
                        'Belum Ada Pesanan',
                        style: AppTextStyle.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mulai buat pesanan baru untuk pelanggan di meja ini.',
                        style: AppTextStyle.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (onNewOrder != null)
                AppButton(
                  text: 'Buka Pesanan Baru',
                  icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 20),
                  onPressed: onNewOrder,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyle.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: isBold
              ? AppTextStyle.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)
              : AppTextStyle.titleSmall,
        ),
      ],
    );
  }
}

