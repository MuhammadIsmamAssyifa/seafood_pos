import '../../../core/api/api_endpoint.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/dio_client.dart';
import '../models/table_model.dart';
import '../models/table_status.dart';

class TableRepository {
  final DioClient dioClient;

  TableRepository({required this.dioClient});

  /// Get list of all tables
  Future<ApiResponse<List<TableModel>>> getTables({
    String? search,
    TableStatus? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (status != null) {
      queryParams['status'] = status.name;
    }

    final response = await dioClient.get(
      ApiEndpoint.tables,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final responseData = response.data;
    List<TableModel> tables = [];

    if (responseData is Map<String, dynamic> && responseData['data'] is List) {
      final list = responseData['data'] as List;
      tables = list.map((item) => TableModel.fromJson(item as Map<String, dynamic>)).toList();
    } else if (responseData is List) {
      tables = responseData.map((item) => TableModel.fromJson(item as Map<String, dynamic>)).toList();
    }

    return ApiResponse<List<TableModel>>.success(
      data: tables,
      statusCode: response.statusCode,
    );
  }

  /// Get single table detail
  Future<ApiResponse<TableModel>> getTable(int id) async {
    final response = await dioClient.get(ApiEndpoint.tableDetail(id));
    final responseData = response.data as Map<String, dynamic>;

    final dataMap = responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
        ? responseData['data'] as Map<String, dynamic>
        : responseData;

    final table = TableModel.fromJson(dataMap);
    return ApiResponse<TableModel>.success(
      data: table,
      statusCode: response.statusCode,
    );
  }

  /// Create new draft order for a table
  Future<ApiResponse<ActiveOrderSummary>> createOrder({
    required int orderTableId,
    required String customerName,
    required int guestCount,
  }) async {
    final response = await dioClient.post(
      ApiEndpoint.orders,
      data: {
        'order_table_id': orderTableId,
        'customer_name': customerName.trim(),
        'guest_count': guestCount,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final dataMap = responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
        ? responseData['data'] as Map<String, dynamic>
        : responseData;

    final orderSummary = ActiveOrderSummary.fromJson(dataMap);

    return ApiResponse<ActiveOrderSummary>.success(
      data: orderSummary,
      message: responseData['message']?.toString() ?? 'Order berhasil dibuat',
      statusCode: response.statusCode,
    );
  }

  /// Get order details by ID
  Future<ApiResponse<Map<String, dynamic>>> getOrder(int orderId) async {
    final response = await dioClient.get(ApiEndpoint.orderDetail(orderId));
    final responseData = response.data as Map<String, dynamic>;

    final dataMap = responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
        ? responseData['data'] as Map<String, dynamic>
        : responseData;

    return ApiResponse<Map<String, dynamic>>.success(
      data: dataMap,
      statusCode: response.statusCode,
    );
  }
}

