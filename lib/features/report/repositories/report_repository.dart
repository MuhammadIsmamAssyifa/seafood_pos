import '../../../core/api/api_endpoint.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/dio_client.dart';
import '../models/dashboard_summary_model.dart';
import '../models/payment_summary_model.dart';
import '../models/report_filter.dart';
import '../models/sales_report_model.dart';
import '../models/top_menu_model.dart';

class ReportRepository {
  final DioClient dioClient;

  ReportRepository({required this.dioClient});

  /// Get dashboard operational summary (for today or specific date)
  Future<ApiResponse<DashboardSummaryModel>> getDashboard({String? date}) async {
    final response = await dioClient.get(
      ApiEndpoint.reportsDashboard,
      queryParameters: date != null ? {'date': date} : null,
    );

    final responseData = response.data;
    Map<String, dynamic> dataMap = {};

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        dataMap = responseData['data'] as Map<String, dynamic>;
      } else {
        dataMap = responseData;
      }
    }

    return ApiResponse<DashboardSummaryModel>.success(
      data: DashboardSummaryModel.fromJson(dataMap),
      statusCode: response.statusCode,
    );
  }

  /// Get sales report with daily trends for a filter period
  Future<ApiResponse<SalesReportModel>> getSales({ReportFilter? filter}) async {
    final queryParams = filter?.toQueryParams() ?? const ReportFilter().toQueryParams();

    final response = await dioClient.get(
      ApiEndpoint.reportsSales,
      queryParameters: queryParams,
    );

    final responseData = response.data;
    Map<String, dynamic> dataMap = {};

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        dataMap = responseData['data'] as Map<String, dynamic>;
      } else {
        dataMap = responseData;
      }
    }

    return ApiResponse<SalesReportModel>.success(
      data: SalesReportModel.fromJson(dataMap),
      statusCode: response.statusCode,
    );
  }

  /// Get payment report breakdown (Cash vs Transfer vs QRIS)
  Future<ApiResponse<PaymentSummaryModel>> getPayments({ReportFilter? filter}) async {
    final queryParams = filter?.toQueryParams() ?? const ReportFilter().toQueryParams();

    final response = await dioClient.get(
      ApiEndpoint.reportsPayments,
      queryParameters: queryParams,
    );

    final responseData = response.data;
    Map<String, dynamic> dataMap = {};

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        dataMap = responseData['data'] as Map<String, dynamic>;
      } else {
        dataMap = responseData;
      }
    }

    return ApiResponse<PaymentSummaryModel>.success(
      data: PaymentSummaryModel.fromJson(dataMap),
      statusCode: response.statusCode,
    );
  }

  /// Get top selling menus / menu sales rankings
  Future<ApiResponse<List<TopMenuModel>>> getTopMenu({ReportFilter? filter}) async {
    final queryParams = filter?.toQueryParams() ?? const ReportFilter().toQueryParams();

    final response = await dioClient.get(
      ApiEndpoint.reportsTopMenu,
      queryParameters: queryParams,
    );

    final responseData = response.data;
    List<dynamic> list = [];

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        final dataField = responseData['data'] as Map<String, dynamic>;
        if (dataField['menu_rankings'] is List) {
          list = dataField['menu_rankings'] as List;
        }
      } else if (responseData.containsKey('menu_rankings') && responseData['menu_rankings'] is List) {
        list = responseData['menu_rankings'] as List;
      } else if (responseData.containsKey('data') && responseData['data'] is List) {
        list = responseData['data'] as List;
      }
    } else if (responseData is List) {
      list = responseData;
    }

    final topMenus = list
        .whereType<Map<String, dynamic>>()
        .map((item) => TopMenuModel.fromJson(item))
        .toList();

    return ApiResponse<List<TopMenuModel>>.success(
      data: topMenus,
      statusCode: response.statusCode,
    );
  }
}

