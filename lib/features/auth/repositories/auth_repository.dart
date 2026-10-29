import '../../../core/api/api_endpoint.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient dioClient;
  final SecureStorageService storageService;

  AuthRepository({
    required this.dioClient,
    required this.storageService,
  });

  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    final response = await dioClient.post(
      ApiEndpoint.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final apiResponse = ApiResponse<UserModel>.fromJson(
      responseData,
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
      statusCode: response.statusCode,
    );

    if (apiResponse.data?.token != null) {
      await storageService.saveToken(apiResponse.data!.token!);
      await storageService.saveUserSession(apiResponse.data!.toJson());
    }

    return apiResponse;
  }

  Future<ApiResponse<UserModel>> staffLogin({
    required String pin,
  }) async {
    final response = await dioClient.post(
      ApiEndpoint.staffLogin,
      data: {'pin': pin},
    );

    final responseData = response.data as Map<String, dynamic>;
    final apiResponse = ApiResponse<UserModel>.fromJson(
      responseData,
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
      statusCode: response.statusCode,
    );

    if (apiResponse.data?.token != null) {
      await storageService.saveToken(apiResponse.data!.token!);
      await storageService.saveUserSession(apiResponse.data!.toJson());
    }

    return apiResponse;
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    final response = await dioClient.get(ApiEndpoint.user);
    final responseData = response.data as Map<String, dynamic>;

    return ApiResponse<UserModel>.fromJson(
      responseData,
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
      statusCode: response.statusCode,
    );
  }

  Future<void> logout() async {
    try {
      await dioClient.post(ApiEndpoint.logout);
    } catch (_) {
      // Continue cleanup even if server logout request fails
    } finally {
      await storageService.deleteToken();
      await storageService.clearAll();
    }
  }

  Future<bool> hasValidToken() async {
    return await storageService.hasToken();
  }

  Future<UserModel?> getCachedUser() async {
    final session = await storageService.getUserSession();
    if (session != null) {
      return UserModel.fromJson(session);
    }
    return null;
  }
}
