import 'package:get/get.dart';
import '../../inventory/models/stock_status.dart';
import '../../order/models/menu_model.dart';
import '../../order/repositories/order_repository.dart';

class MenuCatalogController extends GetxController {
  final OrderRepository orderRepository;

  MenuCatalogController({required this.orderRepository});

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<MenuModel> menus = <MenuModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedType = 'all'.obs;
  final Rxn<StockStatus> selectedStockFilter = Rxn<StockStatus>();

  @override
  void onInit() {
    super.onInit();
    loadMenus();
  }

  /// Load menu data from API
  Future<void> loadMenus({bool forceRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await orderRepository.getMenus(forceRefresh: forceRefresh);
      if (response.success && response.data != null) {
        menus.assignAll(response.data!);
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Gagal memuat katalog menu';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat memuat katalog: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh menu catalog
  Future<void> refreshMenus() async {
    await loadMenus(forceRefresh: true);
  }

  /// Available categories derived from menus
  List<String> get availableTypes {
    final types = <String>{'all'};
    for (final menu in menus) {
      if (menu.type.isNotEmpty) {
        types.add(menu.type);
      }
    }
    return types.toList();
  }

  /// Human friendly label for menu types
  String getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'all':
        return 'Semua Menu';
      case 'seafood':
        return 'Seafood';
      case 'food':
        return 'Makanan';
      case 'beverage':
        return 'Minuman';
      case 'sides':
        return 'Pelengkap';
      default:
        return type.capitalizeFirst ?? type;
    }
  }

  /// Stock metrics calculations
  int get lowStockCount {
    int count = 0;
    for (final m in menus) {
      if (m.variants.any((v) => v.stockStatus == StockStatus.lowStock) ||
          m.stockStatus == StockStatus.lowStock) {
        count++;
      }
    }
    return count;
  }

  int get needMarketCheckCount {
    int count = 0;
    for (final m in menus) {
      if (m.needMarketCheck ||
          m.stockStatus == StockStatus.needMarketCheck ||
          m.variants.any((v) => v.needMarketCheck || v.stockStatus == StockStatus.needMarketCheck)) {
        count++;
      }
    }
    return count;
  }

  int get outOfStockCount {
    int count = 0;
    for (final m in menus) {
      if (m.stockStatus == StockStatus.outOfStock ||
          (m.variants.isNotEmpty && m.variants.every((v) => v.stockStatus == StockStatus.outOfStock))) {
        count++;
      }
    }
    return count;
  }

  /// Toggle stock filter chip
  void toggleStockFilter(StockStatus? status) {
    if (selectedStockFilter.value == status) {
      selectedStockFilter.value = null;
    } else {
      selectedStockFilter.value = status;
    }
  }

  /// Filtered menu list based on search, category, and stock filter
  List<MenuModel> get filteredMenus {
    final query = searchQuery.value.trim().toLowerCase();
    final typeFilter = selectedType.value;
    final stockFilter = selectedStockFilter.value;

    return menus.where((menu) {
      // Type match
      if (typeFilter != 'all' && menu.type.toLowerCase() != typeFilter.toLowerCase()) {
        return false;
      }

      // Stock status filter
      if (stockFilter != null) {
        final matchesParent = menu.stockStatus == stockFilter;
        final matchesVariant = menu.variants.any((v) => v.stockStatus == stockFilter);
        final matchesNeedMarket = stockFilter == StockStatus.needMarketCheck &&
            (menu.needMarketCheck || menu.variants.any((v) => v.needMarketCheck));

        if (!matchesParent && !matchesVariant && !matchesNeedMarket) {
          return false;
        }
      }

      // Search query match (menu name, ingredient, variant name)
      if (query.isNotEmpty) {
        final matchesMenuName = menu.name.toLowerCase().contains(query);
        final matchesVariantName = menu.variants.any((v) =>
            v.name.toLowerCase().contains(query) ||
            (v.ingredient?.toLowerCase().contains(query) ?? false) ||
            (v.cookingMethod?.toLowerCase().contains(query) ?? false));

        if (!matchesMenuName && !matchesVariantName) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
