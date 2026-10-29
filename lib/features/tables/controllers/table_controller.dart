import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/helpers.dart';
import '../models/table_model.dart';
import '../models/table_status.dart';
import '../repositories/table_repository.dart';
import '../views/create_order_dialog.dart';
import '../views/table_detail_page.dart';

class TableController extends GetxController {
  final TableRepository tableRepository;

  TableController({required this.tableRepository});

  final RxList<TableModel> tables = <TableModel>[].obs;
  final RxList<TableModel> filteredTables = <TableModel>[].obs;

  final RxBool isLoading = false.obs;
  final Rxn<TableModel> selectedTable = Rxn<TableModel>();
  final Rxn<ActiveOrderSummary> activeOrder = Rxn<ActiveOrderSummary>();

  final Rxn<TableStatus> selectedStatusFilter = Rxn<TableStatus>();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTables();
  }

  /// Load tables from API
  Future<void> loadTables() async {
    isLoading.value = true;
    try {
      final response = await tableRepository.getTables();
      if (response.success && response.data != null) {
        tables.assignAll(response.data!);
        _applyFilters();
      }
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.message,
        title: 'Gagal Memuat Meja',
      );
    } catch (e) {
      AppHelpers.showError(
        message: 'Gagal memuat data meja: ${e.toString()}',
        title: 'Error Jaringan',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh
  Future<void> refreshTables() async {
    await loadTables();
  }

  /// Filter tables by status
  void filterByStatus(TableStatus? status) {
    selectedStatusFilter.value = status;
    _applyFilters();
  }

  /// Search table number or customer name
  void searchTables(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchQuery.value.toLowerCase().trim();
    final filterStatus = selectedStatusFilter.value;

    filteredTables.assignAll(
      tables.where((table) {
        // Status filter
        if (filterStatus != null && table.status != filterStatus) {
          return false;
        }

        // Search query filter
        if (query.isNotEmpty) {
          final matchNumber = table.number.toLowerCase().contains(query);
          final matchCustomer = table.activeOrder?.customerName?.toLowerCase().contains(query) ?? false;
          final matchOrderNumber = table.activeOrder?.orderNumber.toLowerCase().contains(query) ?? false;
          return matchNumber || matchCustomer || matchOrderNumber;
        }

        return true;
      }).toList(),
    );
  }

  /// On table card tapped
  void onTableTapped(TableModel table, BuildContext context) {
    selectedTable.value = table;
    activeOrder.value = table.activeOrder;

    if (table.isAvailable) {
      // Empty table -> Open Create Order Dialog
      showCreateOrderDialog(table, context);
    } else {
      // Occupied table -> Open Table Detail / Active Order
      Get.to(() => TableDetailPage(
            table: table,
            onNewOrder: () {
              Get.back();
              showCreateOrderDialog(table, context);
            },
          ));
    }
  }

  /// Show Create Order Dialog
  void showCreateOrderDialog(TableModel table, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => CreateOrderDialog(
        table: table,
        onSubmit: (customerName, guestCount) async {
          Navigator.of(dialogCtx).pop();
          await createOrder(
            tableId: table.id,
            tableNumber: table.number,
            customerName: customerName,
            guestCount: guestCount,
          );
        },
      ),
    );
  }

  /// Create order on backend & navigate to order page
  Future<bool> createOrder({
    required int tableId,
    required String tableNumber,
    required String customerName,
    required int guestCount,
  }) async {
    isLoading.value = true;
    try {
      final response = await tableRepository.createOrder(
        orderTableId: tableId,
        customerName: customerName,
        guestCount: guestCount,
      );

      if (response.success && response.data != null) {
        AppHelpers.showSuccess(
          message: 'Order meja $tableNumber atas nama $customerName berhasil dibuat.',
          title: 'Order Dibuat',
        );

        // Refresh tables to reflect occupied status
        await loadTables();

        // Navigate to Order Page with new order details
        Get.toNamed(
          AppRoutes.ORDER,
          arguments: {
            'order_id': response.data!.id,
            'table_id': tableId,
            'table_number': tableNumber,
            'customer_name': customerName,
            'guest_count': guestCount,
          },
        );
        return true;
      } else {
        AppHelpers.showError(message: response.message, title: 'Gagal Membuat Order');
        return false;
      }
    } on ApiException catch (e) {
      final msg = e.firstValidationError ?? e.message;
      AppHelpers.showError(message: msg, title: 'Gagal Membuat Order');
      return false;
    } catch (e) {
      AppHelpers.showError(message: e.toString(), title: 'Gagal Membuat Order');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

