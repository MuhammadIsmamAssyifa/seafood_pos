class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT, {
    int? statusCode,
  }) {
    final bool isSuccess = json['success'] as bool? ??
        (statusCode != null && statusCode >= 200 && statusCode < 300);

    final String msg = json['message']?.toString() ??
        (isSuccess ? 'Operasi berhasil' : 'Terjadi kesalahan');

    dynamic dataContent = json['data'];
    T? parsedData;

    if (dataContent != null && fromJsonT != null) {
      parsedData = fromJsonT(dataContent);
    } else if (dataContent != null && dataContent is T) {
      parsedData = dataContent;
    }

    return ApiResponse<T>(
      success: isSuccess,
      message: msg,
      data: parsedData,
      errors: json['errors'] is Map<String, dynamic>
          ? json['errors'] as Map<String, dynamic>
          : null,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.success({
    required T data,
    String message = 'Success',
    int? statusCode = 200,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.failure({
    required String message,
    Map<String, dynamic>? errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }
}

