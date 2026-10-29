import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_style.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outlined,
  danger,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final Widget? icon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 48,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      switch (variant) {
        case AppButtonVariant.primary:
          return AppColors.primary;
        case AppButtonVariant.secondary:
          return AppColors.secondary;
        case AppButtonVariant.outlined:
          return Colors.transparent;
        case AppButtonVariant.danger:
          return AppColors.error;
      }
    }

    Color getTextColor() {
      switch (variant) {
        case AppButtonVariant.outlined:
          return AppColors.primary;
        default:
          return Colors.white;
      }
    }

    BorderSide? getBorder() {
      if (variant == AppButtonVariant.outlined) {
        return const BorderSide(color: AppColors.primary, width: 1.5);
      }
      return BorderSide.none;
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          foregroundColor: getTextColor(),
          disabledBackgroundColor: getBackgroundColor().withAlpha(120),
          disabledForegroundColor: Colors.white70,
          elevation: variant == AppButtonVariant.outlined ? 0 : 0.5,
          side: getBorder(),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.button.copyWith(color: getTextColor()),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
