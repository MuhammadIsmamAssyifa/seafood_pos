import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/stock_info_model.dart';
import '../models/stock_status.dart';
import '../repositories/inventory_repository.dart';

class InventoryController extends GetxController {
  final InventoryRepository repository;

  InventoryController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxList<StockInfoModel> stockInfo = <StockInfoModel>[].obs;
  final Rxn<StockInfoModel> selectedMenu = Rxn<StockInfoModel>();
  final Rx<StockStatus> stockStatus = StockStatus.available.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<StockStatus> filterStatus = Rxn<StockStatus>();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadInventoryInfo();
  }

  /// Loads stock information from backend
  Future<void> loadInventoryInfo({bool forceRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await repository.getMenuInventory(forceRefresh: forceRefresh);
      if (response.success && response.data != null) {
        stockInfo.assignAll(response.data!);
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Informasi stok tidak tersedia.';
      }
    } catch (e) {
      errorMessage.value = 'Tidak dapat mengambil informasi stok.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Refreshes stock information
  Future<void> refreshInventory() async {
    await loadInventoryInfo(forceRefresh: true);
  }

  /// Finds stock status for a specific menu or variant
  StockStatus getStockStatus(int menuId, {int? variantId}) {
    if (variantId != null) {
      final variantStock = stockInfo.firstWhereOrNull(
        (item) => item.variantId == variantId,
      );
      if (variantStock != null) return variantStock.stockStatus;
    }

    final menuStock = stockInfo.firstWhereOrNull(
      (item) => item.menuId == menuId && item.variantId == null,
    );
    return menuStock?.stockStatus ?? StockStatus.available;
  }

  /// Finds stock info model for a specific menu or variant
  StockInfoModel? getStockInfo(int menuId, {int? variantId}) {
    if (variantId != null) {
      return stockInfo.firstWhereOrNull(
        (item) => item.variantId == variantId,
      );
    }
    return stockInfo.firstWhereOrNull(
      (item) => item.menuId == menuId && item.variantId == null,
    );
  }

  /// Shows stock warning message via snackbar or dialog if needed
  void showStockWarning(StockStatus status, {String? menuName}) {
    final name = menuName != null ? ' untuk "$menuName"' : '';
    if (status == StockStatus.lowStock) {
      Get.snackbar(
        'Peringatan Stok Menipis',
        'Stok hampir habis$name. Pastikan kitchen masih memiliki bahan yang cukup.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } else if (status == StockStatus.needMarketCheck) {
      Get.snackbar(
        'Perlu Cek Pasar',
        'Bahan seafood$name sedang dicek ke pasar. Order tetap dapat dibuat.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        icon: const Icon(Icons.storefront_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Filtered stock info list according to search query and status filter
  List<StockInfoModel> get filteredStockInfo {
    return stockInfo.where((item) {
      if (filterStatus.value != null && item.stockStatus != filterStatus.value) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final name = item.variantName ?? item.menuName;
        if (!name.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  int get lowStockCount => stockInfo.where((i) => i.isLowStock).length;
  int get outOfStockCount => stockInfo.where((i) => i.isOutOfStock).length;
  int get needMarketCheckCount => stockInfo.where((i) => i.isNeedMarketCheck).length;
}
