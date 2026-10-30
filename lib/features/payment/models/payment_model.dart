class PaymentModel {
  final int id;
  final int orderId;
  final String method;
  final String status;
  final double amount;
  final double? cashReceived;
  final double? changeAmount;
  final int? createdBy;
  final DateTime? paidAt;
  final DateTime? createdAt;

  const PaymentModel({
    required this.id,
    required this.orderId,
    required this.method,
    required this.status,
    required this.amount,
    this.cashReceived,
    this.changeAmount,
    this.createdBy,
    this.paidAt,
    this.createdAt,
  });

  bool get isCash => method.toLowerCase() == 'cash';
  bool get isTransfer => method.toLowerCase() == 'transfer';
  bool get isPaid => status.toLowerCase() == 'paid';

  String get methodLabel {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash (Tunai)';
      case 'transfer':
        return 'Transfer Bank';
      default:
        return method.toUpperCase();
    }
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderId: json['order_id'] is int ? json['order_id'] as int : int.tryParse(json['order_id']?.toString() ?? '0') ?? 0,
      method: json['method']?.toString() ?? 'cash',
      status: json['status']?.toString() ?? 'paid',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      cashReceived: json['cash_received'] != null
          ? ((json['cash_received'] is num)
              ? (json['cash_received'] as num).toDouble()
              : double.tryParse(json['cash_received'].toString()))
          : null,
      changeAmount: json['change_amount'] != null
          ? ((json['change_amount'] is num)
              ? (json['change_amount'] as num).toDouble()
              : double.tryParse(json['change_amount'].toString()))
          : null,
      createdBy: json['created_by'] is int ? json['created_by'] as int : int.tryParse(json['created_by']?.toString() ?? ''),
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'method': method,
      'status': status,
      'amount': amount,
      'cash_received': cashReceived,
      'change_amount': changeAmount,
      'created_by': createdBy,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

