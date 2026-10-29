enum HistoryDateRange {
  all('all', 'Semua'),
  today('today', 'Hari Ini'),
  yesterday('yesterday', 'Kemarin'),
  last7Days('last7days', '7 Hari Terakhir'),
  last30Days('last30days', '30 Hari Terakhir'),
  custom('custom', 'Pilih Tanggal');

  final String value;
  final String label;

  const HistoryDateRange(this.value, this.label);
}

class HistoryFilter {
  final String? status;
  final HistoryDateRange dateRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;

  const HistoryFilter({
    this.status,
    this.dateRange = HistoryDateRange.all,
    this.startDate,
    this.endDate,
    this.searchQuery = '',
  });

  bool get hasActiveFilter =>
      (status != null && status!.isNotEmpty) ||
      dateRange != HistoryDateRange.all ||
      searchQuery.isNotEmpty;

  HistoryFilter copyWith({
    String? status,
    bool clearStatus = false,
    HistoryDateRange? dateRange,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return HistoryFilter(
      status: clearStatus ? null : (status ?? this.status),
      dateRange: dateRange ?? this.dateRange,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  Map<String, dynamic> toQueryParams({int page = 1, int perPage = 20}) {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (status != null && status!.isNotEmpty) {
      params['status'] = status;
    }

    if (searchQuery.trim().isNotEmpty) {
      params['search'] = searchQuery.trim();
    }

    final now = DateTime.now();

    switch (dateRange) {
      case HistoryDateRange.today:
        final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        params['date'] = todayStr;
        break;
      case HistoryDateRange.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
        params['date'] = yesterdayStr;
        break;
      case HistoryDateRange.last7Days:
        final start7 = now.subtract(const Duration(days: 7));
        params['start_date'] = '${start7.year}-${start7.month.toString().padLeft(2, '0')}-${start7.day.toString().padLeft(2, '0')}';
        break;
      case HistoryDateRange.last30Days:
        final start30 = now.subtract(const Duration(days: 30));
        params['start_date'] = '${start30.year}-${start30.month.toString().padLeft(2, '0')}-${start30.day.toString().padLeft(2, '0')}';
        break;
      case HistoryDateRange.custom:
        if (startDate != null) {
          params['start_date'] = '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
        }
        if (endDate != null) {
          params['end_date'] = '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
        }
        break;
      case HistoryDateRange.all:
        break;
    }

    return params;
  }
}

