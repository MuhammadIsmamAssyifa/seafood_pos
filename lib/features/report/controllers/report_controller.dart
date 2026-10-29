import 'package:get/get.dart';
import '../models/dashboard_summary_model.dart';
import '../models/payment_summary_model.dart';
import '../models/report_filter.dart';
import '../models/sales_report_model.dart';
import '../models/top_menu_model.dart';
import '../repositories/report_repository.dart';

class ReportController extends GetxController {
  final ReportRepository repository;

  ReportController({required this.repository});

  final RxBool isLoading = false.obs;
  final Rxn<DashboardSummaryModel> dashboard = Rxn<DashboardSummaryModel>();
  final Rxn<SalesReportModel> sales = Rxn<SalesReportModel>();
  final Rxn<PaymentSummaryModel> payments = Rxn<PaymentSummaryModel>();
  final RxList<TopMenuModel> topMenus = <TopMenuModel>[].obs;
  final Rx<ReportFilter> selectedFilter = const ReportFilter().obs;
  final RxnString errorMessage = RxnString();
  final RxInt activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllReports();
  }

  /// Load all report sections for the selected filter
  Future<void> loadAllReports() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await Future.wait([
        loadDashboard(),
        loadSales(),
        loadPayments(),
        loadTopMenu(),
      ]);
    } catch (e) {
      errorMessage.value = 'Tidak dapat mengambil laporan.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load dashboard summary
  Future<void> loadDashboard() async {
    try {
      final res = await repository.getDashboard();
      if (res.success && res.data != null) {
        dashboard.value = res.data;
      }
    } catch (_) {
      // Handled in loadAllReports or silently fallback
    }
  }

  /// Load sales report for current filter
  Future<void> loadSales() async {
    try {
      final res = await repository.getSales(filter: selectedFilter.value);
      if (res.success && res.data != null) {
        sales.value = res.data;
      }
    } catch (_) {}
  }

  /// Load payment report for current filter
  Future<void> loadPayments() async {
    try {
      final res = await repository.getPayments(filter: selectedFilter.value);
      if (res.success && res.data != null) {
        payments.value = res.data;
      }
    } catch (_) {}
  }

  /// Load top selling menu rankings
  Future<void> loadTopMenu() async {
    try {
      final res = await repository.getTopMenu(filter: selectedFilter.value);
      if (res.success && res.data != null) {
        topMenus.assignAll(res.data!);
      }
    } catch (_) {}
  }

  /// Update date/period filter and re-fetch reports
  Future<void> changeFilter(ReportFilter newFilter) async {
    selectedFilter.value = newFilter;
    await loadAllReports();
  }

  /// Pull-to-refresh
  Future<void> refreshReport() async {
    await loadAllReports();
  }
}
