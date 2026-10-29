import 'package:get/get.dart';
import '../../../core/api/dio_client.dart';
import '../controllers/history_controller.dart';
import '../repositories/history_repository.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryRepository>(
      () => HistoryRepository(dioClient: Get.find<DioClient>()),
    );

    Get.lazyPut<HistoryController>(
      () => HistoryController(repository: Get.find<HistoryRepository>()),
    );
  }
}

