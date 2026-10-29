class TopMenuModel {
  final int? variantId;
  final String menuName;
  final String? variantName;
  final String salesUnit;
  final double quantitySold;
  final double totalRevenue;
  final double? percentageOfSales;

  const TopMenuModel({
    this.variantId,
    required this.menuName,
    this.variantName,
    this.salesUnit = 'portion',
    this.quantitySold = 0.0,
    this.totalRevenue = 0.0,
    this.percentageOfSales,
  });

  String get displayName {
    if (variantName != null && variantName!.isNotEmpty && variantName != menuName) {
      return '$menuName ($variantName)';
    }
    return menuName;
  }

  factory TopMenuModel.fromJson(Map<String, dynamic> json) {
    return TopMenuModel(
      variantId: json['variant_id'] is int
          ? json['variant_id'] as int
          : (json['menu_variant_id'] is int ? json['menu_variant_id'] as int : null),
      menuName: json['menu_name']?.toString() ?? json['name']?.toString() ?? '',
      variantName: json['variant_name']?.toString(),
      salesUnit: json['sales_unit']?.toString() ?? 'portion',
      quantitySold: (json['quantity_sold'] is num)
          ? (json['quantity_sold'] as num).toDouble()
          : (json['total_qty'] is num ? (json['total_qty'] as num).toDouble() : 0.0),
      totalRevenue: (json['total_revenue'] is num)
          ? (json['total_revenue'] as num).toDouble()
          : (json['total_rev'] is num ? (json['total_rev'] as num).toDouble() : 0.0),
      percentageOfSales: (json['percentage_of_sales'] is num)
          ? (json['percentage_of_sales'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variant_id': variantId,
      'menu_name': menuName,
      'variant_name': variantName,
      'sales_unit': salesUnit,
      'quantity_sold': quantitySold,
      'total_revenue': totalRevenue,
      'percentage_of_sales': percentageOfSales,
    };
  }
}

