class PaymentSummaryModel {
  final int orderId;
  final double grandTotal;
  final double paid;
  final double remaining;

  const PaymentSummaryModel({
    required this.orderId,
    required this.grandTotal,
    required this.paid,
    required this.remaining,
  });

  bool get isFullyPaid => remaining <= 0;
  bool get hasPartialPayment => paid > 0 && remaining > 0;
  double get paymentProgress => grandTotal > 0 ? (paid / grandTotal).clamp(0.0, 1.0) : 0.0;

  factory PaymentSummaryModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json;

    return PaymentSummaryModel(
      orderId: data['order_id'] is int
          ? data['order_id'] as int
          : int.tryParse(data['order_id']?.toString() ?? '0') ?? 0,
      grandTotal: (data['grand_total'] is num)
          ? (data['grand_total'] as num).toDouble()
          : double.tryParse(data['grand_total']?.toString() ?? '0') ?? 0.0,
      paid: (data['paid'] is num)
          ? (data['paid'] as num).toDouble()
          : double.tryParse(data['paid']?.toString() ?? '0') ?? 0.0,
      remaining: (data['remaining'] is num)
          ? (data['remaining'] as num).toDouble()
          : double.tryParse(data['remaining']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'grand_total': grandTotal,
      'paid': paid,
      'remaining': remaining,
    };
  }
}

