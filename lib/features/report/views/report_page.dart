import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../controllers/report_controller.dart';
import '../widgets/payment_chart.dart';
import '../widgets/report_filter_sheet.dart';
import '../widgets/sales_chart.dart';
import '../widgets/statistic_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/top_menu_card.dart';

class ReportPage extends GetView<ReportController> {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Laporan & Statistik'),
          elevation: 0,
          actions: [
            Obx(() => TextButton.icon(
                  onPressed: () => ReportFilterSheet.show(
                    context: context,
                    currentFilter: controller.selectedFilter.value,
                    onApply: (f) => controller.changeFilter(f),
                  ),
                  icon: const Icon(Icons.filter_list_rounded, size: 18),
                  label: Text(
                    controller.selectedFilter.value.period.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh Laporan',
              onPressed: () => controller.refreshReport(),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Ringkasan'),
              Tab(text: 'Penjualan'),
              Tab(text: 'Pembayaran'),
              Tab(text: 'Menu Terlaris'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.dashboard.value == null && controller.sales.value == null) {
            return const AppLoading(message: 'Memuat data laporan...');
          }

          if (controller.errorMessage.value != null && controller.dashboard.value == null) {
            return AppErrorWidget(
              message: controller.errorMessage.value!,
              onRetry: () => controller.refreshReport(),
            );
          }

          return TabBarView(
            children: [
              _buildDashboardTab(context),
              _buildSalesTab(context),
              _buildPaymentTab(context),
              _buildTopMenuTab(context),
            ],
          );
        }),
      ),
    );
  }

  /// Tab 1: Dashboard Summary & Order Statuses
  Widget _buildDashboardTab(BuildContext context) {
    final dash = controller.dashboard.value;
    if (dash == null) {
      return const Center(child: Text('Data ringkasan belum tersedia.'));
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshReport(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KPI Summary Cards
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Penjualan Hari Ini',
                  value: AppFormatter.formatCurrency(dash.todayRevenue),
                  subtitle: '${dash.completedOrdersToday} order selesai',
                  icon: Icons.monetization_on_rounded,
                  iconColor: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryCard(
                  title: 'Rata-rata Transaksi',
                  value: AppFormatter.formatCurrency(dash.averageTransaction),
                  subtitle: 'Per transaksi selesai',
                  icon: Icons.trending_up_rounded,
                  iconColor: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total Order',
                  value: '${dash.totalOrdersToday}',
                  subtitle: '${dash.activeOrdersCount} sedang diproses',
                  icon: Icons.receipt_long_rounded,
                  iconColor: Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryCard(
                  title: 'Okupansi Meja',
                  value: '${dash.occupancyRate.toStringAsFixed(0)}%',
                  subtitle: '${dash.occupiedTables} dari ${dash.totalTables} terisi',
                  icon: Icons.table_restaurant_rounded,
                  iconColor: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Order Status Breakdown Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribusi Status Order Hari Ini',
                  style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusPill('Draft', dash.statusBreakdown['draft'] ?? 0, Colors.grey),
                    const SizedBox(width: 6),
                    _buildStatusPill('Terkirim', dash.statusBreakdown['submitted'] ?? 0, Colors.blue),
                    const SizedBox(width: 6),
                    _buildStatusPill('Dimasak', dash.statusBreakdown['preparing'] ?? 0, Colors.orange),
                    const SizedBox(width: 6),
                    _buildStatusPill('Siap', dash.statusBreakdown['ready'] ?? 0, Colors.teal),
                    const SizedBox(width: 6),
                    _buildStatusPill('Selesai', dash.statusBreakdown['completed'] ?? 0, Colors.green),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Today's Payment Quick Summary
          Container(
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
                      'Penerimaan Hari Ini',
                      style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      AppFormatter.formatCurrency(dash.totalCollected),
                      style: AppTextStyle.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatisticCard(
                        label: 'Cash (Tunai)',
                        value: AppFormatter.formatCurrency(dash.todayCash),
                        icon: Icons.payments_outlined,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatisticCard(
                        label: 'Transfer Bank',
                        value: AppFormatter.formatCurrency(dash.todayTransfer),
                        icon: Icons.account_balance_outlined,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(80), width: 0.8),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Tab 2: Sales Summary & Daily Trends
  Widget _buildSalesTab(BuildContext context) {
    final sales = controller.sales.value;
    if (sales == null) {
      return RefreshIndicator(
        onRefresh: () => controller.refreshReport(),
        child: ListView(
          children: const [
            Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('Laporan penjualan belum tersedia.')),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshReport(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: StatisticCard(
                  label: 'Penjualan Kotor',
                  value: AppFormatter.formatCurrency(sales.grossSales),
                  icon: Icons.receipt_rounded,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatisticCard(
                  label: 'Total Diskon',
                  value: AppFormatter.formatCurrency(sales.totalDiscounts),
                  icon: Icons.discount_outlined,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                  label: 'Rata-rata / Order',
                  value: AppFormatter.formatCurrency(sales.averageOrderValue),
                  icon: Icons.analytics_outlined,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SalesChart(trends: sales.dailyTrends),
        ],
      ),
    );
  }

  /// Tab 3: Payment Summary
  Widget _buildPaymentTab(BuildContext context) {
    final pay = controller.payments.value;
    if (pay == null) {
      return RefreshIndicator(
        onRefresh: () => controller.refreshReport(),
        child: ListView(
          children: const [
            Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('Laporan pembayaran belum tersedia.')),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshReport(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PaymentChart(paymentSummary: pay),
        ],
      ),
    );
  }

  /// Tab 4: Best Selling Menus
  Widget _buildTopMenuTab(BuildContext context) {
    final topList = controller.topMenus;

    return RefreshIndicator(
      onRefresh: () => controller.refreshReport(),
      child: Builder(
        builder: (context) {
          if (topList.isEmpty) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_menu_rounded, size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('Belum ada menu terjual pada periode ini.'),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: topList.length,
            itemBuilder: (context, index) {
              return TopMenuCard(
                rank: index + 1,
                item: topList[index],
              );
            },
          );
        },
      ),
    );
  }
}

