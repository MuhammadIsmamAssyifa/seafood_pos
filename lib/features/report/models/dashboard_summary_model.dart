import 'top_menu_model.dart';

class DashboardSummaryModel {
  final int outletId;
  final String date;

  // Sales
  final double todayRevenue;
  final double todayCogs;
  final double todayGrossProfit;
  final double todayProfitMargin;
  final double averageTransaction;

  // Orders
  final int totalOrdersToday;
  final int completedOrdersToday;
  final int activeOrdersCount;
  final int guestsToday;
  final Map<String, int> statusBreakdown;

  // Payments
  final double todayCash;
  final double todayTransfer;
  final double todayQris;
  final double totalCollected;

  // Tables
  final int totalTables;
  final int occupiedTables;
  final int availableTables;
  final double occupancyRate;

  // Inventory Alerts
  final int lowStockCount;

  // Lists
  final List<Map<String, dynamic>> recentOrders;
  final List<TopMenuModel> topSellingMenus;

  const DashboardSummaryModel({
    required this.outletId,
    required this.date,
    this.todayRevenue = 0.0,
    this.todayCogs = 0.0,
    this.todayGrossProfit = 0.0,
    this.todayProfitMargin = 0.0,
    this.averageTransaction = 0.0,
    this.totalOrdersToday = 0,
    this.completedOrdersToday = 0,
    this.activeOrdersCount = 0,
    this.guestsToday = 0,
    this.statusBreakdown = const {},
    this.todayCash = 0.0,
    this.todayTransfer = 0.0,
    this.todayQris = 0.0,
    this.totalCollected = 0.0,
    this.totalTables = 0,
    this.occupiedTables = 0,
    this.availableTables = 0,
    this.occupancyRate = 0.0,
    this.lowStockCount = 0,
    this.recentOrders = const [],
    this.topSellingMenus = const [],
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final sales = json['sales'] is Map<String, dynamic> ? json['sales'] as Map<String, dynamic> : <String, dynamic>{};
    final orders = json['orders'] is Map<String, dynamic> ? json['orders'] as Map<String, dynamic> : <String, dynamic>{};
    final payments = json['payments'] is Map<String, dynamic> ? json['payments'] as Map<String, dynamic> : <String, dynamic>{};
    final tables = json['tables'] is Map<String, dynamic> ? json['tables'] as Map<String, dynamic> : <String, dynamic>{};
    final inventory = json['inventory_alerts'] is Map<String, dynamic> ? json['inventory_alerts'] as Map<String, dynamic> : <String, dynamic>{};

    final rawBreakdown = orders['status_breakdown'];
    final Map<String, int> parsedBreakdown = {};
    if (rawBreakdown is Map) {
      rawBreakdown.forEach((k, v) {
        parsedBreakdown[k.toString()] = (v is num) ? v.toInt() : (int.tryParse(v.toString()) ?? 0);
      });
    }

    final rawRecent = json['recent_orders'];
    final List<Map<String, dynamic>> parsedRecent = [];
    if (rawRecent is List) {
      for (final r in rawRecent) {
        if (r is Map<String, dynamic>) parsedRecent.add(r);
      }
    }

    final rawTop = json['top_selling_menus'];
    final List<TopMenuModel> parsedTop = [];
    if (rawTop is List) {
      for (final t in rawTop) {
        if (t is Map<String, dynamic>) {
          parsedTop.add(TopMenuModel.fromJson(t));
        }
      }
    }

    final double rev = (sales['today_revenue'] is num) ? (sales['today_revenue'] as num).toDouble() : 0.0;
    final int completed = (orders['completed_today'] is num) ? (orders['completed_today'] as num).toInt() : 0;
    final double avg = (sales['average_transaction'] is num)
        ? (sales['average_transaction'] as num).toDouble()
        : (completed > 0 ? (rev / completed) : 0.0);

    return DashboardSummaryModel(
      outletId: json['outlet_id'] is int ? json['outlet_id'] as int : (int.tryParse(json['outlet_id']?.toString() ?? '1') ?? 1),
      date: json['date']?.toString() ?? '',
      todayRevenue: rev,
      todayCogs: (sales['today_cogs'] is num) ? (sales['today_cogs'] as num).toDouble() : 0.0,
      todayGrossProfit: (sales['today_gross_profit'] is num) ? (sales['today_gross_profit'] as num).toDouble() : 0.0,
      todayProfitMargin: (sales['today_profit_margin'] is num) ? (sales['today_profit_margin'] as num).toDouble() : 0.0,
      averageTransaction: avg,
      totalOrdersToday: (orders['total_today'] is num) ? (orders['total_today'] as num).toInt() : 0,
      completedOrdersToday: completed,
      activeOrdersCount: (orders['active_orders'] is num) ? (orders['active_orders'] as num).toInt() : 0,
      guestsToday: (orders['guests_today'] is num) ? (orders['guests_today'] as num).toInt() : 0,
      statusBreakdown: parsedBreakdown,
      todayCash: (payments['today_cash'] is num) ? (payments['today_cash'] as num).toDouble() : 0.0,
      todayTransfer: (payments['today_transfer'] is num) ? (payments['today_transfer'] as num).toDouble() : 0.0,
      todayQris: (payments['today_qris'] is num) ? (payments['today_qris'] as num).toDouble() : 0.0,
      totalCollected: (payments['total_collected'] is num) ? (payments['total_collected'] as num).toDouble() : 0.0,
      totalTables: (tables['total_tables'] is num) ? (tables['total_tables'] as num).toInt() : 0,
      occupiedTables: (tables['occupied_tables'] is num) ? (tables['occupied_tables'] as num).toInt() : 0,
      availableTables: (tables['available_tables'] is num) ? (tables['available_tables'] as num).toInt() : 0,
      occupancyRate: (tables['occupancy_rate'] is num) ? (tables['occupancy_rate'] as num).toDouble() : 0.0,
      lowStockCount: (inventory['low_stock_count'] is num) ? (inventory['low_stock_count'] as num).toInt() : 0,
      recentOrders: parsedRecent,
      topSellingMenus: parsedTop,
    );
  }
}

