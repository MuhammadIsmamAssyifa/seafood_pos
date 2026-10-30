import 'package:get/get.dart';
import '../../../core/storage/secure_storage.dart';
import '../controllers/release_controller.dart';
import '../services/connectivity_service.dart';
import '../services/printer_service.dart';
import '../services/session_service.dart';

class ReleaseBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReleaseConnectivityService>()) {
      Get.put<ReleaseConnectivityService>(
        ReleaseConnectivityService(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<SessionService>()) {
      Get.put<SessionService>(
        SessionService(
          storageService: Get.find<SecureStorageService>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<PrinterService>()) {
      Get.put<PrinterService>(
        PrinterService(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ReleaseController>()) {
      Get.put<ReleaseController>(
        ReleaseController(
          printerService: Get.find<PrinterService>(),
          connectivityService: Get.find<ReleaseConnectivityService>(),
          sessionService: Get.find<SessionService>(),
        ),
        permanent: true,
      );
    }
  }
}

