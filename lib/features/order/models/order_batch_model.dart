import 'order_item_model.dart';

class OrderBatchModel {
  final int id;
  final int orderId;
  final int batchNumber;
  final String status;
  final DateTime? sentToKitchenAt;
  final DateTime? createdAt;
  final List<OrderItemModel> items;

  const OrderBatchModel({
    required this.id,
    required this.orderId,
    required this.batchNumber,
    this.status = 'waiting',
    this.sentToKitchenAt,
    this.createdAt,
    this.items = const [],
  });

  bool get isWaiting => status.toLowerCase() == 'waiting';
  bool get isSent => status.toLowerCase() == 'sent';
  bool get isCooking => status.toLowerCase() == 'cooking' || status.toLowerCase() == 'preparing';
  bool get isReady => status.toLowerCase() == 'ready';
  bool get allItemsServed => items.isNotEmpty && items.every((i) => i.isServed);
  bool get isServed => status.toLowerCase() == 'served' || status.toLowerCase() == 'completed' || allItemsServed;
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  String get effectiveStatus {
    if (allItemsServed) return 'served';
    return status;
  }

  int get itemCount => items.fold(0, (sum, i) => sum + (i.quantity > 0 && i.quantity < 1.0 ? 1 : i.quantity.toInt()));
  String get displayName => 'Batch $batchNumber';

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'waiting':
        return 'Menunggu Kirim';
      case 'sent':
        return 'Terkirim ke Kitchen';
      case 'cooking':
      case 'preparing':
        return 'Sedang Dimasak';
      case 'ready':
        return 'Siap Saji';
      case 'completed':
      case 'served':
        return 'Sudah Disajikan';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status.toUpperCase();
    }
  }

  int get progressIndex {
    switch (status.toLowerCase()) {
      case 'waiting':
        return 0;
      case 'sent':
        return 1;
      case 'cooking':
      case 'preparing':
        return 2;
      case 'ready':
        return 3;
      case 'completed':
      case 'served':
        return 4;
      default:
        return 0;
    }
  }

  factory OrderBatchModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemModel> parsedItems = [];
    if (json['items'] is List) {
      for (var item in json['items']) {
        if (item is Map<String, dynamic>) {
          parsedItems.add(OrderItemModel.fromJson(item));
        }
      }
    }

    return OrderBatchModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderId: json['order_id'] is int ? json['order_id'] as int : int.tryParse(json['order_id']?.toString() ?? '0') ?? 0,
      batchNumber: json['batch_number'] is int ? json['batch_number'] as int : int.tryParse(json['batch_number']?.toString() ?? '1') ?? 1,
      status: json['status']?.toString() ?? 'waiting',
      sentToKitchenAt: json['sent_to_kitchen_at'] != null ? DateTime.tryParse(json['sent_to_kitchen_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'batch_number': batchNumber,
      'status': status,
      'sent_to_kitchen_at': sentToKitchenAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  OrderBatchModel copyWith({
    int? id,
    int? orderId,
    int? batchNumber,
    String? status,
    DateTime? sentToKitchenAt,
    DateTime? createdAt,
    List<OrderItemModel>? items,
  }) {
    return OrderBatchModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      batchNumber: batchNumber ?? this.batchNumber,
      status: status ?? this.status,
      sentToKitchenAt: sentToKitchenAt ?? this.sentToKitchenAt,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}

