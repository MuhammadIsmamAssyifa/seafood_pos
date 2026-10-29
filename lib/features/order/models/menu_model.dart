import '../../inventory/models/stock_status.dart';

class MenuVariantModel {
  final int id;
  final String name;
  final double price;
  final String salesUnit;
  final String? ingredient;
  final String? station;
  final String? cookingMethod;
  final StockStatus stockStatus;
  final double? stockQuantity;
  final bool needMarketCheck;

  const MenuVariantModel({
    required this.id,
    required this.name,
    required this.price,
    this.salesUnit = 'portion',
    this.ingredient,
    this.station,
    this.cookingMethod,
    this.stockStatus = StockStatus.available,
    this.stockQuantity,
    this.needMarketCheck = false,
  });

  bool get isOutOfStock => stockStatus == StockStatus.outOfStock;
  bool get isLowStock => stockStatus == StockStatus.lowStock;
  bool get isNeedMarketCheck => stockStatus == StockStatus.needMarketCheck || needMarketCheck;
  bool get isAvailable => stockStatus == StockStatus.available;
  bool get canOrder => !isOutOfStock;

  factory MenuVariantModel.fromJson(Map<String, dynamic> json) {
    final needMarketCheck = json['need_market_check'] == true;
    final statusStr = json['stock_status']?.toString();
    final status = StockStatus.fromString(statusStr, needMarketCheck: needMarketCheck);

    double? qty;
    if (json['stock_quantity'] != null) {
      qty = (json['stock_quantity'] is num)
          ? (json['stock_quantity'] as num).toDouble()
          : double.tryParse(json['stock_quantity'].toString());
    }

    return MenuVariantModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      salesUnit: json['sales_unit']?.toString() ?? 'portion',
      ingredient: json['ingredient']?.toString(),
      station: json['station']?.toString(),
      cookingMethod: json['cooking_method']?.toString(),
      stockStatus: status,
      stockQuantity: qty,
      needMarketCheck: needMarketCheck,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'sales_unit': salesUnit,
      'ingredient': ingredient,
      'station': station,
      'cooking_method': cookingMethod,
      'stock_status': stockStatus.name,
      'stock_quantity': stockQuantity,
      'need_market_check': needMarketCheck,
    };
  }
}

class MenuModel {
  final int id;
  final String name;
  final String type;
  final StockStatus stockStatus;
  final double? stockQuantity;
  final bool needMarketCheck;
  final List<MenuVariantModel> variants;

  const MenuModel({
    required this.id,
    required this.name,
    required this.type,
    this.stockStatus = StockStatus.available,
    this.stockQuantity,
    this.needMarketCheck = false,
    this.variants = const [],
  });

  bool get isOutOfStock => stockStatus == StockStatus.outOfStock;
  bool get isLowStock => stockStatus == StockStatus.lowStock;
  bool get isNeedMarketCheck => stockStatus == StockStatus.needMarketCheck || needMarketCheck;
  bool get isAvailable => stockStatus == StockStatus.available;
  bool get canOrder => !isOutOfStock;

  MenuVariantModel? get primaryVariant => variants.isNotEmpty ? variants.first : null;
  double get minPrice => variants.isNotEmpty
      ? variants.map((v) => v.price).reduce((a, b) => a < b ? a : b)
      : 0.0;

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variants'];
    List<MenuVariantModel> parsedVariants = [];

    if (rawVariants is List) {
      parsedVariants = rawVariants
          .map((v) => MenuVariantModel.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    final needMarketCheck = json['need_market_check'] == true;
    final statusStr = json['stock_status']?.toString();
    final status = StockStatus.fromString(statusStr, needMarketCheck: needMarketCheck);

    double? qty;
    if (json['stock_quantity'] != null) {
      qty = (json['stock_quantity'] is num)
          ? (json['stock_quantity'] as num).toDouble()
          : double.tryParse(json['stock_quantity'].toString());
    }

    return MenuModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'food',
      stockStatus: status,
      stockQuantity: qty,
      needMarketCheck: needMarketCheck,
      variants: parsedVariants,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'stock_status': stockStatus.name,
      'stock_quantity': stockQuantity,
      'need_market_check': needMarketCheck,
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }
}
