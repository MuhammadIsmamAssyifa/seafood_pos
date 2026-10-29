class HistorySummary {
  final int totalOrders;
  final double totalRevenue;
  final int completedCount;
  final int cancelledCount;

  const HistorySummary({
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
    this.completedCount = 0,
    this.cancelledCount = 0,
  });

  factory HistorySummary.fromOrders(List<dynamic> orders) {
    int total = orders.length;
    double revenue = 0.0;
    int completed = 0;
    int cancelled = 0;

    for (final o in orders) {
      final status = o.status.toString().toLowerCase();
      if (status == 'completed') {
        completed++;
        revenue += (o.grandTotal as num).toDouble();
      } else if (status == 'cancelled') {
        cancelled++;
      } else {
        revenue += (o.grandTotal as num).toDouble();
      }
    }

    return HistorySummary(
      totalOrders: total,
      totalRevenue: revenue,
      completedCount: completed,
      cancelledCount: cancelled,
    );
  }
}

