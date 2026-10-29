import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_style.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const AppLoading({
    super.key,
    this.message,
    this.color,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 14),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

