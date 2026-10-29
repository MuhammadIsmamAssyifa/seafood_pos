import '../../../core/api/api_endpoint.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/dio_client.dart';
import '../../order/models/order_item_model.dart';
import '../../order/models/order_model.dart';
import '../models/adjustment_model.dart';

class OrderAdjustmentRepository {
  final DioClient dioClient;

  OrderAdjustmentRepository({required this.dioClient});

  /// Fetch list of order adjustments / item changes
  Future<ApiResponse<List<AdjustmentModel>>> getAdjustment({
    int? orderId,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (orderId != null) queryParams['order_id'] = orderId;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final response = await dioClient.get(
      ApiEndpoint.orderItemChangesList,
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

    final adjustments = list
        .map((item) => AdjustmentModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return ApiResponse<List<AdjustmentModel>>.success(
      data: adjustments,
      statusCode: response.statusCode,
    );
  }

  /// Customer / Cashier approves adjustment
  Future<ApiResponse<AdjustmentModel>> approve(int changeId) async {
    final response = await dioClient.patch(
      ApiEndpoint.approveItemChange(changeId),
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
        ? responseData['data'] as Map<String, dynamic>
        : responseData;

    final adjustment = AdjustmentModel.fromJson(data);
    return ApiResponse<AdjustmentModel>.success(
      data: adjustment,
      statusCode: response.statusCode,
      message: responseData['message']?.toString() ?? 'Perubahan pesanan disetujui',
    );
  }

  /// Customer / Cashier rejects adjustment
  Future<ApiResponse<AdjustmentModel>> reject(int changeId) async {
    final response = await dioClient.patch(
      ApiEndpoint.rejectItemChange(changeId),
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
        ? responseData['data'] as Map<String, dynamic>
        : responseData;

    final adjustment = AdjustmentModel.fromJson(data);
    return ApiResponse<AdjustmentModel>.success(
      data: adjustment,
      statusCode: response.statusCode,
      message: responseData['message']?.toString() ?? 'Perubahan pesanan ditolak',
    );
  }

  /// Replace item with another menu variant
  Future<ApiResponse<OrderItemModel>> replace({
    required int orderItemId,
    required int menuVariantId,
    required double quantity,
    required String reason,
  }) async {
    final response = await dioClient.post(
      ApiEndpoint.orderItemReplace(orderItemId),
      data: {
        'menu_variant_id': menuVariantId,
        'quantity': quantity,
        'reason': reason,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
        ? responseData['data'] as Map<String, dynamic>
        : responseData;

    final newItem = OrderItemModel.fromJson(data);
    return ApiResponse<OrderItemModel>.success(
      data: newItem,
      statusCode: response.statusCode,
      message: responseData['message']?.toString() ?? 'Item berhasil diganti',
    );
  }

  /// Create a new adjustment request (quantity change or cancel item)
  Future<ApiResponse<AdjustmentModel>> createAdjustment({
    required int orderItemId,
    required String type,
    double? quantity,
    double? price,
    required String reason,
  }) async {
    final response = await dioClient.post(
      ApiEndpoint.orderItemChanges(orderItemId),
      data: {
        'type': type,
        if (quantity != null) 'quantity': quantity,
        if (price != null) 'price': price,
        'reason': reason,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
        ? responseData['data'] as Map<String, dynamic>
        : responseData;

    final adjustment = AdjustmentModel.fromJson(data);
    return ApiResponse<AdjustmentModel>.success(
      data: adjustment,
      statusCode: response.statusCode,
      message: responseData['message']?.toString() ?? 'Permintaan adjustment berhasil dibuat',
    );
  }

  /// Refresh order by ID
  Future<ApiResponse<OrderModel>> refreshOrder(int orderId) async {
    final response = await dioClient.get(ApiEndpoint.orderDetail(orderId));
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
        ? responseData['data'] as Map<String, dynamic>
        : responseData;

    final order = OrderModel.fromJson(data);
    return ApiResponse<OrderModel>.success(
      data: order,
      statusCode: response.statusCode,
    );
  }
}

