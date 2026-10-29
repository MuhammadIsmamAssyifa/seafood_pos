import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';

class GuestCounter extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const GuestCounter({
    super.key,
    required this.count,
    required this.onChanged,
    this.min = 1,
    this.max = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Jumlah Tamu',
          style: AppTextStyle.titleSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrement Button
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 26),
                color: count > min ? AppColors.primary : AppColors.textMuted,
                onPressed: count > min ? () => onChanged(count - 1) : null,
              ),

              // Display
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline_rounded, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '$count Orang',
                    style: AppTextStyle.h3.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),

              // Increment Button
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 26),
                color: count < max ? AppColors.primary : AppColors.textMuted,
                onPressed: count < max ? () => onChanged(count + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

