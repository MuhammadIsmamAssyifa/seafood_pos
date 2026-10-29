import 'package:get/get.dart';
import '../../../core/api/dio_client.dart';
import '../controllers/table_controller.dart';
import '../repositories/table_repository.dart';

class TableBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TableRepository>(
      () => TableRepository(
        dioClient: Get.find<DioClient>(),
      ),
    );

    Get.lazyPut<TableController>(
      () => TableController(
        tableRepository: Get.find<TableRepository>(),
      ),
    );
  }
}

