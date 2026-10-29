class PaymentMethodBreakdownModel {
  final String method;
  final double totalAmount;
  final int transactionCount;
  final double percentage;

  const PaymentMethodBreakdownModel({
    required this.method,
    this.totalAmount = 0.0,
    this.transactionCount = 0,
    this.percentage = 0.0,
  });

  String get methodLabel {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Tunai (Cash)';
      case 'transfer':
        return 'Transfer Bank';
      case 'qris':
        return 'QRIS';
      case 'card':
      case 'edc':
        return 'Debit / Kartu';
      default:
        return method.toUpperCase();
    }
  }

  factory PaymentMethodBreakdownModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodBreakdownModel(
      method: json['method']?.toString() ?? 'other',
      totalAmount: (json['total_amount'] is num) ? (json['total_amount'] as num).toDouble() : 0.0,
      transactionCount: (json['transaction_count'] is num) ? (json['transaction_count'] as num).toInt() : 0,
      percentage: (json['percentage'] is num) ? (json['percentage'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'total_amount': totalAmount,
      'transaction_count': transactionCount,
      'percentage': percentage,
    };
  }
}

class PaymentSummaryModel {
  final int outletId;
  final String startDate;
  final String endDate;
  final double totalCollected;
  final int totalTransactions;
  final List<PaymentMethodBreakdownModel> methodBreakdown;

  const PaymentSummaryModel({
    required this.outletId,
    required this.startDate,
    required this.endDate,
    this.totalCollected = 0.0,
    this.totalTransactions = 0,
    this.methodBreakdown = const [],
  });

  double get cashTotal {
    final cash = methodBreakdown.firstWhere(
      (m) => m.method.toLowerCase() == 'cash',
      orElse: () => const PaymentMethodBreakdownModel(method: 'cash'),
    );
    return cash.totalAmount;
  }

  double get transferTotal {
    final transfer = methodBreakdown.firstWhere(
      (m) => m.method.toLowerCase() == 'transfer',
      orElse: () => const PaymentMethodBreakdownModel(method: 'transfer'),
    );
    return transfer.totalAmount;
  }

  double get qrisTotal {
    final qris = methodBreakdown.firstWhere(
      (m) => m.method.toLowerCase() == 'qris',
      orElse: () => const PaymentMethodBreakdownModel(method: 'qris'),
    );
    return qris.totalAmount;
  }

  factory PaymentSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] is Map<String, dynamic> ? json['summary'] as Map<String, dynamic> : <String, dynamic>{};
    final rawBreakdown = json['method_breakdown'];
    final List<PaymentMethodBreakdownModel> parsedBreakdown = [];

    if (rawBreakdown is List) {
      for (final b in rawBreakdown) {
        if (b is Map<String, dynamic>) {
          parsedBreakdown.add(PaymentMethodBreakdownModel.fromJson(b));
        }
      }
    }

    return PaymentSummaryModel(
      outletId: json['outlet_id'] is int ? json['outlet_id'] as int : (int.tryParse(json['outlet_id']?.toString() ?? '1') ?? 1),
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      totalCollected: (summary['total_collected'] is num) ? (summary['total_collected'] as num).toDouble() : 0.0,
      totalTransactions: (summary['total_transactions'] is num) ? (summary['total_transactions'] as num).toInt() : 0,
      methodBreakdown: parsedBreakdown,
    );
  }
}

