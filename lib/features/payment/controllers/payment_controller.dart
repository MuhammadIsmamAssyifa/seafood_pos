import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/helpers.dart';
import '../../order/models/order_model.dart';
import '../../order/repositories/order_repository.dart';
import '../models/payment_model.dart';
import '../models/payment_summary_model.dart';
import '../repositories/payment_repository.dart';

class PaymentController extends GetxController {
  final PaymentRepository paymentRepository;
  final OrderRepository? orderRepository;

  PaymentController({
    required this.paymentRepository,
    this.orderRepository,
  });

  // State
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxnString errorMessage = RxnString();

  final Rxn<OrderModel> order = Rxn<OrderModel>();
  final Rxn<PaymentSummaryModel> summary = Rxn<PaymentSummaryModel>();
  final RxList<PaymentModel> payments = <PaymentModel>[].obs;

  // Form State
  final RxString selectedMethod = 'cash'.obs; // 'cash' | 'transfer'
  final TextEditingController amountController = TextEditingController();
  final RxDouble enteredAmount = 0.0.obs;
  final RxDouble cashReceived = 0.0.obs; // For cash change calculation

  // Quick Nominals
  List<double> get quickNominals {
    final rem = remainingAmount;
    final List<double> list = [];
    if (rem > 0) {
      list.add(rem); // Uang Pas
    }
    final presets = [50000.0, 100000.0, 150000.0, 200000.0, 300000.0, 500000.0];
    for (var p in presets) {
      if (p > rem && !list.contains(p)) {
        list.add(p);
      }
    }
    return list.take(5).toList();
  }

  int? get orderId => order.value?.id ?? summary.value?.orderId;
  double get grandTotal => summary.value?.grandTotal ?? order.value?.grandTotal ?? 0.0;
  double get totalPaid => summary.value?.paid ?? 0.0;
  double get remainingAmount => summary.value?.remaining ?? (grandTotal - totalPaid);
  bool get isPaid => summary.value?.isFullyPaid ?? false;

  /// Kembalian for cash payments: if cashReceived > remainingAmount
  double get changeAmount {
    if (selectedMethod.value != 'cash') return 0.0;
    if (cashReceived.value > remainingAmount) {
      return cashReceived.value - remainingAmount;
    }
    return 0.0;
  }

  @override
  void onInit() {
    super.onInit();
    _initFromArguments();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  void _initFromArguments() {
    final args = Get.arguments;
    if (args is OrderModel) {
      order.value = args;
      loadPaymentData(args.id);
    } else if (args is int) {
      loadPaymentData(args);
    } else if (Get.parameters['id'] != null) {
      final id = int.tryParse(Get.parameters['id']!);
      if (id != null) {
        loadPaymentData(id);
      }
    }
  }

  /// Load payment summary and history
  Future<void> loadPaymentData([int? targetId]) async {
    final id = targetId ?? orderId;
    if (id == null) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final results = await Future.wait([
        paymentRepository.getSummary(id),
        paymentRepository.getHistory(id),
        if (orderRepository != null) orderRepository!.getOrder(id),
      ]);

      final summaryRes = results[0];
      final historyRes = results[1];

      if (summaryRes.success && summaryRes.data != null) {
        summary.value = summaryRes.data as PaymentSummaryModel;
      }

      if (historyRes.success && historyRes.data != null) {
        payments.assignAll(historyRes.data as List<PaymentModel>);
      }

      if (results.length > 2 && results[2].success && results[2].data != null) {
        order.value = results[2].data as OrderModel;
      }

      // Default amount input to remaining amount
      setAmount(remainingAmount);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      AppHelpers.showError(message: e.message, title: 'Gagal Memuat Pembayaran');
    } catch (e) {
      errorMessage.value = e.toString();
      AppHelpers.showError(message: e.toString(), title: 'Kesalahan Sistem');
    } finally {
      isLoading.value = false;
    }
  }

  /// Change payment method
  void selectMethod(String method) {
    selectedMethod.value = method;
    if (method == 'transfer') {
      // In transfer, amount is strictly remaining or exact amount, no cash change
      cashReceived.value = enteredAmount.value;
    }
  }

  /// Set amount manually
  void setAmount(double val) {
    enteredAmount.value = val;
    cashReceived.value = val;
    amountController.text = val > 0 ? val.toInt().toString() : '';
  }

  /// User enters cash amount received (which might exceed remaining to get change)
  void setCashReceived(double val) {
    cashReceived.value = val;
    if (val >= remainingAmount) {
      enteredAmount.value = remainingAmount;
    } else {
      enteredAmount.value = val;
    }
    amountController.text = val > 0 ? val.toInt().toString() : '';
  }

  /// Submit Payment (Cash, Transfer, or Split)
  Future<void> submitPayment() async {
    final id = orderId;
    if (id == null) {
      AppHelpers.showError(message: 'Data pesanan tidak valid');
      return;
    }

    if (remainingAmount <= 0) {
      AppHelpers.showInfo(message: 'Pesanan ini sudah lunas.');
      return;
    }

    final double toPay;
    if (selectedMethod.value == 'cash') {
      if (cashReceived.value <= 0) {
        AppHelpers.showWarning(message: 'Masukkan nominal uang tunai yang diterima');
        return;
      }
      // Amount submitted to backend cannot exceed remaining; excess is change
      toPay = cashReceived.value >= remainingAmount ? remainingAmount : cashReceived.value;
    } else {
      toPay = enteredAmount.value;
      if (toPay <= 0) {
        AppHelpers.showWarning(message: 'Masukkan nominal pembayaran transfer');
        return;
      }
      if (toPay > remainingAmount) {
        AppHelpers.showWarning(message: 'Nominal pembayaran melebihi sisa tagihan');
        return;
      }
    }

    isSubmitting.value = true;
    try {
      final res = await paymentRepository.createPayment(
        orderId: id,
        method: selectedMethod.value,
        amount: toPay,
      );

      if (res.success) {
        final lastPayment = res.data;
        final change = changeAmount;

        // Reload fresh summary and history
        await loadPaymentData(id);

        if (isPaid) {
          // Full payment completed -> Navigate to receipt/success page
          Get.offNamed(
            AppRoutes.PAYMENT + '/success',
            arguments: {
              'order': order.value,
              'summary': summary.value,
              'lastPayment': lastPayment,
              'change': change,
              'payments': payments.toList(),
            },
          );
        } else {
          // Split payment recorded, still has remaining
          AppHelpers.showSuccess(
            message: 'Pembayaran sebagian berhasil dicatat. Sisa tagihan ${AppFormatter.formatCurrency(remainingAmount)}',
          );
          // Reset input to new remaining
          setAmount(remainingAmount);
        }
      }
    } on ApiException catch (e) {
      AppHelpers.showError(
        message: e.message,
        title: 'Pembayaran Gagal',
      );
    } catch (e) {
      AppHelpers.showError(
        message: e.toString(),
        title: 'Pembayaran Gagal',
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
