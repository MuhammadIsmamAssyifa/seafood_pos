import 'package:get/get.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/helpers.dart';
import '../../order/controllers/order_controller.dart';
import '../../order/models/menu_model.dart';
import '../../order/models/order_model.dart';
import '../models/adjustment_model.dart';
import '../models/adjustment_status.dart';
import '../repositories/order_adjustment_repository.dart';

class OrderAdjustmentController extends GetxController {
  final OrderAdjustmentRepository repository;

  OrderAdjustmentController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<AdjustmentModel> adjustments = <AdjustmentModel>[].obs;
  final Rx<AdjustmentModel?> selectedAdjustment = Rx<AdjustmentModel?>(null);
  final Rx<MenuVariantModel?> selectedReplacement = Rx<MenuVariantModel?>(null);
  final Rx<AdjustmentStatus?> filterStatus = Rx<AdjustmentStatus?>(null);

  final Rx<OrderModel?> activeOrder = Rx<OrderModel?>(null);
  final RxInt activeOrderId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      if (args['orderId'] != null) {
        activeOrderId.value = args['orderId'] as int;
      }
      if (args['order'] is OrderModel) {
        activeOrder.value = args['order'] as OrderModel;
        activeOrderId.value = activeOrder.value!.id;
      }
    } else if (args is int) {
      activeOrderId.value = args;
    } else if (Get.isRegistered<OrderController>()) {
      final orderCtrl = Get.find<OrderController>();
      if (orderCtrl.order.value != null) {
        activeOrder.value = orderCtrl.order.value;
        activeOrderId.value = activeOrder.value!.id;
      }
    }

    loadAdjustment();
  }

  /// List of adjustments filtered by current status tab
  List<AdjustmentModel> get filteredAdjustments {
    if (filterStatus.value == null) {
      return adjustments;
    }
    return adjustments.where((a) => a.status == filterStatus.value).toList();
  }

  /// Count of pending adjustments that need customer approval
  int get pendingCount => adjustments.where((a) => a.isPending).length;

  /// Load adjustments from backend
  Future<void> loadAdjustment([int? orderId]) async {
    final targetOrderId = orderId ?? (activeOrderId.value > 0 ? activeOrderId.value : null);

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await repository.getAdjustment(
        orderId: targetOrderId,
        status: filterStatus.value?.value,
      );

      adjustments.assignAll(response.data ?? []);

      // Also refresh order data if available
      if (targetOrderId != null) {
        await refreshOrder(targetOrderId);
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Gagal memuat daftar adjustment: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Approve adjustment (Customer confirms price/quantity adjustment)
  Future<bool> approveAdjustment(int changeId) async {
    try {
      isActionLoading.value = true;
      final response = await repository.approve(changeId);

      AppHelpers.showSuccess(
        message: response.message,
        title: 'Berhasil',
      );

      // Refresh list & current order
      await loadAdjustment();
      if (activeOrderId.value > 0) {
        await refreshOrder(activeOrderId.value);
      }

      return true;
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.message,
        title: 'Gagal Menyetujui',
      );
      return false;
    } catch (e) {
      AppHelpers.showError(
        message: 'Gagal menyetujui perubahan: $e',
        title: 'Error',
      );
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Reject adjustment (Customer rejects kitchen's proposed change)
  Future<bool> rejectAdjustment(int changeId) async {
    try {
      isActionLoading.value = true;
      final response = await repository.reject(changeId);

      AppHelpers.showSuccess(
        message: response.message,
        title: 'Perubahan Ditolak',
      );

      await loadAdjustment();
      return true;
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.message,
        title: 'Gagal Menolak',
      );
      return false;
    } catch (e) {
      AppHelpers.showError(
        message: 'Gagal menolak perubahan: $e',
        title: 'Error',
      );
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Replace rejected / unavailable item with a new menu variant
  Future<bool> replaceItem({
    required int orderItemId,
    required int menuVariantId,
    required double quantity,
    required String reason,
  }) async {
    try {
      isActionLoading.value = true;
      final response = await repository.replace(
        orderItemId: orderItemId,
        menuVariantId: menuVariantId,
        quantity: quantity,
        reason: reason,
      );

      AppHelpers.showSuccess(
        message: response.message,
        title: 'Menu Diganti',
      );

      // Refresh list & current order
      await loadAdjustment();
      if (activeOrderId.value > 0) {
        await refreshOrder(activeOrderId.value);
      }

      return true;
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.message,
        title: 'Gagal Mengganti Menu',
      );
      return false;
    } catch (e) {
      AppHelpers.showError(
        message: 'Gagal mengganti menu: $e',
        title: 'Error',
      );
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Cancel an item via adjustment request
  Future<bool> cancelItem({
    required int orderItemId,
    required String reason,
  }) async {
    try {
      isActionLoading.value = true;
      final response = await repository.createAdjustment(
        orderItemId: orderItemId,
        type: 'cancel',
        reason: reason,
      );

      // Auto approve cancellation if confirmed
      if (response.data != null) {
        await repository.approve(response.data!.id);
      }

      AppHelpers.showSuccess(
        message: 'Item pesanan berhasil dibatalkan dan total order telah diperbarui',
        title: 'Item Dibatalkan',
      );

      await loadAdjustment();
      if (activeOrderId.value > 0) {
        await refreshOrder(activeOrderId.value);
      }

      return true;
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.message,
        title: 'Gagal Membatalkan Item',
      );
      return false;
    } catch (e) {
      AppHelpers.showError(
        message: 'Gagal membatalkan item: $e',
        title: 'Error',
      );
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Refresh order data from backend and sync with OrderController if present
  Future<void> refreshOrder([int? orderId]) async {
    final id = orderId ?? activeOrderId.value;
    if (id <= 0) return;

    try {
      final response = await repository.refreshOrder(id);
      activeOrder.value = response.data;

      // Sync with global OrderController if registered
      if (Get.isRegistered<OrderController>()) {
        final orderCtrl = Get.find<OrderController>();
        orderCtrl.order.value = response.data;
      }
    } catch (_) {
      // Non-critical, ignore
    }
  }

  void selectAdjustment(AdjustmentModel adjustment) {
    selectedAdjustment.value = adjustment;
  }

  void setFilterStatus(AdjustmentStatus? status) {
    filterStatus.value = status;
    loadAdjustment();
  }
}

