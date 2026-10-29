import 'package:flutter/material.dart';
import '../../../app/theme/app_text_style.dart';
import '../models/table_status.dart';

class TableStatusBadge extends StatelessWidget {
  final TableStatus status;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const TableStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withAlpha(70), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: fontSize - 3, color: status.color),
          const SizedBox(width: 5),
          Text(
            status.displayName,
            style: AppTextStyle.caption.copyWith(
              color: status.color,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

