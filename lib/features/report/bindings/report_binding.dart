import 'package:get/get.dart';
import '../../../core/api/dio_client.dart';
import '../controllers/report_controller.dart';
import '../repositories/report_repository.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportRepository>(
      () => ReportRepository(dioClient: Get.find<DioClient>()),
    );

    Get.lazyPut<ReportController>(
      () => ReportController(repository: Get.find<ReportRepository>()),
    );
  }
}

