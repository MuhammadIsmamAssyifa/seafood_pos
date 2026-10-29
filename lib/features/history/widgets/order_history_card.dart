import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/history_order_model.dart';
import 'history_status_badge.dart';

class OrderHistoryCard extends StatelessWidget {
  final HistoryOrderModel order;
  final VoidCallback onTap;

  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = order.createdAt != null
        ? AppFormatter.formatDateTime(order.createdAt!)
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Order Number & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.receipt_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.orderNumber,
                          style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    HistoryStatusBadge(status: order.status),
                  ],
                ),

                const Divider(height: 20),

                // Middle Row: Customer Info, Table & Date
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                order.customerName,
                                style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.table_restaurant_outlined, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                order.tableNumber != null ? 'Meja ${order.tableNumber}' : 'Tanpa Meja',
                                style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 8),
                              Text('•', style: AppTextStyle.caption.copyWith(color: AppColors.textMuted)),
                              const SizedBox(width: 8),
                              Text(
                                '${order.guestCount} Tamu',
                                style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Total & Item Count
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppFormatter.formatCurrency(order.grandTotal),
                          style: AppTextStyle.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${order.totalItemCount} item pesanan',
                          style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Footer Row: Timestamp & Arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                    ),
                    Row(
                      children: [
                        Text(
                          'Lihat Detail',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
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

