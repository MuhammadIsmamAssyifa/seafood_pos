class OrderItemModel {
  final int id;
  final int? orderBatchId;
  final int menuVariantId;
  final String menuName;
  final String? variantName;
  final double quantity;
  final String unit;
  final double price;
  final double subtotal;
  final String status;

  const OrderItemModel({
    required this.id,
    this.orderBatchId,
    required this.menuVariantId,
    required this.menuName,
    this.variantName,
    required this.quantity,
    this.unit = 'portion',
    required this.price,
    required this.subtotal,
    this.status = 'draft',
  });

  String get displayName => variantName != null && variantName!.isNotEmpty && variantName != menuName
      ? '$menuName ($variantName)'
      : menuName;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderBatchId: json['order_batch_id'] is int
          ? json['order_batch_id'] as int
          : int.tryParse(json['order_batch_id']?.toString() ?? ''),
      menuVariantId: json['menu_variant_id'] is int
          ? json['menu_variant_id'] as int
          : int.tryParse(json['menu_variant_id']?.toString() ?? '0') ?? 0,
      menuName: json['menu_name']?.toString() ?? json['name']?.toString() ?? '',
      variantName: json['variant_name']?.toString(),
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toDouble()
          : double.tryParse(json['quantity']?.toString() ?? '1') ?? 1.0,
      unit: json['unit']?.toString() ?? json['sales_unit']?.toString() ?? 'portion',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : (json['price_snapshot'] is num)
              ? (json['price_snapshot'] as num).toDouble()
              : double.tryParse(json['price']?.toString() ?? json['price_snapshot']?.toString() ?? '0') ?? 0.0,
      subtotal: (json['subtotal'] is num)
          ? (json['subtotal'] as num).toDouble()
          : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'draft',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_batch_id': orderBatchId,
      'menu_variant_id': menuVariantId,
      'menu_name': menuName,
      'variant_name': variantName,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'subtotal': subtotal,
      'status': status,
    };
  }

  OrderItemModel copyWith({
    int? id,
    int? orderBatchId,
    int? menuVariantId,
    String? menuName,
    String? variantName,
    double? quantity,
    String? unit,
    double? price,
    double? subtotal,
    String? status,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderBatchId: orderBatchId ?? this.orderBatchId,
      menuVariantId: menuVariantId ?? this.menuVariantId,
      menuName: menuName ?? this.menuName,
      variantName: variantName ?? this.variantName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
      status: status ?? this.status,
    );
  }
}

