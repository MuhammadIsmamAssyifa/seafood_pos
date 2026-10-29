import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';

class AppHelpers {
  static void showSuccess({
    required String message,
    String title = 'Berhasil',
    Duration duration = const Duration(seconds: 3),
  }) {
    if (Get.testMode || Get.context == null) return;
    try {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: duration,
        isDismissible: true,
      );
    } catch (_) {}
  }

  static void showError({
    required String message,
    String title = 'Perhatian',
    Duration duration = const Duration(seconds: 4),
  }) {
    if (Get.testMode || Get.context == null) return;
    try {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: duration,
        isDismissible: true,
      );
    } catch (_) {}
  }

  static void showWarning({
    required String message,
    String title = 'Peringatan',
    Duration duration = const Duration(seconds: 3),
  }) {
    if (Get.testMode || Get.context == null) return;
    try {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: duration,
        isDismissible: true,
      );
    } catch (_) {}
  }

  static void showInfo({
    required String message,
    String title = 'Informasi',
    Duration duration = const Duration(seconds: 3),
  }) {
    if (Get.testMode || Get.context == null) return;
    try {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.info,
        colorText: Colors.white,
        icon: const Icon(Icons.info_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: duration,
        isDismissible: true,
      );
    } catch (_) {}
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 400});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
