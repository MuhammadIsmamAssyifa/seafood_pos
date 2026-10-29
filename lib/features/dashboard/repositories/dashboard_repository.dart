import '../../../core/api/api_endpoint.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../auth/models/user_model.dart';
import '../models/outlet_model.dart';

class DashboardRepository {
  final DioClient dioClient;
  final SecureStorageService storageService;

  DashboardRepository({
    required this.dioClient,
    required this.storageService,
  });

  /// Get current user profile from API with offline cached fallback
  Future<ApiResponse<UserModel>> getUserProfile() async {
    try {
      final response = await dioClient.get(ApiEndpoint.user);
      final responseData = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(responseData);
      await storageService.saveUserData(user.toJson());

      return ApiResponse<UserModel>.success(
        data: user,
        statusCode: response.statusCode,
      );
    } catch (_) {
      // Fallback to cached user in local storage
      final cached = await storageService.getUserData();
      if (cached != null) {
        return ApiResponse<UserModel>.success(
          data: UserModel.fromJson(cached),
          message: 'Data dimuat dari memori lokal',
        );
      }
      rethrow;
    }
  }

  /// Get current outlet information
  Future<OutletModel> getOutletInfo() async {
    // In production, this can call an outlet API or read from tenant/outlet configuration
    return OutletModel.defaultOutlet();
  }

  /// Logout current session
  Future<void> logout() async {
    try {
      await dioClient.post(ApiEndpoint.logout);
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await storageService.deleteToken();
      await storageService.clearAll();
    }
  }
}

