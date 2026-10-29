import 'dart:async';
import 'package:get/get.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_response.dart';
import '../../../core/utils/helpers.dart';
import '../../order_adjustment/models/adjustment_model.dart';
import '../../payment/models/payment_model.dart';
import '../models/history_filter.dart';
import '../models/history_order_model.dart';
import '../models/history_summary.dart';
import '../repositories/history_repository.dart';

class HistoryController extends GetxController {
  final HistoryRepository repository;

  HistoryController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxBool isDetailLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<HistoryOrderModel> orders = <HistoryOrderModel>[].obs;
  final Rx<HistoryOrderModel?> selectedOrder = Rx<HistoryOrderModel?>(null);
  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final RxList<AdjustmentModel> adjustments = <AdjustmentModel>[].obs;

  final Rx<HistoryFilter> filter = const HistoryFilter().obs;
  final RxString searchText = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;

  HistorySummary get summary => HistorySummary.fromOrders(orders);

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Load order history from page 1
  Future<void> loadHistory({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMore.value = true;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await repository.getHistory(
        filter.value,
        page: currentPage.value,
        perPage: 20,
      );

      final newOrders = response.data ?? [];

      if (isRefresh) {
        orders.assignAll(newOrders);
      } else {
        orders.addAll(newOrders);
      }

      if (newOrders.length < 20) {
        hasMore.value = false;
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      AppHelpers.showError(message: e.message, title: 'Gagal Memuat Transaksi');
    } catch (e) {
      errorMessage.value = 'Gagal memuat riwayat order: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more items for infinite scrolling
  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;
    currentPage.value++;
    await loadHistory(isRefresh: false);
  }

  /// Debounced search query handler
  void onSearchChanged(String query) {
    searchText.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      filter.value = filter.value.copyWith(searchQuery: query);
      loadHistory();
    });
  }

  /// Clear search input
  void clearSearch() {
    searchText.value = '';
    filter.value = filter.value.copyWith(searchQuery: '');
    loadHistory();
  }

  /// Apply filter from filter sheet / date picker
  void applyFilter(HistoryFilter newFilter) {
    filter.value = newFilter;
    loadHistory();
  }

  /// Set quick status filter (e.g. from tab or chip)
  void setStatusFilter(String? status) {
    if (status == null || status.isEmpty) {
      filter.value = filter.value.copyWith(clearStatus: true);
    } else {
      filter.value = filter.value.copyWith(status: status);
    }
    loadHistory();
  }

  /// Set quick date range filter
  void setDateRangeFilter(HistoryDateRange range, {DateTime? start, DateTime? end}) {
    filter.value = filter.value.copyWith(
      dateRange: range,
      startDate: start,
      endDate: end,
    );
    loadHistory();
  }

  /// Reset all filters to default
  void resetFilter() {
    filter.value = const HistoryFilter();
    searchText.value = '';
    loadHistory();
  }

  /// Load full details of a single order (including payments & adjustments)
  Future<void> loadDetail(int orderId) async {
    try {
      isDetailLoading.value = true;
      errorMessage.value = '';

      // 1. Fetch Order detail
      final orderResponse = await repository.getOrder(orderId);
      final order = orderResponse.data;

      if (order != null) {
        selectedOrder.value = order;
      }

      // 2. Fetch Payments in parallel
      final paymentsFuture = repository.getPayments(orderId);

      // 3. Fetch Adjustments in parallel
      final adjustmentsFuture = repository.getAdjustments(orderId);

      final results = await Future.wait([paymentsFuture, adjustmentsFuture]);

      final pList = results[0] as ApiResponse<List<PaymentModel>>;
      final aList = results[1] as ApiResponse<List<AdjustmentModel>>;

      payments.assignAll(pList.data ?? []);
      adjustments.assignAll(aList.data ?? []);

      if (selectedOrder.value != null) {
        selectedOrder.value = selectedOrder.value!.copyWith(
          payments: payments,
          adjustments: adjustments,
        );
      }
    } on ApiException catch (e) {
      AppHelpers.showError(message: e.message, title: 'Gagal Memuat Detail');
    } catch (e) {
      AppHelpers.showError(message: 'Error: $e', title: 'Terjadi Kesalahan');
    } finally {
      isDetailLoading.value = false;
    }
  }

  /// Select an order directly (e.g. from list) before fetching extra details
  void selectOrder(HistoryOrderModel order) {
    selectedOrder.value = order;
    payments.assignAll(order.payments);
    adjustments.assignAll(order.adjustments);
    loadDetail(order.id);
  }
}
