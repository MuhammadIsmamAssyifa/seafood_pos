import 'package:flutter/material.dart';
import '../../../core/utils/formatter.dart';
import '../../order/models/order_item_model.dart';
import '../../payment/models/payment_model.dart';
import '../models/receipt_config_model.dart';

class ThermalReceiptWidget extends StatelessWidget {
  final String orderNumber;
  final String? tableNumber;
  final String? customerName;
  final int guestCount;
  final DateTime? createdAt;
  final List<OrderItemModel> items;
  final double subtotal;
  final double discount;
  final double grandTotal;
  final List<PaymentModel>? payments;
  final double? changeAmount;
  final double? cashReceived;
  final ReceiptConfigModel config;

  const ThermalReceiptWidget({
    super.key,
    required this.orderNumber,
    this.tableNumber,
    this.customerName,
    this.guestCount = 1,
    this.createdAt,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    required this.grandTotal,
    this.payments,
    this.changeAmount,
    this.cashReceived,
    this.config = const ReceiptConfigModel(),
  });

  Widget _buildDashedDivider() {
    return const Column(
      children: [
        SizedBox(height: 6),
        Text(
          '--------------------------------------',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'monospace', color: Colors.grey),
        ),
        SizedBox(height: 6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Restaurant Header (Customizable from Restaurant table)
          Center(
            child: Column(
              children: [
                Text(
                  config.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                if (config.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    config.address,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
                if (config.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Telp: ${config.phone}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          _buildDashedDivider(),

          // Order Meta Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'No: $orderNumber',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              Text(
                tableNumber != null && tableNumber!.isNotEmpty
                    ? 'Meja: $tableNumber'
                    : '-',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer: ${customerName?.isNotEmpty == true ? customerName! : 'Umum'}',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              Text(
                '$guestCount Tamu',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
          if (createdAt != null)
            Text(
              'Waktu: ${AppFormatter.formatReceiptDateTime(createdAt!)}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.black54,
              ),
            ),

          _buildDashedDivider(),

          // Itemized Breakdown
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '  ${AppFormatter.formatQuantity(item.quantity, item.unit)} x ${AppFormatter.formatCurrency(item.price)}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Colors.black54,
                        ),
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

          _buildDashedDivider(),

          // Financial Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
              Text(AppFormatter.formatCurrency(subtotal), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ],
          ),
          if (discount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Diskon:', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.red)),
                Text('- ${AppFormatter.formatCurrency(discount)}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.red)),
              ],
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL:', style: TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold)),
              Text(AppFormatter.formatCurrency(grandTotal), style: const TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),

          _buildDashedDivider(),

          // Payments Breakdown
          if (payments != null && payments!.isNotEmpty) ...[
            ...payments!.map((p) {
              final isCash = p.isCash;
              double tendered = p.amount;
              if (p.cashReceived != null && p.cashReceived! > 0) {
                tendered = p.cashReceived!;
              } else if (cashReceived != null && cashReceived! > 0) {
                tendered = cashReceived!;
              } else if (p.amount > grandTotal) {
                tendered = p.amount;
              } else if (changeAmount != null && changeAmount! > 0) {
                tendered = p.amount + changeAmount!;
              } else if (p.changeAmount != null && p.changeAmount! > 0) {
                tendered = p.amount + p.changeAmount!;
              }
              final itemChange = p.changeAmount ?? changeAmount;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCash ? 'Cash (Tunai)' : p.methodLabel,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                      Text(
                        AppFormatter.formatCurrency(isCash ? tendered : p.amount),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ],
                  ),
                  if (isCash && itemChange != null && itemChange > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kembalian', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                          Text(
                            AppFormatter.formatCurrency(itemChange),
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            }),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cash (Tunai)', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                Text(
                  AppFormatter.formatCurrency(cashReceived ?? grandTotal),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
            if (changeAmount != null && changeAmount! > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kembalian', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    Text(
                      AppFormatter.formatCurrency(changeAmount!),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],

          const SizedBox(height: 16),

          // Footer Message (Customizable from Restaurant table)
          Center(
            child: Text(
              config.footerMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
