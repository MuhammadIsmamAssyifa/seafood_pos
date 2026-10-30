import 'package:get/get.dart';
import '../../../core/api/dio_client.dart';
import '../../order/repositories/order_repository.dart';
import '../controllers/menu_catalog_controller.dart';

class MenuBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OrderRepository>()) {
      Get.lazyPut<OrderRepository>(
        () => OrderRepository(dioClient: Get.find<DioClient>()),
      );
    }

    Get.lazyPut<MenuCatalogController>(
      () => MenuCatalogController(orderRepository: Get.find<OrderRepository>()),
    );
  }
}

