class MenuVariantModel {
  final int id;
  final String name;
  final double price;
  final String salesUnit;
  final String? ingredient;
  final String? station;
  final String? cookingMethod;

  const MenuVariantModel({
    required this.id,
    required this.name,
    required this.price,
    this.salesUnit = 'portion',
    this.ingredient,
    this.station,
    this.cookingMethod,
  });

  factory MenuVariantModel.fromJson(Map<String, dynamic> json) {
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
    };
  }
}

class MenuModel {
  final int id;
  final String name;
  final String type;
  final List<MenuVariantModel> variants;

  const MenuModel({
    required this.id,
    required this.name,
    required this.type,
    this.variants = const [],
  });

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

    return MenuModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'food',
      variants: parsedVariants,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }
}

