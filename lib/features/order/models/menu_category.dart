class MenuCategory {
  final String id;
  final String name;

  const MenuCategory({
    required this.id,
    required this.name,
  });

  static const List<MenuCategory> defaultCategories = [
    MenuCategory(id: 'all', name: 'Semua'),
    MenuCategory(id: 'seafood', name: 'Seafood'),
    MenuCategory(id: 'food', name: 'Makanan'),
    MenuCategory(id: 'drink', name: 'Minuman'),
    MenuCategory(id: 'snack', name: 'Camilan'),
  ];
}

