import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../models/adjustment_status.dart';

class AdjustmentStatusBadge extends StatelessWidget {
  final AdjustmentStatus status;
  final bool isCompact;

  const AdjustmentStatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (status) {
      case AdjustmentStatus.pendingCustomer:
        bg = AppColors.warning.withAlpha(25);
        fg = AppColors.warning;
        icon = Icons.hourglass_top_rounded;
        label = 'Pending Customer';
        break;
      case AdjustmentStatus.approved:
        bg = AppColors.success.withAlpha(25);
        fg = AppColors.success;
        icon = Icons.check_circle_rounded;
        label = 'Approved';
        break;
      case AdjustmentStatus.rejected:
        bg = AppColors.error.withAlpha(25);
        fg = AppColors.error;
        icon = Icons.cancel_rounded;
        label = 'Rejected';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withAlpha(50), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: (isCompact ? AppTextStyle.caption : AppTextStyle.bodySmall).copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

