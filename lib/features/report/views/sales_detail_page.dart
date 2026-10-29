import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../controllers/report_controller.dart';
import '../widgets/sales_chart.dart';
import '../widgets/statistic_card.dart';

class SalesDetailPage extends GetView<ReportController> {
  const SalesDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Penjualan'),
        elevation: 0,
      ),
      body: Obx(() {
        final sales = controller.sales.value;
        if (sales == null) {
          return const Center(child: Text('Data penjualan belum tersedia.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Metrics Grid
              Row(
                children: [
                  Expanded(
                    child: StatisticCard(
                      label: 'Penjualan Bersih',
                      value: AppFormatter.formatCurrency(sales.netSales),
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticCard(
                      label: 'Total Order',
                      value: '${sales.totalOrders}',
                      icon: Icons.receipt_long_rounded,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatisticCard(
                      label: 'Rata-rata Order (AOV)',
                      value: AppFormatter.formatCurrency(sales.averageOrderValue),
                      icon: Icons.analytics_rounded,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatisticCard(
                      label: 'Rata-rata / Tamu',
                      value: AppFormatter.formatCurrency(sales.averageSpendPerGuest),
                      icon: Icons.person_outline_rounded,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Daily Trends Chart
              SalesChart(
                trends: sales.dailyTrends,
                title: 'Grafik Tren Penjualan',
              ),
              const SizedBox(height: 16),

              // Breakdown Table / List
              Text(
                'Rincian Harian',
                style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...sales.dailyTrends.reversed.map((trend) {
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.border, width: 0.8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trend.date,
                              style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${trend.totalOrders} transaksi • Diskon: ${AppFormatter.formatCurrency(trend.discounts)}',
                              style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        Text(
                          AppFormatter.formatCurrency(trend.netSales),
                          style: AppTextStyle.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

