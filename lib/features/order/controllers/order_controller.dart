import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/services/pusher_service.dart';
import '../../../core/utils/helpers.dart';
import '../models/menu_category.dart';
import '../models/menu_model.dart';
import '../models/order_batch_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';
import '../widgets/submit_dialog.dart';

class OrderController extends GetxController {
  final OrderRepository orderRepository;
  final PusherService? pusherService;

  OrderController({
    required this.orderRepository,
    this.pusherService,
  });

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
  final RxBool isSubmitting = false.obs;
  final Rxn<int> mutatingItemId = Rxn<int>();
  final Rxn<int> selectedBatchId = Rxn<int>();

  // Catalog Data
  final RxList<MenuModel> menus = <MenuModel>[].obs;
  final RxList<MenuModel> filteredMenus = <MenuModel>[].obs;
  final RxList<MenuCategory> categories = <MenuCategory>[].obs;
  final RxString selectedCategoryId = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Order / Cart Data
  final Rxn<OrderModel> order = Rxn<OrderModel>();

  // Realtime Pusher Subscription
  StreamSubscription<PusherKdsEvent>? _pusherSubscription;

  // Computed Properties (Direct from Backend)
  List<OrderItemModel> get cartItems => order.value?.items ?? [];
  List<OrderBatchModel> get batches => order.value?.batches ?? [];
  OrderBatchModel? get waitingBatch => order.value?.waitingBatch;
  bool get hasWaitingBatch => order.value?.hasWaitingBatch ?? false;

  double get subtotal => order.value?.subtotal ?? 0.0;
  double get discount => order.value?.discount ?? 0.0;
  double get grandTotal => order.value?.grandTotal ?? 0.0;
  int get totalItemCount => order.value?.totalItemCount ?? 0;
  String get orderStatus => order.value?.status ?? 'draft';
  bool get isOrderDraft => order.value?.isDraft ?? true;

  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    _initCategories();
    _setupPusherListener();
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

  void _setupPusherListener() {
    final pusher = pusherService ?? (Get.isRegistered<PusherService>() ? Get.find<PusherService>() : null);
    if (pusher != null) {
      _pusherSubscription = pusher.onKdsEvent.listen((event) {
        if (orderId.value == null) return;

        final isMatchingOrder = event.orderId == orderId.value;
        final isMatchingBatch = event.batchId != null &&
            batches.any((b) => b.id == event.batchId);

        if (isMatchingOrder || isMatchingBatch) {
          // Real-time update received from Pusher -> Refresh order state
          loadOrder(orderId.value!, isSilent: true);
        }
      });
    }
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
  Future<void> loadOrder(int id, {bool isSilent = false}) async {
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
      if (!isSilent) {
        AppHelpers.showError(
          message: e.message,
          title: 'Gagal Memuat Order',
        );
      }
    } catch (e) {
      if (!isSilent) {
        AppHelpers.showError(
          message: e.toString(),
          title: 'Gagal Memuat Order',
        );
      }
    }
  }

  /// Refresh current order from backend
  Future<void> refreshOrder() async {
    if (orderId.value != null) {
      await loadOrder(orderId.value!);
    }
    await loadMenus();
  }

  /// Refresh order status specifically
  Future<void> refreshStatus() async {
    if (orderId.value != null) {
      await loadOrder(orderId.value!, isSilent: true);
    }
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

    if (order.value?.isCompleted == true || order.value?.isCancelled == true) {
      AppHelpers.showError(
        message: 'Order berstatus ${order.value?.status.toUpperCase()} tidak dapat diubah.',
        title: 'Order Selesai',
      );
      return;
    }

    // Check if variant already exists in active waiting batch -> increment quantity instead
    final currentWaitingBatch = waitingBatch;
    final existingWaitingItem = currentWaitingBatch?.items.firstWhereOrNull(
      (item) => item.menuVariantId == variant.id,
    );

    if (existingWaitingItem != null) {
      await updateItemQuantity(existingWaitingItem, existingWaitingItem.quantity + quantity);
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

    // Check if item belongs to a waiting batch
    final batch = batches.firstWhereOrNull((b) => b.id == item.orderBatchId);
    if (batch != null && !batch.isWaiting) {
      AppHelpers.showError(
        message: 'Item pada ${batch.displayName} sudah terkirim ke dapur dan tidak dapat diubah langsung.',
        title: 'Item Terkunci',
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
    final batch = batches.firstWhereOrNull((b) => b.id == item.orderBatchId);
    if (batch != null && !batch.isWaiting) {
      AppHelpers.showError(
        message: 'Item pada ${batch.displayName} sudah terkirim ke dapur dan tidak dapat dihapus.',
        title: 'Item Terkunci',
      );
      return;
    }

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

  /// Submit batch to kitchen with confirmation
  Future<void> submitBatchPrompt(BuildContext context, [OrderBatchModel? batch]) async {
    final targetBatch = batch ?? waitingBatch;

    if (targetBatch == null) {
      AppHelpers.showInfo(
        message: 'Semua pesanan sudah dikirim ke dapur.',
        title: 'Tidak Ada Batch Menunggu',
      );
      return;
    }

    if (targetBatch.items.isEmpty) {
      AppHelpers.showError(
        message: 'Tidak ada item di ${targetBatch.displayName} untuk dikirim.',
        title: 'Batch Kosong',
      );
      return;
    }

    SubmitOrderDialog.show(
      context: context,
      batchNumber: targetBatch.batchNumber,
      itemCount: targetBatch.itemCount,
      onConfirm: () => submitBatch(targetBatch.id),
    );
  }

  /// Execute batch submit API
  Future<void> submitBatch(int batchId) async {
    isSubmitting.value = true;
    try {
      final response = await orderRepository.submitBatch(batchId);
      if (response.success) {
        AppHelpers.showSuccess(
          message: response.message.isNotEmpty
              ? response.message
              : 'Pesanan berhasil dikirim ke dapur!',
          title: 'Pesanan Dikirim',
        );

        // Refresh entire order to obtain new status, batches and timestamps
        if (orderId.value != null) {
          await loadOrder(orderId.value!);
        }
      } else {
        AppHelpers.showError(
          message: response.message,
          title: 'Gagal Mengirim ke Dapur',
        );
      }
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.firstValidationError ?? e.message,
        title: 'Gagal Mengirim ke Dapur',
      );
    } catch (e) {
      AppHelpers.showError(
        message: e.toString(),
        title: 'Error Mengirim ke Dapur',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Cancel / delete a waiting batch (e.g. additional batch cancelled by customer)
  Future<void> deleteBatch(int batchId) async {
    isSubmitting.value = true;
    try {
      final response = await orderRepository.deleteBatch(batchId);
      if (response.success) {
        AppHelpers.showSuccess(message: 'Batch berhasil dibatalkan');
        if (orderId.value != null) {
          await loadOrder(orderId.value!);
        }
      } else {
        AppHelpers.showError(
          message: response.message,
          title: 'Gagal Membatalkan Batch',
        );
      }
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.firstValidationError ?? e.message,
        title: 'Gagal Membatalkan Batch',
      );
    } catch (e) {
      AppHelpers.showError(
        message: e.toString(),
        title: 'Error Membatalkan Batch',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Total count for a menu across its variants in the current waiting cart
  int getMenuQuantityInCart(MenuModel menu) {
    final variantIds = menu.variants.map((v) => v.id).toSet();
    int count = 0;
    // Count items currently in the waiting batch (or all cart items)
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

  @override
  void onClose() {
    _pusherSubscription?.cancel();
    super.onClose();
  }
}
