import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/helpers.dart';
import '../models/menu_category.dart';
import '../models/menu_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';

class OrderController extends GetxController {
  final OrderRepository orderRepository;

  OrderController({required this.orderRepository});

  // Order identifiers & summary context
  final Rxn<int> orderId = Rxn<int>();
  final Rxn<int> tableId = Rxn<int>();
  final RxString tableNumber = ''.obs;
  final RxString customerName = ''.obs;
  final RxInt guestCount = 1.obs;

  // Loading & State
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMenu = false.obs;
  final RxBool isCartMutating = false.obs;
  final Rxn<int> mutatingItemId = Rxn<int>();

  // Catalog Data
  final RxList<MenuModel> menus = <MenuModel>[].obs;
  final RxList<MenuModel> filteredMenus = <MenuModel>[].obs;
  final RxList<MenuCategory> categories = <MenuCategory>[].obs;
  final RxString selectedCategoryId = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Order / Cart Data
  final Rxn<OrderModel> order = Rxn<OrderModel>();

  // Computed Properties (Direct from Backend)
  List<OrderItemModel> get cartItems => order.value?.items ?? [];
  double get subtotal => order.value?.subtotal ?? 0.0;
  double get discount => order.value?.discount ?? 0.0;
  double get grandTotal => order.value?.grandTotal ?? 0.0;
  int get totalItemCount => order.value?.totalItemCount ?? 0;
  bool get isOrderDraft => order.value?.isDraft ?? true;

  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    _initCategories();
    initData();
  }

  void _extractArguments() {
    final args = Get.arguments;
    if (args is Map) {
      if (args['order_id'] != null) {
        orderId.value = int.tryParse(args['order_id'].toString());
      }
      if (args['table_id'] != null) {
        tableId.value = int.tryParse(args['table_id'].toString());
      }
      if (args['table_number'] != null) {
        tableNumber.value = args['table_number'].toString();
      }
      if (args['customer_name'] != null) {
        customerName.value = args['customer_name'].toString();
      }
      if (args['guest_count'] != null) {
        guestCount.value = int.tryParse(args['guest_count'].toString()) ?? 1;
      }
    }
  }

  void _initCategories() {
    categories.assignAll(MenuCategory.defaultCategories);
  }

  Future<void> initData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadMenus(),
        if (orderId.value != null) loadOrder(orderId.value!),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  /// Load menu catalog from backend
  Future<void> loadMenus() async {
    isLoadingMenu.value = true;
    try {
      final response = await orderRepository.getMenus();
      if (response.success && response.data != null) {
        menus.assignAll(response.data!);
        _mergeDynamicCategories(response.data!);
        _applyMenuFilters();
      } else {
        AppHelpers.showError(
          message: response.message,
          title: 'Gagal Memuat Menu',
        );
      }
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.message,
        title: 'Error Memuat Menu',
      );
    } catch (e) {
      AppHelpers.showError(
        message: 'Gagal terhubung ke server menu: ${e.toString()}',
        title: 'Koneksi Bermasalah',
      );
    } finally {
      isLoadingMenu.value = false;
    }
  }

  /// Merge any categories present in loaded menus into categories list
  void _mergeDynamicCategories(List<MenuModel> menuList) {
    final existingIds = categories.map((c) => c.id.toLowerCase()).toSet();
    final newCategories = <MenuCategory>[];

    for (final menu in menuList) {
      final typeId = menu.type.trim().toLowerCase();
      if (typeId.isNotEmpty && !existingIds.contains(typeId)) {
        existingIds.add(typeId);
        final title = typeId[0].toUpperCase() + typeId.substring(1);
        newCategories.add(MenuCategory(id: typeId, name: title));
      }
    }

    if (newCategories.isNotEmpty) {
      categories.addAll(newCategories);
    }
  }

  /// Fetch full order details
  Future<void> loadOrder(int id) async {
    try {
      final response = await orderRepository.getOrder(id);
      if (response.success && response.data != null) {
        order.value = response.data;
        // Update context fields if empty
        if (tableNumber.value.isEmpty && response.data!.tableNumber != null) {
          tableNumber.value = response.data!.tableNumber!;
        }
        if (customerName.value.isEmpty && response.data!.customerName != null) {
          customerName.value = response.data!.customerName!;
        }
        guestCount.value = response.data!.guestCount;
      }
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.message,
        title: 'Gagal Memuat Order',
      );
    } catch (e) {
      AppHelpers.showError(
        message: e.toString(),
        title: 'Gagal Memuat Order',
      );
    }
  }

  /// Refresh current order from backend
  Future<void> refreshOrder() async {
    if (orderId.value != null) {
      await loadOrder(orderId.value!);
    }
    await loadMenus();
  }

  /// Category filter change
  void setCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
    _applyMenuFilters();
  }

  /// Search keyword input
  void searchMenu(String query) {
    searchQuery.value = query;
    _applyMenuFilters();
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    _applyMenuFilters();
  }

  void _applyMenuFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final selectedCat = selectedCategoryId.value.toLowerCase();

    filteredMenus.assignAll(
      menus.where((menu) {
        // Category check
        if (selectedCat != 'all' && menu.type.toLowerCase() != selectedCat) {
          return false;
        }

        // Search text check
        if (query.isNotEmpty) {
          final matchesMenuName = menu.name.toLowerCase().contains(query);
          final matchesVariant = menu.variants.any((v) =>
              v.name.toLowerCase().contains(query) ||
              (v.ingredient?.toLowerCase().contains(query) ?? false) ||
              (v.cookingMethod?.toLowerCase().contains(query) ?? false));

          return matchesMenuName || matchesVariant;
        }

        return true;
      }).toList(),
    );
  }

  /// Add item (variant) to order
  Future<void> addItem(MenuVariantModel variant, {double quantity = 1.0}) async {
    if (orderId.value == null) {
      AppHelpers.showError(
        message: 'Order ID tidak ditemukan. Buat order terlebih dahulu melalui Meja.',
        title: 'Order Tidak Ditemukan',
      );
      return;
    }

    if (!isOrderDraft) {
      AppHelpers.showError(
        message: 'Order berstatus ${order.value?.status.toUpperCase()} tidak dapat diubah.',
        title: 'Order Terkunci',
      );
      return;
    }

    // Check if variant already exists in cart -> increment quantity instead
    final existingItem = cartItems.firstWhereOrNull(
      (item) => item.menuVariantId == variant.id,
    );

    if (existingItem != null) {
      await updateItemQuantity(existingItem, existingItem.quantity + quantity);
      return;
    }

    isCartMutating.value = true;
    try {
      final response = await orderRepository.addItem(
        orderId: orderId.value!,
        menuVariantId: variant.id,
        quantity: quantity,
      );

      if (response.success && response.data != null) {
        order.value = response.data;
        AppHelpers.showSuccess(
          message: '${variant.name} (${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2)}) berhasil ditambahkan',
          title: 'Item Ditambahkan',
          duration: const Duration(milliseconds: 1500),
        );
      } else {
        AppHelpers.showError(
          message: response.message,
          title: 'Gagal Menambah Item',
        );
      }
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.firstValidationError ?? e.message,
        title: 'Gagal Menambah Item',
      );
    } catch (e) {
      AppHelpers.showError(
        message: e.toString(),
        title: 'Error Menambah Item',
      );
    } finally {
      isCartMutating.value = false;
    }
  }

  /// Update quantity of an item directly
  Future<void> updateItemQuantity(OrderItemModel item, double newQuantity) async {
    if (newQuantity <= 0) {
      // Trigger confirmation dialog for deletion
      confirmDeleteItem(item);
      return;
    }

    if (!isOrderDraft) {
      AppHelpers.showError(
        message: 'Order berstatus ${order.value?.status.toUpperCase()} tidak dapat diubah.',
        title: 'Order Terkunci',
      );
      return;
    }

    isCartMutating.value = true;
    mutatingItemId.value = item.id;
    try {
      final response = await orderRepository.updateItem(
        orderItemId: item.id,
        quantity: newQuantity,
      );

      if (response.success && response.data != null) {
        order.value = response.data;
      } else {
        AppHelpers.showError(
          message: response.message,
          title: 'Gagal Mengubah Quantity',
        );
      }
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.firstValidationError ?? e.message,
        title: 'Gagal Mengubah Quantity',
      );
    } catch (e) {
      AppHelpers.showError(
        message: e.toString(),
        title: 'Error Mengubah Quantity',
      );
    } finally {
      isCartMutating.value = false;
      mutatingItemId.value = null;
    }
  }

  /// Confirm and delete item from order
  void confirmDeleteItem(OrderItemModel item) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Item'),
        content: Text('Hapus "${item.displayName}" dari daftar pesanan?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 40),
            ),
            onPressed: () {
              Get.back();
              deleteItem(item.id, item.displayName);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  /// Delete item from order API
  Future<void> deleteItem(int itemId, [String? itemName]) async {
    if (!isOrderDraft) {
      AppHelpers.showError(
        message: 'Order berstatus ${order.value?.status.toUpperCase()} tidak dapat diubah.',
        title: 'Order Terkunci',
      );
      return;
    }

    isCartMutating.value = true;
    mutatingItemId.value = itemId;
    try {
      final response = await orderRepository.deleteItem(itemId);
      if (response.success && response.data != null) {
        order.value = response.data;
        AppHelpers.showSuccess(
          message: itemName != null ? '$itemName dihapus dari order' : 'Item berhasil dihapus',
          title: 'Item Dihapus',
          duration: const Duration(milliseconds: 1500),
        );
      } else {
        AppHelpers.showError(
          message: response.message,
          title: 'Gagal Menghapus Item',
        );
      }
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.firstValidationError ?? e.message,
        title: 'Gagal Menghapus Item',
      );
    } catch (e) {
      AppHelpers.showError(
        message: e.toString(),
        title: 'Error Menghapus Item',
      );
    } finally {
      isCartMutating.value = false;
      mutatingItemId.value = null;
    }
  }

  /// Total count for a menu across its variants in the current cart
  int getMenuQuantityInCart(MenuModel menu) {
    final variantIds = menu.variants.map((v) => v.id).toSet();
    int count = 0;
    for (final item in cartItems) {
      if (variantIds.contains(item.menuVariantId)) {
        count += item.quantity.toInt();
      }
    }
    return count;
  }

  /// Get specific variant in cart
  OrderItemModel? getCartItemForVariant(int variantId) {
    return cartItems.firstWhereOrNull((item) => item.menuVariantId == variantId);
  }
}

