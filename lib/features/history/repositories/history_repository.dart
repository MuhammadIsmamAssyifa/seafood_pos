import '../../../core/api/api_endpoint.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/dio_client.dart';
import '../../order_adjustment/models/adjustment_model.dart';
import '../../payment/models/payment_model.dart';
import '../models/history_filter.dart';
import '../models/history_order_model.dart';

class HistoryRepository {
  final DioClient dioClient;

  HistoryRepository({required this.dioClient});

  /// Fetch order history with search and filters
  Future<ApiResponse<List<HistoryOrderModel>>> getHistory(
    HistoryFilter filter, {
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = filter.toQueryParams(page: page, perPage: perPage);

    final response = await dioClient.get(
      ApiEndpoint.orders,
      queryParameters: queryParams,
    );

    final responseData = response.data;
    List<dynamic> list = [];

    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataField = responseData['data'];
      if (dataField is List) {
        list = dataField;
      } else if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
        list = dataField['data'] as List;
      }
    } else if (responseData is List) {
      list = responseData;
    }

    final orders = list
        .map((item) => HistoryOrderModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return ApiResponse<List<HistoryOrderModel>>.success(
      data: orders,
      statusCode: response.statusCode,
    );
  }

  /// Fetch single order details
  Future<ApiResponse<HistoryOrderModel>> getOrder(int orderId) async {
    final response = await dioClient.get(ApiEndpoint.orderDetail(orderId));
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
        ? responseData['data'] as Map<String, dynamic>
        : responseData;

    final order = HistoryOrderModel.fromJson(data);
    return ApiResponse<HistoryOrderModel>.success(
      data: order,
      statusCode: response.statusCode,
    );
  }

  /// Fetch payment history for a given order
  Future<ApiResponse<List<PaymentModel>>> getPayments(int orderId) async {
    final response = await dioClient.get(ApiEndpoint.orderPayments(orderId));
    final responseData = response.data;
    List<dynamic> list = [];

    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataField = responseData['data'];
      if (dataField is List) {
        list = dataField;
      }
    } else if (responseData is List) {
      list = responseData;
    }

    final payments = list
        .map((p) => PaymentModel.fromJson(p as Map<String, dynamic>))
        .toList();

    return ApiResponse<List<PaymentModel>>.success(
      data: payments,
      statusCode: response.statusCode,
    );
  }

  /// Fetch adjustment history for a given order
  Future<ApiResponse<List<AdjustmentModel>>> getAdjustments(int orderId) async {
    final response = await dioClient.get(ApiEndpoint.orderAdjustments(orderId));
    final responseData = response.data;
    List<dynamic> list = [];

    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataField = responseData['data'];
      if (dataField is List) {
        list = dataField;
      }
    } else if (responseData is List) {
      list = responseData;
    }

    final adjustments = list
        .map((a) => AdjustmentModel.fromJson(a as Map<String, dynamic>))
        .toList();

    return ApiResponse<List<AdjustmentModel>>.success(
      data: adjustments,
      statusCode: response.statusCode,
    );
  }
}

