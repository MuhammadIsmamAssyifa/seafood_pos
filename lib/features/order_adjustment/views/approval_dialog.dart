import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../models/adjustment_model.dart';
import '../widgets/quantity_compare.dart';

class ApprovalDialog extends StatelessWidget {
  final AdjustmentModel adjustment;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ApprovalDialog({
    super.key,
    required this.adjustment,
    required this.onApprove,
    required this.onReject,
  });

  static Future<void> show({
    required BuildContext context,
    required AdjustmentModel adjustment,
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ApprovalDialog(
        adjustment: adjustment,
        onApprove: onApprove,
        onReject: onReject,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.rule_rounded, color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Konfirmasi Perubahan', style: AppTextStyle.h3),
                Text(
                  'Kitchen meminta penyesuaian pesanan',
                  style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(height: 16),
            Text(
              adjustment.itemName,
              style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Alasan: ${adjustment.reason}',
              style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 14),

            // Compare widget
            QuantityCompareWidget(adjustment: adjustment),

            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tanyakan kepada customer apakah setuju dengan perubahan ukuran/harga di atas.',
                      style: AppTextStyle.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            // Reject Button
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Get.back();
                  onReject();
                },
                child: const Text('Customer Menolak'),
              ),
            ),
            const SizedBox(width: 10),

            // Approve Button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Get.back();
                  onApprove();
                },
                child: const Text('Customer Setuju'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

