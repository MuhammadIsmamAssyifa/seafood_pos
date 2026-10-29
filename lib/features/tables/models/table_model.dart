import 'table_status.dart';

class ActiveOrderSummary {
  final int id;
  final String orderNumber;
  final String? customerName;
  final int guestCount;
  final String status;
  final double subtotal;
  final double grandTotal;
  final DateTime? createdAt;

  const ActiveOrderSummary({
    required this.id,
    required this.orderNumber,
    this.customerName,
    this.guestCount = 1,
    required this.status,
    this.subtotal = 0.0,
    this.grandTotal = 0.0,
    this.createdAt,
  });

  factory ActiveOrderSummary.fromJson(Map<String, dynamic> json) {
    return ActiveOrderSummary(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderNumber: json['order_number']?.toString() ?? '#ORD-${json['id']}',
      customerName: json['customer_name']?.toString(),
      guestCount: json['guest_count'] is int
          ? json['guest_count'] as int
          : int.tryParse(json['guest_count']?.toString() ?? '1') ?? 1,
      status: json['status']?.toString() ?? 'draft',
      subtotal: (json['subtotal'] is num)
          ? (json['subtotal'] as num).toDouble()
          : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      grandTotal: (json['grand_total'] is num)
          ? (json['grand_total'] as num).toDouble()
          : double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_name': customerName,
      'guest_count': guestCount,
      'status': status,
      'subtotal': subtotal,
      'grand_total': grandTotal,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class TableModel {
  final int id;
  final String number;
  final TableStatus status;
  final int? outletId;
  final ActiveOrderSummary? activeOrder;

  const TableModel({
    required this.id,
    required this.number,
    this.status = TableStatus.available,
    this.outletId,
    this.activeOrder,
  });

  bool get isAvailable => activeOrder == null && status != TableStatus.occupied;
  bool get isOccupied => activeOrder != null;

  String get displayName => 'Meja $number';

  factory TableModel.fromJson(Map<String, dynamic> json) {
    ActiveOrderSummary? orderSummary;
    if (json['active_order'] is Map<String, dynamic>) {
      orderSummary = ActiveOrderSummary.fromJson(json['active_order'] as Map<String, dynamic>);
    }

    final rawStatus = json['status']?.toString();
    final tableStatus = TableStatus.fromString(rawStatus);

    final resolvedStatus = orderSummary != null
        ? TableStatus.occupied
        : (tableStatus == TableStatus.occupied ? TableStatus.available : tableStatus);

    return TableModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      number: json['number']?.toString() ?? '${json['id']}',
      status: resolvedStatus,
      outletId: json['outlet_id'] is int ? json['outlet_id'] as int : int.tryParse(json['outlet_id']?.toString() ?? ''),
      activeOrder: orderSummary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'status': status.name,
      'outlet_id': outletId,
      'active_order': activeOrder?.toJson(),
    };
  }

  TableModel copyWith({
    int? id,
    String? number,
    TableStatus? status,
    int? outletId,
    ActiveOrderSummary? activeOrder,
  }) {
    return TableModel(
      id: id ?? this.id,
      number: number ?? this.number,
      status: status ?? this.status,
      outletId: outletId ?? this.outletId,
      activeOrder: activeOrder ?? this.activeOrder,
    );
  }
}

