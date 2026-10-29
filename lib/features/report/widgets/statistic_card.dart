import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';

class StatisticCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? subtitle;

  const StatisticCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeColor.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: themeColor, size: 18),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyle.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

