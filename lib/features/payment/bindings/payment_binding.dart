import 'package:get/get.dart';
import '../../../core/api/dio_client.dart';
import '../../order/repositories/order_repository.dart';
import '../controllers/payment_controller.dart';
import '../repositories/payment_repository.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PaymentRepository>()) {
      Get.lazyPut<PaymentRepository>(
        () => PaymentRepository(
          dioClient: Get.find<DioClient>(),
        ),
      );
    }

    if (!Get.isRegistered<OrderRepository>()) {
      Get.lazyPut<OrderRepository>(
        () => OrderRepository(
          dioClient: Get.find<DioClient>(),
        ),
      );
    }

    Get.lazyPut<PaymentController>(
      () => PaymentController(
        paymentRepository: Get.find<PaymentRepository>(),
        orderRepository: Get.isRegistered<OrderRepository>() ? Get.find<OrderRepository>() : null,
      ),
    );
  }
}

