import 'order_item_model.dart';

class OrderModel {
  final int id;
  final int? outletId;
  final int? orderTableId;
  final String orderNumber;
  final String? customerName;
  final int guestCount;
  final String status;
  final double subtotal;
  final double discount;
  final double grandTotal;
  final String? tableNumber;
  final List<OrderItemModel> items;
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    this.outletId,
    this.orderTableId,
    required this.orderNumber,
    this.customerName,
    this.guestCount = 1,
    this.status = 'draft',
    this.subtotal = 0.0,
    this.discount = 0.0,
    this.grandTotal = 0.0,
    this.tableNumber,
    this.items = const [],
    this.createdAt,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity.toInt());
  bool get isDraft => status.toLowerCase() == 'draft';
  bool get isEmpty => items.isEmpty;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    // Flatten items from batches
    List<OrderItemModel> extractedItems = [];
    if (data['batches'] is List) {
      for (var batch in data['batches']) {
        if (batch is Map<String, dynamic> && batch['items'] is List) {
          for (var item in batch['items']) {
            if (item is Map<String, dynamic>) {
              extractedItems.add(OrderItemModel.fromJson(item));
            }
          }
        }
      }
    } else if (data['items'] is List) {
      for (var item in data['items']) {
        if (item is Map<String, dynamic>) {
          extractedItems.add(OrderItemModel.fromJson(item));
        }
      }
    }

    String? tableNum;
    if (data['table'] is Map<String, dynamic>) {
      tableNum = data['table']['number']?.toString();
    } else if (data['order_table'] is Map<String, dynamic>) {
      tableNum = data['order_table']['number']?.toString();
    }

    return OrderModel(
      id: data['id'] is int ? data['id'] as int : int.tryParse(data['id']?.toString() ?? '0') ?? 0,
      outletId: data['outlet_id'] is int ? data['outlet_id'] as int : int.tryParse(data['outlet_id']?.toString() ?? ''),
      orderTableId: data['order_table_id'] is int ? data['order_table_id'] as int : int.tryParse(data['order_table_id']?.toString() ?? ''),
      orderNumber: data['order_number']?.toString() ?? '#ORD-${data['id']}',
      customerName: data['customer_name']?.toString(),
      guestCount: data['guest_count'] is int ? data['guest_count'] as int : int.tryParse(data['guest_count']?.toString() ?? '1') ?? 1,
      status: data['status']?.toString() ?? 'draft',
      subtotal: (data['subtotal'] is num) ? (data['subtotal'] as num).toDouble() : double.tryParse(data['subtotal']?.toString() ?? '0') ?? 0.0,
      discount: (data['discount'] is num) ? (data['discount'] as num).toDouble() : double.tryParse(data['discount']?.toString() ?? '0') ?? 0.0,
      grandTotal: (data['grand_total'] is num) ? (data['grand_total'] as num).toDouble() : double.tryParse(data['grand_total']?.toString() ?? '0') ?? 0.0,
      tableNumber: tableNum,
      items: extractedItems,
      createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outlet_id': outletId,
      'order_table_id': orderTableId,
      'order_number': orderNumber,
      'customer_name': customerName,
      'guest_count': guestCount,
      'status': status,
      'subtotal': subtotal,
      'discount': discount,
      'grand_total': grandTotal,
      'table_number': tableNumber,
      'items': items.map((i) => i.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    int? id,
    int? outletId,
    int? orderTableId,
    String? orderNumber,
    String? customerName,
    int? guestCount,
    String? status,
    double? subtotal,
    double? discount,
    double? grandTotal,
    String? tableNumber,
    List<OrderItemModel>? items,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      outletId: outletId ?? this.outletId,
      orderTableId: orderTableId ?? this.orderTableId,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      guestCount: guestCount ?? this.guestCount,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      grandTotal: grandTotal ?? this.grandTotal,
      tableNumber: tableNumber ?? this.tableNumber,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

