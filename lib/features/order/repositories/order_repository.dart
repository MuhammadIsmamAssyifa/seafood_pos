import '../../../core/api/api_endpoint.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/dio_client.dart';
import '../models/menu_model.dart';
import '../models/order_batch_model.dart';
import '../models/order_model.dart';

class OrderRepository {
  final DioClient dioClient;

  OrderRepository({required this.dioClient});

  /// Get menu catalog from backend
  Future<ApiResponse<List<MenuModel>>> getMenus() async {
    final response = await dioClient.get(ApiEndpoint.menus);
    final responseData = response.data;
    List<MenuModel> menus = [];

    if (responseData is Map<String, dynamic> && responseData['data'] is List) {
      final list = responseData['data'] as List;
      menus = list.map((item) => MenuModel.fromJson(item as Map<String, dynamic>)).toList();
    } else if (responseData is List) {
      menus = responseData.map((item) => MenuModel.fromJson(item as Map<String, dynamic>)).toList();
    }

    return ApiResponse<List<MenuModel>>.success(
      data: menus,
      statusCode: response.statusCode,
    );
  }

  /// Get order details with batches and items
  Future<ApiResponse<OrderModel>> getOrder(int orderId) async {
    final response = await dioClient.get(ApiEndpoint.orderDetail(orderId));
    final responseData = response.data as Map<String, dynamic>;

    final order = OrderModel.fromJson(responseData);
    return ApiResponse<OrderModel>.success(
      data: order,
      statusCode: response.statusCode,
    );
  }

  /// Add item (variant) to order
  Future<ApiResponse<OrderModel>> addItem({
    required int orderId,
    required int menuVariantId,
    required double quantity,
  }) async {
    final response = await dioClient.post(
      ApiEndpoint.orderItems(orderId),
      data: {
        'menu_variant_id': menuVariantId,
        'quantity': quantity,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final order = OrderModel.fromJson(responseData);

    return ApiResponse<OrderModel>.success(
      data: order,
      message: responseData['message']?.toString() ?? 'Item ditambahkan',
      statusCode: response.statusCode,
    );
  }

  /// Update item quantity
  Future<ApiResponse<OrderModel>> updateItem({
    required int orderItemId,
    required double quantity,
  }) async {
    final response = await dioClient.patch(
      ApiEndpoint.orderItemDetail(orderItemId),
      data: {
        'quantity': quantity,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final order = OrderModel.fromJson(responseData);

    return ApiResponse<OrderModel>.success(
      data: order,
      message: responseData['message']?.toString() ?? 'Quantity diperbarui',
      statusCode: response.statusCode,
    );
  }

  /// Delete item from order
  Future<ApiResponse<OrderModel>> deleteItem(int orderItemId) async {
    final response = await dioClient.delete(
      ApiEndpoint.orderItemDetail(orderItemId),
    );

    final responseData = response.data as Map<String, dynamic>;
    final order = OrderModel.fromJson(responseData);

    return ApiResponse<OrderModel>.success(
      data: order,
      message: responseData['message']?.toString() ?? 'Item dihapus',
      statusCode: response.statusCode,
    );
  }

  /// Submit batch to kitchen
  Future<ApiResponse<OrderBatchModel>> submitBatch(int batchId) async {
    final response = await dioClient.post(
      ApiEndpoint.submitBatch(batchId),
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
        ? responseData['data'] as Map<String, dynamic>
        : responseData;

    final batch = OrderBatchModel.fromJson(data);

    return ApiResponse<OrderBatchModel>.success(
      data: batch,
      message: responseData['message']?.toString() ?? 'Pesanan berhasil dikirim ke dapur.',
      statusCode: response.statusCode,
    );
  }
}

