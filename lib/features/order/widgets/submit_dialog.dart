import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';

class SubmitOrderDialog extends StatelessWidget {
  final int batchNumber;
  final int itemCount;
  final VoidCallback onConfirm;

  const SubmitOrderDialog({
    super.key,
    required this.batchNumber,
    required this.itemCount,
    required this.onConfirm,
  });

  static Future<bool?> show({
    required BuildContext context,
    required int batchNumber,
    required int itemCount,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => SubmitOrderDialog(
        batchNumber: batchNumber,
        itemCount: itemCount,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.soup_kitchen_rounded, color: AppColors.secondary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Kirim Batch $batchNumber ke Dapur?',
              style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '$itemCount Item siap dimasak',
                  style: AppTextStyle.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pesanan yang telah dikirim ke dapur tidak dapat diubah secara langsung.',
            style: AppTextStyle.bodySmall.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Penambahan menu selanjutnya akan dibuat secara otomatis sebagai batch baru.',
            style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            minimumSize: const Size(80, 44),
          ),
          child: const Text('Batal'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Get.back(result: true);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(120, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Kirim ke Dapur', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

