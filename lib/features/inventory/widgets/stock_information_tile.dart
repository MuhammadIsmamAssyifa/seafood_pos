import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/stock_info_model.dart';
import 'stock_badge.dart';

class StockInformationTile extends StatelessWidget {
  final StockInfoModel stockInfo;
  final VoidCallback? onTap;

  const StockInformationTile({
    super.key,
    required this.stockInfo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = stockInfo.variantName ?? stockInfo.menuName;
    final isVariant = stockInfo.variantId != null;

    final subInfo = [
      if (isVariant) 'Menu: ${stockInfo.menuName}',
      if (stockInfo.ingredientName != null) 'Bahan: ${stockInfo.ingredientName}',
      if (stockInfo.station != null) 'Stasiun: ${stockInfo.station}',
    ].join(' • ');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 0.8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stockInfo.stockStatus.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  stockInfo.stockStatus.icon,
                  color: stockInfo.stockStatus.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Title & details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subInfo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subInfo,
                        style: AppTextStyle.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Quantity & Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StockBadge(
                    status: stockInfo.stockStatus,
                    isCompact: true,
                  ),
                  if (stockInfo.stockQuantity != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${AppFormatter.formatQuantity(stockInfo.stockQuantity!)} ${stockInfo.salesUnit}',
                      style: AppTextStyle.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

