import 'dart:math';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/sales_report_model.dart';

class SalesChart extends StatelessWidget {
  final List<DailySalesTrendModel> trends;
  final String title;

  const SalesChart({
    super.key,
    required this.trends,
    this.title = 'Tren Penjualan Harian',
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Text(
          'Belum ada data transaksi harian pada periode ini.',
          style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final maxSales = trends.map((t) => t.netSales).fold<double>(0.0, max);
    final totalNet = trends.map((t) => t.netSales).fold<double>(0.0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                AppFormatter.formatCurrency(totalNet),
                style: AppTextStyle.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: trends.map((item) {
                final ratio = maxSales > 0 ? (item.netSales / maxSales).clamp(0.05, 1.0) : 0.05;
                final dateLabel = item.date.length >= 5 ? item.date.substring(5) : item.date;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: '${item.date}\n${AppFormatter.formatCurrency(item.netSales)}\n${item.totalOrders} order',
                          child: Container(
                            height: 100 * ratio,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withAlpha(160),
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dateLabel,
                          style: AppTextStyle.caption.copyWith(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
