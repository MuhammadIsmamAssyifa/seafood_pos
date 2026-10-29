import 'package:get/get.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../controllers/auth_controller.dart';
import '../repositories/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        dioClient: Get.find<DioClient>(),
        storageService: Get.find<SecureStorageService>(),
      ),
    );

    Get.lazyPut<AuthController>(
      () => AuthController(
        authRepository: Get.find<AuthRepository>(),
      ),
    );
  }
}

