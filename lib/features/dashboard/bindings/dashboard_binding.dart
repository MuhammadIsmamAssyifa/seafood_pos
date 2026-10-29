import 'package:get/get.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../controllers/dashboard_controller.dart';
import '../repositories/dashboard_repository.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardRepository>(
      () => DashboardRepository(
        dioClient: Get.find<DioClient>(),
        storageService: Get.find<SecureStorageService>(),
      ),
    );

    Get.lazyPut<DashboardController>(
      () => DashboardController(
        dashboardRepository: Get.find<DashboardRepository>(),
      ),
    );
  }
}

