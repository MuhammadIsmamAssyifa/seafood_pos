import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../order/controllers/order_controller.dart';
import '../../order/models/menu_model.dart';
import '../controllers/order_adjustment_controller.dart';
import '../models/adjustment_model.dart';
import '../models/adjustment_type.dart';
import '../widgets/adjustment_status_badge.dart';
import '../widgets/quantity_compare.dart';
import '../widgets/replacement_item.dart';

class AdjustmentDetailPage extends GetView<OrderAdjustmentController> {
  const AdjustmentDetailPage({super.key});

  void _showReplaceMenuModal(BuildContext context, AdjustmentModel adjustment) {
    if (!Get.isRegistered<OrderController>()) {
      Get.snackbar('Perhatian', 'Katalog menu belum tersedia.');
      return;
    }

    final orderCtrl = Get.find<OrderController>();
    final menus = orderCtrl.menus;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pilih Menu Pengganti', style: AppTextStyle.h3),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            Text(
              'Menggantikan item: ${adjustment.itemName}',
              style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
            ),
            const Divider(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: menus.length,
                itemBuilder: (context, i) {
                  final menu = menus[i];
                  return ExpansionTile(
                    title: Text(menu.name, style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text('${menu.variants.length} varian tersedia', style: AppTextStyle.caption),
                    children: menu.variants.map((v) {
                      return ListTile(
                        title: Text(v.name),
                        trailing: Text(AppFormatter.formatCurrency(v.price), style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          Get.back();
                          _showConfirmReplaceDialog(context, adjustment, v);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showConfirmReplaceDialog(BuildContext context, AdjustmentModel adjustment, MenuVariantModel variant) {
    final qtyController = TextEditingController(text: '1.0');
    final reasonController = TextEditingController(text: 'Customer memilih menu pengganti: ${variant.name}');

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Konfirmasi Penggantian', style: AppTextStyle.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Menu Baru: ${variant.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Harga: ${AppFormatter.formatCurrency(variant.price)} / ${variant.salesUnit}'),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Jumlah / Berat (${variant.salesUnit})',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Alasan Penggantian',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final qty = double.tryParse(qtyController.text.replaceAll(',', '.')) ?? 1.0;
              Get.back();
              final success = await controller.replaceItem(
                orderItemId: adjustment.orderItemId,
                menuVariantId: variant.id,
                quantity: qty,
                reason: reasonController.text.trim(),
              );
              if (success) {
                Get.back(); // return from detail page
              }
            },
            child: const Text('Ganti Menu'),
          ),
        ],
      ),
    );
  }

  void _showCancelItemDialog(BuildContext context, AdjustmentModel adjustment) {
    final reasonController = TextEditingController(text: 'Customer menolak perubahan dan membatalkan item');

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Batalkan Item', style: AppTextStyle.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah yakin ingin membatalkan item ${adjustment.itemName}?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Alasan Pembatalan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Kembali')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              Get.back();
              final success = await controller.cancelItem(
                orderItemId: adjustment.orderItemId,
                reason: reasonController.text.trim(),
              );
              if (success) {
                Get.back();
              }
            },
            child: const Text('Ya, Batalkan Item'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AdjustmentModel? item = controller.selectedAdjustment.value ??
        (Get.arguments is AdjustmentModel ? Get.arguments as AdjustmentModel : null);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Adjustment')),
        body: const Center(child: Text('Data adjustment tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penyesuaian Pesanan'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ID Adjustment #${item.id}',
                        style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                      ),
                      AdjustmentStatusBadge(status: item.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item.itemName, style: AppTextStyle.h3),
                  const SizedBox(height: 4),
                  Text(
                    'Tipe Penyesuaian: ${item.type.label}',
                    style: AppTextStyle.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  if (item.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Waktu Permintaan: ${AppFormatter.formatDateTime(item.createdAt!)}',
                      style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reason Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alasan Perubahan', style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    item.reason.isNotEmpty ? item.reason : 'Tidak ada keterangan tambahan.',
                    style: AppTextStyle.bodyMedium.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Comparison / Replacement Section
            if (item.type == AdjustmentType.replace)
              ReplacementItemWidget(adjustment: item)
            else
              QuantityCompareWidget(adjustment: item),

            const SizedBox(height: 24),

            // Actions for Pending Customer
            if (item.isPending) ...[
              Obx(() {
                final isBusy = controller.isActionLoading.value;
                return Column(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isBusy
                          ? null
                          : () async {
                              final ok = await controller.approveAdjustment(item.id);
                              if (ok) Get.back();
                            },
                      icon: isBusy
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Customer Setuju (Approve)'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isBusy
                          ? null
                          : () async {
                              final ok = await controller.rejectAdjustment(item.id);
                              if (ok) {
                                // Reload item status to show replace/cancel options
                                controller.loadAdjustment();
                              }
                            },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Customer Menolak (Reject)'),
                    ),
                  ],
                );
              }),
            ],

            // Actions for Rejected Status (Options to Replace or Cancel)
            if (item.isRejected) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withAlpha(50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Telah Menolak',
                      style: AppTextStyle.titleSmall.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Silakan tentukan menu pengganti yang disepakati bersama customer atau batalkan item ini dari pesanan.',
                      style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _showReplaceMenuModal(context, item),
                            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                            label: const Text('Ganti Menu'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _showCancelItemDialog(context, item),
                            icon: const Icon(Icons.delete_outline_rounded, size: 16),
                            label: const Text('Batalkan Item'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

