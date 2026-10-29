import 'package:flutter/material.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/stock_status.dart';

class StockBadge extends StatelessWidget {
  final StockStatus status;
  final bool isCompact;
  final double? quantity;
  final String? salesUnit;

  const StockBadge({
    super.key,
    required this.status,
    this.isCompact = false,
    this.quantity,
    this.salesUnit,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    final bgColor = status.backgroundColor;

    String displayText = status.badgeText;
    if (!isCompact && quantity != null && status != StockStatus.outOfStock) {
      final unitStr = salesUnit != null ? ' $salesUnit' : '';
      displayText = '$displayText (${AppFormatter.formatQuantity(quantity!)}$unitStr)';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withAlpha(60),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCompact ? 6 : 8,
            height: isCompact ? 6 : 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              displayText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isCompact
                  ? AppTextStyle.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    )
                  : AppTextStyle.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
