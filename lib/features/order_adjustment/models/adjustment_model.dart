import '../../order/models/order_item_model.dart';
import 'adjustment_status.dart';
import 'adjustment_type.dart';

class AdjustmentModel {
  final int id;
  final int orderItemId;
  final AdjustmentType type;
  final AdjustmentStatus status;
  final String reason;
  final double oldQuantity;
  final double oldPrice;
  final double? newQuantity;
  final double? newPrice;
  final int? replacementItemId;
  final OrderItemModel? replacementItem;
  final OrderItemModel? orderItem;
  final dynamic createdBy;
  final DateTime? createdAt;

  const AdjustmentModel({
    required this.id,
    required this.orderItemId,
    required this.type,
    required this.status,
    required this.reason,
    required this.oldQuantity,
    required this.oldPrice,
    this.newQuantity,
    this.newPrice,
    this.replacementItemId,
    this.replacementItem,
    this.orderItem,
    this.createdBy,
    this.createdAt,
  });

  bool get isPending => status == AdjustmentStatus.pendingCustomer;
  bool get isApproved => status == AdjustmentStatus.approved;
  bool get isRejected => status == AdjustmentStatus.rejected;

  String get itemName => orderItem?.displayName ?? 'Item #$orderItemId';
  String get unit => orderItem?.unit ?? 'portion';

  double get oldSubtotal => oldQuantity * oldPrice;
  double get effectiveNewQuantity => newQuantity ?? oldQuantity;
  double get effectiveNewPrice => newPrice ?? oldPrice;
  double get newSubtotal {
    if (type == AdjustmentType.cancel) return 0.0;
    if (type == AdjustmentType.replace && replacementItem != null) {
      return replacementItem!.subtotal;
    }
    return effectiveNewQuantity * effectiveNewPrice;
  }

  factory AdjustmentModel.fromJson(Map<String, dynamic> json) {
    return AdjustmentModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderItemId: json['order_item_id'] is int
          ? json['order_item_id'] as int
          : int.tryParse(json['order_item_id']?.toString() ?? '0') ?? 0,
      type: AdjustmentType.fromString(json['type']?.toString()),
      status: AdjustmentStatus.fromString(json['status']?.toString()),
      reason: json['reason']?.toString() ?? '',
      oldQuantity: (json['old_quantity'] is num)
          ? (json['old_quantity'] as num).toDouble()
          : double.tryParse(json['old_quantity']?.toString() ?? '0') ?? 0.0,
      oldPrice: (json['old_price'] is num)
          ? (json['old_price'] as num).toDouble()
          : double.tryParse(json['old_price']?.toString() ?? '0') ?? 0.0,
      newQuantity: (json['new_quantity'] is num)
          ? (json['new_quantity'] as num).toDouble()
          : double.tryParse(json['new_quantity']?.toString() ?? ''),
      newPrice: (json['new_price'] is num)
          ? (json['new_price'] as num).toDouble()
          : double.tryParse(json['new_price']?.toString() ?? ''),
      replacementItemId: json['replacement_item_id'] is int
          ? json['replacement_item_id'] as int
          : int.tryParse(json['replacement_item_id']?.toString() ?? ''),
      replacementItem: json['replacement_item'] is Map<String, dynamic>
          ? OrderItemModel.fromJson(json['replacement_item'] as Map<String, dynamic>)
          : null,
      orderItem: json['order_item'] is Map<String, dynamic>
          ? OrderItemModel.fromJson(json['order_item'] as Map<String, dynamic>)
          : null,
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_item_id': orderItemId,
      'type': type.value,
      'status': status.value,
      'reason': reason,
      'old_quantity': oldQuantity,
      'old_price': oldPrice,
      'new_quantity': newQuantity,
      'new_price': newPrice,
      'replacement_item_id': replacementItemId,
      'replacement_item': replacementItem?.toJson(),
      'order_item': orderItem?.toJson(),
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

