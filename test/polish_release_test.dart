import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seafood_pos/core/storage/secure_storage.dart';
import 'package:seafood_pos/features/order/models/order_item_model.dart';
import 'package:seafood_pos/features/order/models/order_model.dart';
import 'package:seafood_pos/features/payment/models/payment_model.dart';
import 'package:seafood_pos/features/payment/models/payment_summary_model.dart';
import 'package:seafood_pos/features/release/controllers/release_controller.dart';
import 'package:seafood_pos/features/release/services/connectivity_service.dart';
import 'package:seafood_pos/features/release/services/printer_service.dart';
import 'package:seafood_pos/features/release/services/session_service.dart';
import 'package:seafood_pos/features/release/widgets/empty_state.dart';
import 'package:seafood_pos/features/release/widgets/error_state.dart';
import 'package:seafood_pos/features/release/widgets/offline_banner.dart';
import 'package:seafood_pos/features/release/widgets/skeleton_loading.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Get.testMode = true;
    FlutterSecureStorage.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  group('Sprint 12 - SessionService Tests', () {
    test('isSessionValid returns true only when token exists', () async {
      final storage = SecureStorageService(isTest: true);
      final sessionService = SessionService(storageService: storage);

      await storage.deleteToken();
      expect(await sessionService.isSessionValid(), isFalse);

      await storage.saveToken('valid-bearer-token');
      expect(await sessionService.isSessionValid(), isTrue);
    });

    test('handleSessionExpired clears token and sets flag', () async {
      final storage = SecureStorageService(isTest: true);
      final sessionService = SessionService(storageService: storage);

      await storage.saveToken('jwt-token-to-expire');
      await sessionService.handleSessionExpired();

      expect(sessionService.isSessionExpired.value, isTrue);
      expect(await storage.getToken(), isNull);

      sessionService.resetSession();
      expect(sessionService.isSessionExpired.value, isFalse);
    });
  });

  group('Sprint 12 - PrinterService Tests', () {
    test('Scan printers executes without throwing and respects test environment', () async {
      final printerService = PrinterService(isTest: true);
      final printers = await printerService.scanPrinters(scanDuration: const Duration(milliseconds: 10));

      expect(printers, isA<List<PrinterDevice>>());
    });

    test('Connect and save printer updates current printer and state', () async {
      final printerService = PrinterService(isTest: true);
      final target = PrinterDevice(
        id: 'test_p1',
        name: 'Kasir BT-58',
        address: '11:22:33:44:55:66',
        paperSize: PrinterPaperSize.mm58,
      );

      final connected = await printerService.connectPrinter(target);
      expect(connected, isTrue);
      expect(printerService.currentPrinter.value?.isConnected, isTrue);
      expect(printerService.currentPrinter.value?.name, 'Kasir BT-58');

      await printerService.disconnectPrinter();
      expect(printerService.currentPrinter.value?.isConnected, isFalse);
    });

    test('Generates ESC/POS Test receipt with proper formatting', () {
      final printerService = PrinterService(isTest: true);
      final receipt58 = printerService.generateTestReceipt(PrinterPaperSize.mm58);
      expect(receipt58, contains('SEAFOOD RESTO POS'));
      expect(receipt58, contains('TEST PRINT SUCCESS'));

      final receipt80 = printerService.generateTestReceipt(PrinterPaperSize.mm80);
      expect(receipt80, contains('SEAFOOD RESTO POS'));
      expect(receipt80.length, greaterThan(receipt58.length));
    });

    test('Generates ESC/POS Order receipt with items, weights, and payments', () {
      final printerService = PrinterService(isTest: true);
      final order = OrderModel(
        id: 99,
        orderNumber: 'ORD-20261029-0099',
        tableNumber: '04',
        customerName: 'Bapak Hartono',
        subtotal: 175000,
        grandTotal: 175000,
        items: const [
          OrderItemModel(
            id: 1,
            menuVariantId: 10,
            menuName: 'Ikan Bakar Etong',
            variantName: '0.7 kg',
            quantity: 0.7,
            unit: 'kg',
            price: 150000,
            subtotal: 105000,
          ),
          OrderItemModel(
            id: 2,
            menuVariantId: 11,
            menuName: 'Es Kelapa Muda',
            quantity: 2,
            unit: 'portion',
            price: 35000,
            subtotal: 70000,
          ),
        ],
      );

      final summary = PaymentSummaryModel(
        orderId: 99,
        grandTotal: 175000,
        paid: 200000,
        remaining: 0,
      );

      final List<PaymentModel> payments = [
        PaymentModel(
          id: 1,
          orderId: 99,
          method: 'cash',
          status: 'paid',
          amount: 200000,
          paidAt: DateTime.now(),
        ),
      ];

      final receipt = printerService.generateOrderReceipt(
        order,
        summary: summary,
        payments: payments,
        change: 25000,
        paperSize: PrinterPaperSize.mm58,
      );

      expect(receipt, contains('ORD-20261029-0099'));
      expect(receipt, contains('Meja: 04'));
      expect(receipt, contains('Bapak Hartono'));
      expect(receipt, contains('0.7 kg'));
      expect(receipt, contains('Ikan Bakar Etong'));
      expect(receipt, contains('Rp 175.000'));
      expect(receipt, contains('Rp 200.000'));
      expect(receipt, contains('Rp 25.000'));
    });

    test('Receipt correctly formats concise timestamp and cash received tendered amount', () {
      final printerService = PrinterService(isTest: true);
      final order = OrderModel(
        id: 101,
        orderNumber: 'ORD-20261029-0101',
        tableNumber: '02',
        customerName: 'Ibu Ratna',
        subtotal: 100000,
        grandTotal: 100000,
        createdAt: DateTime(2026, 10, 30, 14, 30),
      );

      final payments = [
        const PaymentModel(
          id: 1,
          orderId: 101,
          method: 'cash',
          status: 'paid',
          amount: 100000,
          cashReceived: 150000,
          changeAmount: 50000,
        ),
      ];

      final receipt = printerService.generateOrderReceipt(
        order,
        payments: payments,
        change: 50000,
        cashReceived: 150000,
        paperSize: PrinterPaperSize.mm58,
      );

      // Concise receipt timestamp format (not overflowing)
      expect(receipt, contains('30/10/2026 14:30'));
      // Cash tendered printed is the actual input: Rp 150.000
      expect(receipt, contains('Rp 150.000'));
      // Change printed is Rp 50.000
      expect(receipt, contains('Rp 50.000'));
    });
  });

  group('Sprint 12 - ReleaseController Tests', () {
    test('Initializes states and coordinates services', () async {
      final storage = SecureStorageService(isTest: true);
      final sessionService = SessionService(storageService: storage);
      final printerService = PrinterService(isTest: true);
      final connectivity = ReleaseConnectivityService();

      final controller = ReleaseController(
        printerService: printerService,
        connectivityService: connectivity,
        sessionService: sessionService,
      );

      expect(controller.isConnected.value, isTrue);
      expect(controller.isPrinting.value, isFalse);
      expect(controller.isRefreshing.value, isFalse);
      expect(controller.sessionExpired.value, isFalse);

      // Check testPrint
      final testPrintResult = await controller.testPrint();
      expect(testPrintResult, isTrue);

      // Check refreshAll
      await controller.refreshAll();
      expect(controller.isRefreshing.value, isFalse);
    });
  });

  group('Sprint 12 - UI Polish Widgets Tests', () {
    testWidgets('SkeletonLoading renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SkeletonLoading.text(),
                SkeletonLoading.card(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLoading), findsNWidgets(2));
    });

    testWidgets('ReleaseEmptyState renders title, message, and action', (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReleaseEmptyState(
              title: 'Belum Ada Transaksi',
              message: 'Silakan buka pesanan baru untuk meja pelanggan.',
              action: ElevatedButton(
                onPressed: () => actionTapped = true,
                child: const Text('Buka Meja'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Belum Ada Transaksi'), findsOneWidget);
      expect(find.text('Silakan buka pesanan baru untuk meja pelanggan.'), findsOneWidget);
      expect(find.text('Buka Meja'), findsOneWidget);

      await tester.tap(find.text('Buka Meja'));
      expect(actionTapped, isTrue);
    });

    testWidgets('ReleaseErrorState and RetryButton trigger retry callback', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReleaseErrorState(
              title: 'Gagal Memuat Data',
              message: 'Koneksi ke server terputus.',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Gagal Memuat Data'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      expect(retried, isTrue);
    });

    testWidgets('OfflineBanner displays offline warning message and retry', (tester) async {
      bool retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineBanner(
              onRetry: () => retryTapped = true,
            ),
          ),
        ),
      );

      expect(find.textContaining('Tidak ada koneksi internet'), findsOneWidget);
      expect(find.text('Coba Hubungkan'), findsOneWidget);

      await tester.tap(find.text('Coba Hubungkan'));
      expect(retryTapped, isTrue);
    });
  });
}
