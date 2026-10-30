import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seafood_pos/app/theme/app_theme.dart';
import 'package:seafood_pos/core/api/api_response.dart';
import 'package:seafood_pos/core/api/dio_client.dart';
import 'package:seafood_pos/core/storage/secure_storage.dart';
import 'package:seafood_pos/features/order/models/order_model.dart';
import 'package:seafood_pos/features/order/repositories/order_repository.dart';
import 'package:seafood_pos/features/payment/controllers/payment_controller.dart';
import 'package:seafood_pos/features/payment/models/payment_model.dart';
import 'package:seafood_pos/features/payment/models/payment_summary_model.dart';
import 'package:seafood_pos/features/payment/repositories/payment_repository.dart';
import 'package:seafood_pos/features/payment/widgets/payment_history.dart';
import 'package:seafood_pos/features/payment/widgets/payment_method_button.dart';
import 'package:seafood_pos/features/payment/widgets/payment_summary_card.dart';
import 'package:seafood_pos/features/payment/widgets/remaining_amount_card.dart';

class FakePaymentRepository extends PaymentRepository {
  bool shouldSucceed = true;
  PaymentSummaryModel mockSummary;
  List<PaymentModel> mockPayments = [];
  int createPaymentCount = 0;

  FakePaymentRepository({
    required super.dioClient,
    required this.mockSummary,
  });

  @override
  Future<ApiResponse<PaymentSummaryModel>> getSummary(int orderId) async {
    if (!shouldSucceed) {
      return ApiResponse<PaymentSummaryModel>.failure(message: 'Gagal memuat ringkasan');
    }
    return ApiResponse<PaymentSummaryModel>.success(data: mockSummary);
  }

  @override
  Future<ApiResponse<List<PaymentModel>>> getHistory(int orderId) async {
    if (!shouldSucceed) {
      return ApiResponse<List<PaymentModel>>.failure(message: 'Gagal memuat riwayat');
    }
    return ApiResponse<List<PaymentModel>>.success(data: mockPayments);
  }

  @override
  Future<ApiResponse<PaymentModel>> createPayment({
    required int orderId,
    required String method,
    required double amount,
    double? cashReceived,
    double? changeAmount,
  }) async {
    createPaymentCount++;
    if (!shouldSucceed) {
      return ApiResponse<PaymentModel>.failure(message: 'Gagal memproses pembayaran');
    }

    final newPayment = PaymentModel(
      id: mockPayments.length + 1,
      orderId: orderId,
      method: method,
      status: 'paid',
      amount: amount,
      cashReceived: cashReceived,
      changeAmount: changeAmount,
      createdAt: DateTime.now(),
    );

    mockPayments.add(newPayment);

    final newPaid = mockSummary.paid + amount;
    final newRemaining = (mockSummary.grandTotal - newPaid).clamp(0.0, double.infinity);

    mockSummary = PaymentSummaryModel(
      orderId: orderId,
      grandTotal: mockSummary.grandTotal,
      paid: newPaid,
      remaining: newRemaining,
    );

    return ApiResponse<PaymentModel>.success(
      data: newPayment,
      message: 'Pembayaran berhasil',
    );
  }
}

class FakeOrderRepository extends OrderRepository {
  OrderModel? mockOrder;

  FakeOrderRepository({required super.dioClient});

