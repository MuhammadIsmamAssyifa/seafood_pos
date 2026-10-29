class DailySalesTrendModel {
  final String date;
  final int totalOrders;
  final double grossSales;
  final double discounts;
  final double netSales;

  const DailySalesTrendModel({
    required this.date,
    this.totalOrders = 0,
    this.grossSales = 0.0,
    this.discounts = 0.0,
    this.netSales = 0.0,
  });

  factory DailySalesTrendModel.fromJson(Map<String, dynamic> json) {
    return DailySalesTrendModel(
      date: json['date']?.toString() ?? '',
      totalOrders: (json['total_orders'] is num) ? (json['total_orders'] as num).toInt() : 0,
      grossSales: (json['gross_sales'] is num) ? (json['gross_sales'] as num).toDouble() : 0.0,
      discounts: (json['discounts'] is num) ? (json['discounts'] as num).toDouble() : 0.0,
      netSales: (json['net_sales'] is num) ? (json['net_sales'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total_orders': totalOrders,
      'gross_sales': grossSales,
      'discounts': discounts,
      'net_sales': netSales,
    };
  }
}

class SalesReportModel {
  final int outletId;
  final String startDate;
  final String endDate;
  final int totalOrders;
  final int totalGuests;
  final double grossSales;
  final double totalDiscounts;
  final double netSales;
  final double averageOrderValue;
  final double averageSpendPerGuest;
  final List<DailySalesTrendModel> dailyTrends;

  const SalesReportModel({
    required this.outletId,
    required this.startDate,
    required this.endDate,
    this.totalOrders = 0,
    this.totalGuests = 0,
    this.grossSales = 0.0,
    this.totalDiscounts = 0.0,
    this.netSales = 0.0,
    this.averageOrderValue = 0.0,
    this.averageSpendPerGuest = 0.0,
    this.dailyTrends = const [],
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] is Map<String, dynamic> ? json['summary'] as Map<String, dynamic> : <String, dynamic>{};
    final rawTrends = json['daily_trends'];
    final List<DailySalesTrendModel> parsedTrends = [];

    if (rawTrends is List) {
      for (final t in rawTrends) {
        if (t is Map<String, dynamic>) {
          parsedTrends.add(DailySalesTrendModel.fromJson(t));
        }
      }
    }

    return SalesReportModel(
      outletId: json['outlet_id'] is int ? json['outlet_id'] as int : (int.tryParse(json['outlet_id']?.toString() ?? '1') ?? 1),
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      totalOrders: (summary['total_orders'] is num) ? (summary['total_orders'] as num).toInt() : 0,
      totalGuests: (summary['total_guests'] is num) ? (summary['total_guests'] as num).toInt() : 0,
      grossSales: (summary['gross_sales'] is num) ? (summary['gross_sales'] as num).toDouble() : 0.0,
      totalDiscounts: (summary['total_discounts'] is num) ? (summary['total_discounts'] as num).toDouble() : 0.0,
      netSales: (summary['net_sales'] is num) ? (summary['net_sales'] as num).toDouble() : 0.0,
      averageOrderValue: (summary['average_order_value'] is num) ? (summary['average_order_value'] as num).toDouble() : 0.0,
      averageSpendPerGuest: (summary['average_spend_per_guest'] is num) ? (summary['average_spend_per_guest'] as num).toDouble() : 0.0,
      dailyTrends: parsedTrends,
    );
  }
}

