import 'package:get/get.dart';
import '../../../core/utils/helpers.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../order/models/order_model.dart';
import '../../payment/models/payment_model.dart';
import '../../payment/models/payment_summary_model.dart';
import '../models/receipt_config_model.dart';
import '../services/connectivity_service.dart';
import '../services/printer_service.dart';
import '../services/session_service.dart';

class ReleaseController extends GetxController {
  final PrinterService printerService;
  final ReleaseConnectivityService connectivityService;
  final SessionService sessionService;

  ReleaseController({
    required this.printerService,
    required this.connectivityService,
    required this.sessionService,
  });

  // Sprint 12 required states
  RxBool get isConnected => connectivityService.isConnected;
  RxBool get isPrinting => printerService.isPrinting;
  Rxn<PrinterDevice> get printer => printerService.currentPrinter;
  RxBool get sessionExpired => sessionService.isSessionExpired;
  final RxBool isRefreshing = false.obs;

  // Additional helper states
  RxList<PrinterDevice> get scannedPrinters => printerService.availablePrinters;
  RxBool get isScanning => printerService.isScanning;
  Rx<ReceiptConfigModel> get receiptConfig => printerService.receiptConfig;

  @override
  void onInit() {
    super.onInit();
    // Reactively watch connectivity status
    ever(isConnected, (connected) {
      if (!connected) {
        AppHelpers.showWarning(
          message: 'Koneksi terputus. POS beroperasi dalam mode offline terbatas.',
          title: 'Offline',
        );
      } else if (connectivityService.wasOffline.value) {
        connectivityService.wasOffline.value = false;
        AppHelpers.showSuccess(
          message: 'Koneksi internet kembali normal.',
          title: 'Online',
        );
      }
    });
  }

  /// Sprint 12 required method: checkSession()
  Future<bool> checkSession() async {
    final valid = await sessionService.isSessionValid();
    if (!valid) {
      await sessionService.handleSessionExpired();
      return false;
    }
    return true;
  }

  /// Sprint 12 required method: retryRequest()
  Future<T?> retryRequest<T>(Future<T> Function() requestAction) async {
    try {
      final isOnline = await connectivityService.checkConnectivity();
      if (!isOnline) {
        AppHelpers.showWarning(
          message: 'Tidak ada koneksi. Harap periksa jaringan Anda sebelum mencoba lagi.',
          title: 'Jaringan Terputus',
        );
        return null;
      }
      return await requestAction();
    } catch (e) {
      AppHelpers.showError(
        message: 'Gagal memproses ulang permintaan: ${e.toString()}',
        title: 'Percobaan Gagal',
      );
      return null;
    }
  }

  /// Sprint 12 required method: refreshAll()
  Future<void> refreshAll() async {
    isRefreshing.value = true;
    try {
      await connectivityService.checkConnectivity();
      printerService.loadSavedPrinter();
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Sprint 12 required method: connectPrinter()
  Future<bool> connectPrinter(PrinterDevice device) async {
    final success = await printerService.connectPrinter(device);
    if (success) {
      AppHelpers.showSuccess(
        message: 'Printer ${device.name} berhasil terhubung.',
        title: 'Printer Terhubung',
      );
    } else {
      AppHelpers.showError(
        message: 'Gagal menghubungkan ke printer ${device.name}.',
        title: 'Koneksi Printer Gagal',
      );
    }
    return success;
  }

  /// Scan for nearby printers
  Future<void> scanPrinters() async {
    await printerService.scanPrinters();
  }

  /// Send test receipt
  Future<bool> testPrint() async {
    final success = await printerService.testPrint();
    if (success) {
      AppHelpers.showSuccess(
        message: 'Test print berhasil dikirim ke printer.',
        title: 'Test Print',
      );
    } else {
      AppHelpers.showError(
        message: 'Gagal mengirim test print ke printer.',
        title: 'Test Print Gagal',
      );
    }
    return success;
  }

  /// Sprint 12 required method: printReceipt()
  Future<bool> printReceipt(
    OrderModel order, {
    PaymentSummaryModel? summary,
    List<PaymentModel>? payments,
    double change = 0.0,
    double? cashReceived,
  }) async {
    final success = await printerService.printReceipt(
      order,
      summary: summary,
      payments: payments,
      change: change,
      cashReceived: cashReceived,
    );

    if (success) {
      AppHelpers.showSuccess(
        message: 'Struk order berhasil dicetak.',
        title: 'Cetak Struk Berhasil',
      );
    } else {
      AppHelpers.showError(
        message: 'Gagal mencetak struk.',
        title: 'Cetak Struk Gagal',
      );
    }
    return success;
  }

  /// Sprint 12 required method: logout()
  Future<void> logout() async {
    if (Get.isRegistered<AuthController>()) {
      await Get.find<AuthController>().logout();
    } else {
      await sessionService.handleSessionExpired();
    }
  }
}

