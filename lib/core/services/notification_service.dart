import 'package:get/get.dart';
import '../utils/helpers.dart';

class NotificationService extends GetxService {
  void showSuccess(String message, {String title = 'Berhasil'}) {
    AppHelpers.showSuccess(message: message, title: title);
  }

  void showError(String message, {String title = 'Gagal'}) {
    AppHelpers.showError(message: message, title: title);
  }

  void showInfo(String message, {String title = 'Info'}) {
    AppHelpers.showInfo(message: message, title: title);
  }
}

