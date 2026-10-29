import 'package:dio/dio.dart';

enum ApiExceptionType {
  networkError,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  validationError,
  serverError,
  timeout,
  cancel,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiExceptionType type;
  final Map<String, dynamic>? errors;
  final dynamic rawData;

  ApiException({
    required this.message,
    this.statusCode,
    this.type = ApiExceptionType.unknown,
    this.errors,
    this.rawData,
  });

  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Koneksi ke server timeout. Silakan periksa jaringan Anda.',
          statusCode: dioException.response?.statusCode,
          type: ApiExceptionType.timeout,
        );

      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final responseData = dioException.response?.data;

        String errorMessage = 'Terjadi kesalahan pada server ($statusCode)';
        Map<String, dynamic>? validationErrors;

        if (responseData is Map<String, dynamic>) {
          if (responseData['message'] != null) {
            errorMessage = responseData['message'].toString();
          } else if (responseData['error'] != null) {
            errorMessage = responseData['error'].toString();
          }

          if (responseData['errors'] is Map<String, dynamic>) {
            validationErrors = responseData['errors'] as Map<String, dynamic>;
          }
        }

        switch (statusCode) {
          case 400:
            return ApiException(
              message: errorMessage,
              statusCode: statusCode,
              type: ApiExceptionType.badRequest,
              errors: validationErrors,
              rawData: responseData,
            );
          case 401:
            return ApiException(
              message: errorMessage.isEmpty ? 'Sesi berakhir, silakan login kembali.' : errorMessage,
              statusCode: statusCode,
              type: ApiExceptionType.unauthorized,
              errors: validationErrors,
              rawData: responseData,
            );
          case 403:
            return ApiException(
              message: errorMessage.isEmpty ? 'Anda tidak memiliki hak akses.' : errorMessage,
              statusCode: statusCode,
              type: ApiExceptionType.forbidden,
              errors: validationErrors,
              rawData: responseData,
            );
          case 404:
            return ApiException(
              message: errorMessage.isEmpty ? 'Data tidak ditemukan.' : errorMessage,
              statusCode: statusCode,
              type: ApiExceptionType.notFound,
              errors: validationErrors,
              rawData: responseData,
            );
          case 422:
            return ApiException(
              message: errorMessage.isEmpty ? 'Validasi gagal, mohon periksa input Anda.' : errorMessage,
              statusCode: statusCode,
              type: ApiExceptionType.validationError,
              errors: validationErrors,
              rawData: responseData,
            );
          case 500:
          case 502:
          case 503:
            return ApiException(
              message: 'Server sedang mengalami gangguan internal ($statusCode).',
              statusCode: statusCode,
              type: ApiExceptionType.serverError,
              rawData: responseData,
            );
          default:
            return ApiException(
              message: errorMessage,
              statusCode: statusCode,
              type: ApiExceptionType.unknown,
              errors: validationErrors,
              rawData: responseData,
            );
        }

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Permintaan dibatalkan.',
          type: ApiExceptionType.cancel,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Tidak dapat terhubung ke server. Periksa koneksi internet atau IP server.',
          type: ApiExceptionType.networkError,
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Sertifikat keamanan server tidak valid.',
          type: ApiExceptionType.networkError,
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: dioException.message ?? 'Terjadi kesalahan tidak terduga.',
          type: ApiExceptionType.unknown,
        );
    }
  }

  /// Get first validation error message if available
  String? get firstValidationError {
    if (errors == null || errors!.isEmpty) return null;
    final firstEntry = errors!.values.first;
    if (firstEntry is List && firstEntry.isNotEmpty) {
      return firstEntry.first.toString();
    }
    return firstEntry.toString();
  }

  @override
  String toString() => 'ApiException(status: $statusCode, type: $type, message: $message)';
}

