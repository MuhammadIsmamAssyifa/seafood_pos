import 'package:get/get.dart';
import '../../../core/api/dio_client.dart';
import '../controllers/inventory_controller.dart';
import '../repositories/inventory_repository.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryRepository>(
      () => InventoryRepository(dioClient: Get.find<DioClient>()),
    );

    Get.lazyPut<InventoryController>(
      () => InventoryController(repository: Get.find<InventoryRepository>()),
    );
  }
}

