import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.warning;
      case 'submitted':
      case 'sent':
        return AppColors.info;
      case 'preparing':
      case 'cooking':
        return const Color(0xFF8B5CF6); // Purple / Cooking
      case 'ready':
        return const Color(0xFF06B6D4); // Cyan / Ready
      case 'completed':
      case 'served':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'draft':
        return Icons.edit_note_rounded;
      case 'submitted':
      case 'sent':
        return Icons.send_rounded;
      case 'preparing':
      case 'cooking':
        return Icons.outdoor_grill_rounded;
      case 'ready':
        return Icons.check_circle_outline_rounded;
      case 'completed':
      case 'served':
        return Icons.task_alt_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _getStatusText() {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'DRAFT';
      case 'submitted':
      case 'sent':
        return 'TERKIRIM';
      case 'preparing':
      case 'cooking':
        return 'DIMASAK';
      case 'ready':
        return 'SIAP SAJI';
      case 'completed':
      case 'served':
        return 'SELESAI';
      case 'cancelled':
        return 'BATAL';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final icon = _getStatusIcon();
    final text = _getStatusText();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 3, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyle.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

