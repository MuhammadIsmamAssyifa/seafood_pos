import '../../../core/api/api_endpoint.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/dio_client.dart';
import '../models/payment_model.dart';
import '../models/payment_summary_model.dart';

class PaymentRepository {
  final DioClient dioClient;

  PaymentRepository({required this.dioClient});

  /// Fetch payment summary for an order
  Future<ApiResponse<PaymentSummaryModel>> getSummary(int orderId) async {
    final response = await dioClient.get(ApiEndpoint.paymentSummary(orderId));
    final responseData = response.data;

    final summary = PaymentSummaryModel.fromJson(responseData as Map<String, dynamic>);
    return ApiResponse<PaymentSummaryModel>.success(
      data: summary,
      statusCode: response.statusCode,
    );
  }

  /// Create / submit a payment (cash or transfer)
  Future<ApiResponse<PaymentModel>> createPayment({
    required int orderId,
    required String method,
    required double amount,
  }) async {
    final response = await dioClient.post(
      ApiEndpoint.orderPayments(orderId),
      data: {
        'method': method,
        'amount': amount,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
        ? responseData['data'] as Map<String, dynamic>
        : responseData;

    final payment = PaymentModel.fromJson(data);
    return ApiResponse<PaymentModel>.success(
      data: payment,
      statusCode: response.statusCode,
      message: 'Pembayaran berhasil diproses',
    );
  }

  /// Fetch payment history for an order
  Future<ApiResponse<List<PaymentModel>>> getHistory(int orderId) async {
    final response = await dioClient.get(ApiEndpoint.orderPayments(orderId));
    final responseData = response.data;
    List<PaymentModel> list = [];

    if (responseData is Map<String, dynamic> && responseData['data'] is List) {
      final items = responseData['data'] as List;
      list = items.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (responseData is List) {
      list = responseData.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    return ApiResponse<List<PaymentModel>>.success(
      data: list,
      statusCode: response.statusCode,
    );
  }
}

