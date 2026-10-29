import 'package:flutter/material.dart';
import '../../../app/theme/app_text_style.dart';
import '../models/stock_status.dart';

class MarketCheckBadge extends StatelessWidget {
  final bool isCompact;

  const MarketCheckBadge({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    const status = StockStatus.needMarketCheck;
    final color = status.color;
    final bgColor = status.backgroundColor;

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
          Icon(
            Icons.storefront_rounded,
            size: isCompact ? 11 : 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            'Perlu Cek Pasar',
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
        ],
      ),
    );
  }
}

