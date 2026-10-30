import 'package:get/get.dart';
import '../../core/api/dio_client.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/pusher_service.dart';
import '../../core/storage/secure_storage.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/release/controllers/release_controller.dart';
import '../../features/release/services/connectivity_service.dart';
import '../../features/release/services/printer_service.dart';
import '../../features/release/services/session_service.dart';

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

    // Release Services & Controllers (Sprint 12)
    final sessionService = Get.put<SessionService>(
      SessionService(storageService: storageService),
      permanent: true,
    );

    final releaseConnectivity = Get.put<ReleaseConnectivityService>(
      ReleaseConnectivityService(),
      permanent: true,
    );

    final printerService = Get.put<PrinterService>(
      PrinterService(),
      permanent: true,
    );

    Get.put<ReleaseController>(
      ReleaseController(
        printerService: printerService,
        connectivityService: releaseConnectivity,
        sessionService: sessionService,
      ),
      permanent: true,
    );
  }
}

