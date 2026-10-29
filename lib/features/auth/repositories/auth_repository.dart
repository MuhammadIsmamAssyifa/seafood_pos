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

  /// Login with email and password
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
    String deviceName = 'pos',
  }) async {
    final response = await dioClient.post(
      ApiEndpoint.login,
      data: {
        'email': email,
        'password': password,
        'device_name': deviceName,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final user = UserModel.fromAuthResponse(responseData);

    if (user.token != null && user.token!.isNotEmpty) {
      await storageService.saveToken(user.token!);
      await storageService.saveUserData(user.toJson());
    }

    return ApiResponse<UserModel>.success(
      data: user,
      message: responseData['message']?.toString() ?? 'Login berhasil',
      statusCode: response.statusCode,
    );
  }

  /// Login staff with username and PIN
  Future<ApiResponse<UserModel>> staffLogin({
    required String username,
    required String pin,
    String deviceName = 'pos',
  }) async {
    final response = await dioClient.post(
      ApiEndpoint.staffLogin,
      data: {
        'username': username,
        'pin': pin,
        'device_name': deviceName,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final user = UserModel.fromAuthResponse(responseData);

    if (user.token != null && user.token!.isNotEmpty) {
      await storageService.saveToken(user.token!);
      await storageService.saveUserData(user.toJson());
    }

    return ApiResponse<UserModel>.success(
      data: user,
      message: responseData['message']?.toString() ?? 'Login staff berhasil',
      statusCode: response.statusCode,
    );
  }

  /// Get current user profile from `/user`
  Future<ApiResponse<UserModel>> getProfile() async {
    final response = await dioClient.get(ApiEndpoint.user);
    final responseData = response.data as Map<String, dynamic>;

    final user = UserModel.fromJson(responseData);
    await storageService.saveUserData(user.toJson());

    return ApiResponse<UserModel>.success(
      data: user,
      statusCode: response.statusCode,
    );
  }

  /// Logout current session
  Future<void> logout() async {
    try {
      await dioClient.post(ApiEndpoint.logout);
    } catch (_) {
      // Continue cleanup even if network fails
    } finally {
      await storageService.deleteToken();
      await storageService.clearAll();
    }
  }

  Future<bool> hasValidToken() async {
    return await storageService.hasToken();
  }

  Future<UserModel?> getCachedUser() async {
    final userData = await storageService.getUserData();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }
}
