import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';

class RetryButton extends StatelessWidget {
  final VoidCallback? onRetry;
  final String text;
  final bool isLoading;
  final IconData icon;

  const RetryButton({
    super.key,
    required this.onRetry,
    this.text = 'Coba Lagi',
    this.isLoading = false,
    this.icon = Icons.refresh_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: isLoading ? null : onRetry,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon, size: 20),
      label: Text(
        text,
        style: AppTextStyle.button.copyWith(color: Colors.white),
      ),
    );
  }
}

