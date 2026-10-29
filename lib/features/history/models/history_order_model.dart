import '../../order/models/order_batch_model.dart';
import '../../order/models/order_item_model.dart';
import '../../order_adjustment/models/adjustment_model.dart';
import '../../payment/models/payment_model.dart';

class HistoryOrderModel {
  final int id;
  final String orderNumber;
  final String customerName;
  final String? tableNumber;
  final int guestCount;
  final String status;
  final double subtotal;
  final double discount;
  final double grandTotal;
  final List<OrderItemModel> items;
  final List<OrderBatchModel> batches;
  final List<PaymentModel> payments;
  final List<AdjustmentModel> adjustments;
  final DateTime? createdAt;

  const HistoryOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    this.tableNumber,
    this.guestCount = 1,
    required this.status,
    required this.subtotal,
    this.discount = 0.0,
    required this.grandTotal,
    this.items = const [],
    this.batches = const [],
    this.payments = const [],
    this.adjustments = const [],
    this.createdAt,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isDraft => status.toLowerCase() == 'draft';
  bool get isReady => status.toLowerCase() == 'ready';
  bool get isPreparing => status.toLowerCase() == 'preparing';

  int get totalItemCount {
    if (items.isNotEmpty) {
      return items.fold(0, (sum, item) => sum + (item.quantity > 0 && item.quantity < 1.0 ? 1 : item.quantity.toInt()));
    }
    return batches.fold(0, (sum, b) => sum + b.itemCount);
  }

  factory HistoryOrderModel.fromJson(Map<String, dynamic> json) {
    // 1. Table
    String? tableNum;
    if (json['table'] != null && json['table'] is Map<String, dynamic>) {
      tableNum = json['table']['number']?.toString();
    } else if (json['table_number'] != null) {
      tableNum = json['table_number'].toString();
    }

    // 2. Batches & Items
    List<OrderBatchModel> parsedBatches = [];
    List<OrderItemModel> parsedItems = [];

    if (json['batches'] != null && json['batches'] is List) {
      parsedBatches = (json['batches'] as List)
          .map((b) => OrderBatchModel.fromJson(b as Map<String, dynamic>))
          .toList();
      for (final b in parsedBatches) {
        parsedItems.addAll(b.items);
      }
    } else if (json['items'] != null && json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    // 3. Payments
    List<PaymentModel> parsedPayments = [];
    if (json['payments'] != null && json['payments'] is List) {
      parsedPayments = (json['payments'] as List)
          .map((p) => PaymentModel.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    // 4. Adjustments
    List<AdjustmentModel> parsedAdjustments = [];
    if (json['adjustments'] != null && json['adjustments'] is List) {
      parsedAdjustments = (json['adjustments'] as List)
          .map((a) => AdjustmentModel.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    return HistoryOrderModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderNumber: json['order_number']?.toString() ?? '#ORD-${json['id']}',
      customerName: json['customer_name']?.toString() ?? 'Pelanggan',
      tableNumber: tableNum,
      guestCount: json['guest_count'] is int ? json['guest_count'] as int : int.tryParse(json['guest_count']?.toString() ?? '1') ?? 1,
      status: json['status']?.toString() ?? 'draft',
      subtotal: (json['subtotal'] is num)
          ? (json['subtotal'] as num).toDouble()
          : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      discount: (json['discount'] is num)
          ? (json['discount'] as num).toDouble()
          : double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      grandTotal: (json['grand_total'] is num)
          ? (json['grand_total'] as num).toDouble()
          : double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0.0,
      items: parsedItems,
      batches: parsedBatches,
      payments: parsedPayments,
      adjustments: parsedAdjustments,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  HistoryOrderModel copyWith({
    List<PaymentModel>? payments,
    List<AdjustmentModel>? adjustments,
  }) {
    return HistoryOrderModel(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName,
      tableNumber: tableNumber,
      guestCount: guestCount,
      status: status,
      subtotal: subtotal,
      discount: discount,
      grandTotal: grandTotal,
      items: items,
      batches: batches,
      payments: payments ?? this.payments,
      adjustments: adjustments ?? this.adjustments,
      createdAt: createdAt,
    );
  }
}

