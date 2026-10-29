import 'package:get/get.dart';
import '../../../core/api/dio_client.dart';
import '../controllers/order_controller.dart';
import '../repositories/order_repository.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRepository>(
      () => OrderRepository(
        dioClient: Get.find<DioClient>(),
      ),
    );

    Get.lazyPut<OrderController>(
      () => OrderController(
        orderRepository: Get.find<OrderRepository>(),
      ),
    );
  }
}

