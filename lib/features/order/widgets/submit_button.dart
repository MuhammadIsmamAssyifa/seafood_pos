import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';

class SubmitBatchButton extends StatelessWidget {
  final int batchNumber;
  final int itemCount;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const SubmitBatchButton({
    super.key,
    required this.batchNumber,
    required this.itemCount,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) return const SizedBox.shrink();

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
      ),
      onPressed: isSubmitting ? null : onSubmit,
      icon: isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.send_rounded, size: 20),
      label: Text(
        isSubmitting
            ? 'Mengirim ke Dapur...'
            : 'Kirim Batch $batchNumber ke Dapur ($itemCount Item)',
        style: AppTextStyle.button.copyWith(color: Colors.white),
      ),
    );
  }
}

