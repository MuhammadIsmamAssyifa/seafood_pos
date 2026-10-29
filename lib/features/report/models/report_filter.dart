enum ReportPeriod {
  today,
  yesterday,
  last7Days,
  last30Days,
  custom;

  String get label {
    switch (this) {
      case ReportPeriod.today:
        return 'Hari Ini';
      case ReportPeriod.yesterday:
        return 'Kemarin';
      case ReportPeriod.last7Days:
        return '7 Hari';
      case ReportPeriod.last30Days:
        return '30 Hari';
      case ReportPeriod.custom:
        return 'Custom Range';
    }
  }
}

class ReportFilter {
  final ReportPeriod period;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const ReportFilter({
    this.period = ReportPeriod.today,
    this.customStartDate,
    this.customEndDate,
  });

  DateTime get startDate {
    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.today:
        return DateTime(now.year, now.month, now.day);
      case ReportPeriod.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTime(yesterday.year, yesterday.month, yesterday.day);
      case ReportPeriod.last7Days:
        final date = now.subtract(const Duration(days: 6));
        return DateTime(date.year, date.month, date.day);
      case ReportPeriod.last30Days:
        final date = now.subtract(const Duration(days: 29));
        return DateTime(date.year, date.month, date.day);
      case ReportPeriod.custom:
        return customStartDate ?? DateTime(now.year, now.month, now.day);
    }
  }

  DateTime get endDate {
    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.today:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case ReportPeriod.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
      case ReportPeriod.last7Days:
      case ReportPeriod.last30Days:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case ReportPeriod.custom:
        return customEndDate != null
            ? DateTime(customEndDate!.year, customEndDate!.month, customEndDate!.day, 23, 59, 59)
            : DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
  }

  String _formatDate(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Map<String, dynamic> toQueryParams() {
    return {
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
    };
  }

  ReportFilter copyWith({
    ReportPeriod? period,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return ReportFilter(
      period: period ?? this.period,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }
}

