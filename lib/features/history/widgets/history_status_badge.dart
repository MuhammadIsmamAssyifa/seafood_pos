import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';

class HistoryStatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const HistoryStatusBadge({
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

    switch (status.toLowerCase()) {
      case 'completed':
        bg = AppColors.success.withAlpha(25);
        fg = AppColors.success;
        icon = Icons.check_circle_rounded;
        label = 'Selesai';
        break;
      case 'ready':
        bg = const Color(0xFF0284C7).withAlpha(25);
        fg = const Color(0xFF0284C7);
        icon = Icons.notifications_active_rounded;
        label = 'Siap Saji / Bayar';
        break;
      case 'preparing':
      case 'cooking':
        bg = AppColors.warning.withAlpha(25);
        fg = AppColors.warning;
        icon = Icons.soup_kitchen_rounded;
        label = 'Dimasak';
        break;
      case 'cancelled':
        bg = AppColors.error.withAlpha(25);
        fg = AppColors.error;
        icon = Icons.cancel_rounded;
        label = 'Dibatalkan';
        break;
      case 'draft':
      default:
        bg = AppColors.textMuted.withAlpha(25);
        fg = AppColors.textSecondary;
        icon = Icons.edit_note_rounded;
        label = 'Draft';
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

