import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/top_menu_model.dart';

class TopMenuCard extends StatelessWidget {
  final int rank;
  final TopMenuModel item;

  const TopMenuCard({
    super.key,
    required this.rank,
    required this.item,
  });

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFF59E0B); // Gold
      case 2:
        return const Color(0xFF94A3B8); // Silver
      case 3:
        return const Color(0xFFD97706); // Bronze
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: rankColor.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(color: rankColor, width: 1.2),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: rankColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Menu Name & Sales Unit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName,
                    style: AppTextStyle.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${AppFormatter.formatQuantity(item.quantitySold)} ${item.salesUnit}',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Revenue
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatter.formatCurrency(item.totalRevenue),
                  style: AppTextStyle.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (item.percentageOfSales != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${item.percentageOfSales!.toStringAsFixed(1)}% total',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

