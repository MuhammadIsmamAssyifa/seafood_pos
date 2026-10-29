import 'stock_status.dart';

class StockInfoModel {
  final int menuId;
  final String menuName;
  final int? variantId;
  final String? variantName;
  final StockStatus stockStatus;
  final double? stockQuantity;
  final String salesUnit;
  final bool needMarketCheck;
  final String? ingredientName;
  final String? station;

  const StockInfoModel({
    required this.menuId,
    required this.menuName,
    this.variantId,
    this.variantName,
    this.stockStatus = StockStatus.available,
    this.stockQuantity,
    this.salesUnit = 'portion',
    this.needMarketCheck = false,
    this.ingredientName,
    this.station,
  });

  bool get isOutOfStock => stockStatus == StockStatus.outOfStock;
  bool get isLowStock => stockStatus == StockStatus.lowStock;
  bool get isNeedMarketCheck => stockStatus == StockStatus.needMarketCheck || needMarketCheck;
  bool get isAvailable => stockStatus == StockStatus.available;
  bool get canOrder => !isOutOfStock;

  factory StockInfoModel.fromMenuJson(Map<String, dynamic> json) {
    final needMarketCheck = json['need_market_check'] == true;
    final statusStr = json['stock_status']?.toString();
    final status = StockStatus.fromString(statusStr, needMarketCheck: needMarketCheck);

    double? quantity;
    if (json['stock_quantity'] != null) {
      quantity = (json['stock_quantity'] is num)
          ? (json['stock_quantity'] as num).toDouble()
          : double.tryParse(json['stock_quantity'].toString());
    }

    return StockInfoModel(
      menuId: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      menuName: json['name']?.toString() ?? '',
      stockStatus: status,
      stockQuantity: quantity,
      needMarketCheck: needMarketCheck,
    );
  }

  factory StockInfoModel.fromVariantJson(Map<String, dynamic> json, {required int menuId, required String menuName}) {
    final needMarketCheck = json['need_market_check'] == true;
    final statusStr = json['stock_status']?.toString();
    final status = StockStatus.fromString(statusStr, needMarketCheck: needMarketCheck);

    double? quantity;
    if (json['stock_quantity'] != null) {
      quantity = (json['stock_quantity'] is num)
          ? (json['stock_quantity'] as num).toDouble()
          : double.tryParse(json['stock_quantity'].toString());
    }

    return StockInfoModel(
      menuId: menuId,
      menuName: menuName,
      variantId: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      variantName: json['name']?.toString() ?? '',
      stockStatus: status,
      stockQuantity: quantity,
      salesUnit: json['sales_unit']?.toString() ?? 'portion',
      needMarketCheck: needMarketCheck,
      ingredientName: json['ingredient']?.toString(),
      station: json['station']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'menu_name': menuName,
      'variant_id': variantId,
      'variant_name': variantName,
      'stock_status': stockStatus.name,
      'stock_quantity': stockQuantity,
      'sales_unit': salesUnit,
      'need_market_check': needMarketCheck,
      'ingredient_name': ingredientName,
      'station': station,
    };
  }
}

