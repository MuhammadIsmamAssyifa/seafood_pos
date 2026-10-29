import 'package:get/get.dart';
import '../../../core/api/dio_client.dart';
import '../controllers/order_adjustment_controller.dart';
import '../repositories/order_adjustment_repository.dart';

class OrderAdjustmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderAdjustmentRepository>(
      () => OrderAdjustmentRepository(dioClient: Get.find<DioClient>()),
    );

    Get.lazyPut<OrderAdjustmentController>(
      () => OrderAdjustmentController(repository: Get.find<OrderAdjustmentRepository>()),
    );
  }
}

