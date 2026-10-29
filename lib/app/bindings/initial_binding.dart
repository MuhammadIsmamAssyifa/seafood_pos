import 'package:get/get.dart';
import '../../core/api/dio_client.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/pusher_service.dart';
import '../../core/storage/secure_storage.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/repositories/auth_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    final storageService = Get.put<SecureStorageService>(
      SecureStorageService(),
      permanent: true,
    );

    Get.put<ConnectivityService>(
      ConnectivityService(),
      permanent: true,
    );

    Get.put<NotificationService>(
      NotificationService(),
      permanent: true,
    );

    Get.put<PusherService>(
      PusherService(),
      permanent: true,
    );

    // API Client
    final dioClient = Get.put<DioClient>(
      DioClient(storageService: storageService),
      permanent: true,
    );

    // Base Auth Dependencies
    final authRepository = Get.put<AuthRepository>(
      AuthRepository(
        dioClient: dioClient,
        storageService: storageService,
      ),
      permanent: true,
    );

    Get.put<AuthController>(
      AuthController(authRepository: authRepository),
      permanent: true,
    );
  }
}