  @override
  Future<ApiResponse<OrderModel>> getOrder(int orderId) async {
    return ApiResponse<OrderModel>.success(
      data: mockOrder ??
          OrderModel(
            id: orderId,
            orderNumber: 'ORD-12345',
            customerName: 'Budi Santoso',
            tableNumber: 'A1',
            grandTotal: 150000,
            subtotal: 150000,
          ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePaymentRepository fakePaymentRepo;
  late FakeOrderRepository fakeOrderRepo;
  late PaymentController controller;
  late DioClient dummyDio;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    dummyDio = DioClient(storageService: SecureStorageService(isTest: true));

    fakePaymentRepo = FakePaymentRepository(
      dioClient: dummyDio,
      mockSummary: const PaymentSummaryModel(
        orderId: 10,
        grandTotal: 150000.0,
        paid: 0.0,
        remaining: 150000.0,
      ),
    );

    fakeOrderRepo = FakeOrderRepository(dioClient: dummyDio);

    controller = PaymentController(
      paymentRepository: fakePaymentRepo,
      orderRepository: fakeOrderRepo,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('Payment Models & Calculation Tests', () {
    test('PaymentSummaryModel calculations and status flags', () {
      final unpaid = const PaymentSummaryModel(
        orderId: 1,
        grandTotal: 200000,
        paid: 0,
        remaining: 200000,
      );
      expect(unpaid.isFullyPaid, false);
      expect(unpaid.hasPartialPayment, false);
      expect(unpaid.paymentProgress, 0.0);

      final partial = const PaymentSummaryModel(
        orderId: 1,
        grandTotal: 200000,
        paid: 100000,
        remaining: 100000,
      );
      expect(partial.isFullyPaid, false);
      expect(partial.hasPartialPayment, true);
      expect(partial.paymentProgress, 0.5);

      final fullyPaid = const PaymentSummaryModel(
        orderId: 1,
        grandTotal: 200000,
        paid: 200000,
        remaining: 0,
      );
      expect(fullyPaid.isFullyPaid, true);
      expect(fullyPaid.hasPartialPayment, false);
      expect(fullyPaid.paymentProgress, 1.0);
    });

    test('PaymentModel helper methods and labels', () {
      final cashPayment = PaymentModel(
        id: 1,
        orderId: 10,
        method: 'cash',
        status: 'paid',
        amount: 50000,
      );
      expect(cashPayment.isCash, true);
      expect(cashPayment.isTransfer, false);
      expect(cashPayment.isPaid, true);
      expect(cashPayment.methodLabel, 'Cash (Tunai)');

      final transferPayment = PaymentModel(
        id: 2,
        orderId: 10,
        method: 'transfer',
        status: 'paid',
        amount: 100000,
      );
      expect(transferPayment.isCash, false);
      expect(transferPayment.isTransfer, true);
      expect(transferPayment.methodLabel, 'Transfer Bank');
    });
  });

  group('Payment Controller Logic Tests', () {
    test('Load payment data initializes summary and default amount', () async {
      await controller.loadPaymentData(10);

      expect(controller.summary.value, isNotNull);
      expect(controller.grandTotal, 150000.0);
      expect(controller.remainingAmount, 150000.0);
      expect(controller.enteredAmount.value, 150000.0);
      expect(controller.isPaid, false);
    });

    test('Method selection and quick nominals', () async {
      await controller.loadPaymentData(10);

      controller.selectMethod('transfer');
      expect(controller.selectedMethod.value, 'transfer');

      controller.selectMethod('cash');
      expect(controller.selectedMethod.value, 'cash');

      expect(controller.quickNominals, contains(150000.0)); // Uang Pas
    });

    test('Cash payment change (kembalian) calculation', () async {
      await controller.loadPaymentData(10); // Tagihan 150.000

      // Customer gives 200.000 cash
      controller.setCashReceived(200000.0);

      expect(controller.cashReceived.value, 200000.0);
      expect(controller.enteredAmount.value, 150000.0); // Backend receives capped remaining
      expect(controller.changeAmount, 50000.0); // Kembalian 50.000
    });

    test('Submit full cash payment completes order', () async {
      await controller.loadPaymentData(10);
      controller.setCashReceived(150000.0);

      await controller.submitPayment();

      expect(fakePaymentRepo.createPaymentCount, 1);
      expect(controller.summary.value?.remaining, 0.0);
      expect(controller.isPaid, true);
    });

    test('Split payment handles multiple partial transactions', () async {
      await controller.loadPaymentData(10); // Tagihan 150.000

      // Step 1: Bayar Rp 100.000 via Cash
      controller.selectMethod('cash');
      controller.setCashReceived(100000.0);
      await controller.submitPayment();

      expect(fakePaymentRepo.createPaymentCount, 1);
      expect(controller.summary.value?.paid, 100000.0);
      expect(controller.summary.value?.remaining, 50000.0);
      expect(controller.isPaid, false);

      // Step 2: Bayar sisa Rp 50.000 via Transfer
      controller.selectMethod('transfer');
      controller.setAmount(50000.0);
      await controller.submitPayment();

      expect(fakePaymentRepo.createPaymentCount, 2);
      expect(controller.summary.value?.paid, 150000.0);
      expect(controller.summary.value?.remaining, 0.0);
      expect(controller.isPaid, true);
      expect(controller.payments.length, 2);
    });
  });

  group('Payment UI Widgets Tests', () {
    testWidgets('PaymentSummaryCard renders order info and financial rows', (tester) async {
      final summary = const PaymentSummaryModel(
        orderId: 10,
        grandTotal: 175000.0,
        paid: 50000.0,
        remaining: 125000.0,
      );

      final order = const OrderModel(
        id: 10,
        orderNumber: 'ORD-999',
        customerName: 'Pak Joko',
        tableNumber: '5',
        subtotal: 175000.0,
        grandTotal: 175000.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: PaymentSummaryCard(order: order, summary: summary),
          ),
        ),
      );

      expect(find.text('Pak Joko'), findsOneWidget);
      expect(find.textContaining('Meja 5'), findsOneWidget);
      expect(find.text('Total Tagihan'), findsOneWidget);
      expect(find.text('Sisa Pembayaran'), findsOneWidget);
    });

    testWidgets('RemainingAmountCard renders progress and remaining correctly', (tester) async {
      final summary = const PaymentSummaryModel(
        orderId: 10,
        grandTotal: 200000.0,
        paid: 100000.0,
        remaining: 100000.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: RemainingAmountCard(summary: summary),
          ),
        ),
      );

      expect(find.text('Sisa Pembayaran'), findsOneWidget);
      expect(find.text('SEBAGIAN'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('PaymentMethodButton toggles selection accurately', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Row(
              children: [
                PaymentMethodButton(
                  method: 'cash',
                  title: 'Tunai',
                  subtitle: 'Uang Cash',
                  icon: Icons.payments_rounded,
                  isSelected: true,
                  onTap: () {
                    tapped = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tunai'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      await tester.tap(find.text('Tunai'));
      expect(tapped, true);
    });

    testWidgets('PaymentHistoryWidget displays transaction list', (tester) async {
      final payments = [
        PaymentModel(
          id: 1,
          orderId: 10,
          method: 'cash',
          status: 'paid',
          amount: 50000,
          createdAt: DateTime(2026, 10, 29, 14, 0),
        ),
        PaymentModel(
          id: 2,
          orderId: 10,
          method: 'transfer',
          status: 'paid',
          amount: 100000,
          createdAt: DateTime(2026, 10, 29, 14, 15),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: PaymentHistoryWidget(payments: payments),
            ),
          ),
        ),
      );

      expect(find.text('Riwayat Pembayaran'), findsOneWidget);
      expect(find.text('Cash (Tunai)'), findsOneWidget);
      expect(find.text('Transfer Bank'), findsOneWidget);
    });
  });
}

class FakeSecureStorageService extends SecureStorageService {
  @override
  Future<String?> getToken() async => 'dummy_token';
}
