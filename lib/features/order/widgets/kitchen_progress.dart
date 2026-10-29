import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';

class KitchenProgressWidget extends StatelessWidget {
  final String status;
  final bool isCompact;

  const KitchenProgressWidget({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  static const List<_ProgressStep> _steps = [
    _ProgressStep(title: 'Menunggu', icon: Icons.hourglass_top_rounded),
    _ProgressStep(title: 'Dimasak', icon: Icons.outdoor_grill_rounded),
    _ProgressStep(title: 'Siap', icon: Icons.check_circle_outline_rounded),
    _ProgressStep(title: 'Disajikan', icon: Icons.task_alt_rounded),
  ];

  int _getCurrentStepIndex() {
    switch (status.toLowerCase()) {
      case 'waiting':
      case 'draft':
      case 'sent':
      case 'submitted':
        return 0; // Menunggu diterima oleh dapur
      case 'cooking':
      case 'preparing':
        return 1; // Dapur menerima & sedang memasak
      case 'ready':
        return 2; // Makanan siap disajikan
      case 'completed':
      case 'served':
        return 3; // Makanan sudah disajikan
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentStepIndex();

    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final prevStep = index ~/ 2;
            final isCompleted = prevStep < currentIndex;
            return Container(
              width: 14,
              height: 2,
              color: isCompleted ? AppColors.success : AppColors.border,
            );
          }
          final stepIndex = index ~/ 2;
          final isPastOrCurrent = stepIndex <= currentIndex;
          final isCurrent = stepIndex == currentIndex;

          return Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent
                  ? AppColors.primary
                  : (isPastOrCurrent ? AppColors.success : AppColors.border),
              border: Border.all(
                color: isCurrent ? AppColors.primaryLight : Colors.transparent,
                width: 2,
              ),
            ),
          );
        }),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_steps.length, (index) {
          final step = _steps[index];
          final isPast = index < currentIndex;
          final isCurrent = index == currentIndex;
          final color = isCurrent
              ? AppColors.primary
              : (isPast ? AppColors.success : AppColors.textMuted);

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPast
                          ? AppColors.success
                          : (isCurrent ? AppColors.primary : AppColors.surface),
                      border: Border.all(color: color, width: 1.5),
                    ),
                    child: Center(
                      child: Icon(
                        isPast ? Icons.check_rounded : step.icon,
                        size: 14,
                        color: (isPast || isCurrent) ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.title,
                    style: AppTextStyle.caption.copyWith(
                      color: color,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              if (index < _steps.length - 1)
                Container(
                  width: 24,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: index < currentIndex ? AppColors.success : AppColors.border,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _ProgressStep {
  final String title;
  final IconData icon;

  const _ProgressStep({required this.title, required this.icon});
}

