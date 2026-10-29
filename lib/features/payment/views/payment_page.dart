import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../controllers/payment_controller.dart';
import '../widgets/payment_history.dart';
import '../widgets/payment_input.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/remaining_amount_card.dart';

class PaymentPage extends GetView<PaymentController> {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() {
          final table = controller.order.value?.tableNumber;
          final orderNum = controller.order.value?.orderNumber;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                table != null && table.isNotEmpty ? 'Pembayaran Meja $table' : 'Pembayaran Pesanan',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              if (orderNum != null)
                Text(
                  orderNum,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () => controller.loadPaymentData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.summary.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value != null && controller.summary.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value!,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadPaymentData(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isLandscapeTablet = constraints.maxWidth >= 800;

            if (isLandscapeTablet) {
              // Two column split layout for tablet/desktop
              return RefreshIndicator(
                onRefresh: () => controller.loadPaymentData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Summary, Remaining, History
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            RemainingAmountCard(
                              summary: controller.summary.value,
                              defaultGrandTotal: controller.grandTotal,
                            ),
                            const SizedBox(height: 16),
                            PaymentSummaryCard(
                              order: controller.order.value,
                              summary: controller.summary.value,
                            ),
                            const SizedBox(height: 16),
                            PaymentHistoryWidget(
                              payments: controller.payments,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right Column: Payment Input
                      Expanded(
                        flex: 6,
                        child: PaymentInputWidget(
                          controller: controller,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Single column layout for mobile
            return RefreshIndicator(
              onRefresh: () => controller.loadPaymentData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    RemainingAmountCard(
                      summary: controller.summary.value,
                      defaultGrandTotal: controller.grandTotal,
                    ),
                    const SizedBox(height: 16),
                    PaymentInputWidget(
                      controller: controller,
                    ),
                    const SizedBox(height: 16),
                    PaymentSummaryCard(
                      order: controller.order.value,
                      summary: controller.summary.value,
                    ),
                    const SizedBox(height: 16),
                    PaymentHistoryWidget(
                      payments: controller.payments,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
