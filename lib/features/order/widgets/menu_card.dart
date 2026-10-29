import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../../inventory/widgets/stock_badge.dart';
import '../models/menu_model.dart';

class OrderMenuCard extends StatelessWidget {
  final MenuModel menu;
  final int cartQuantity;
  final VoidCallback onAdd;
  final bool isLoading;

  const OrderMenuCard({
    super.key,
    required this.menu,
    required this.cartQuantity,
    required this.onAdd,
    this.isLoading = false,
  });

  IconData _getMenuTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'seafood':
        return Icons.set_meal_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'drink':
        return Icons.local_bar_rounded;
      case 'snack':
        return Icons.cookie_rounded;
      default:
        return Icons.fastfood_rounded;
    }
  }

  Color _getBadgeColor(String type) {
    switch (type.toLowerCase()) {
      case 'seafood':
        return AppColors.secondary;
      case 'drink':
        return Colors.blue;
      case 'snack':
        return Colors.amber.shade700;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryVariant = menu.primaryVariant;
    final hasMultipleVariants = menu.variants.length > 1;
    final isOutOfStock = menu.isOutOfStock;

    final displayPrice = hasMultipleVariants
        ? 'Mulai ${AppFormatter.formatCurrency(menu.minPrice)}'
        : (primaryVariant != null
            ? AppFormatter.formatCurrency(primaryVariant.price)
            : 'Rp -');

    final stationName = primaryVariant?.station;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: cartQuantity > 0 ? AppColors.primary : AppColors.border,
          width: cartQuantity > 0 ? 1.5 : 1,
        ),
      ),
      color: isOutOfStock
          ? AppColors.surfaceMuted.withAlpha(120)
          : (cartQuantity > 0 ? AppColors.surface : AppColors.surface),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: (isLoading || isOutOfStock) ? null : onAdd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon Header with Type & Stock Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(menu.type).withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getMenuTypeIcon(menu.type),
                          color: _getBadgeColor(menu.type),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: StockBadge(
                          status: menu.stockStatus,
                          isCompact: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Menu Name & Variant
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          menu.name,
                          style: AppTextStyle.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isOutOfStock ? AppColors.textMuted : AppColors.textPrimary,
                            decoration: isOutOfStock ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (stationName != null && stationName.isNotEmpty) ...[
                              Text(
                                stationName,
                                style: AppTextStyle.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('•', style: TextStyle(color: AppColors.textMuted)),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                isOutOfStock
                                    ? 'Menu tidak tersedia'
                                    : (hasMultipleVariants
                                        ? '${menu.variants.length} Varian'
                                        : (primaryVariant?.name ?? menu.type.toUpperCase())),
                                style: AppTextStyle.caption.copyWith(
                                  color: isOutOfStock ? AppColors.error : AppColors.textSecondary,
                                  fontWeight: isOutOfStock ? FontWeight.w600 : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price and Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayPrice,
                          style: AppTextStyle.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isOutOfStock ? AppColors.textMuted : AppColors.primary,
                          ),
                        ),
                      ),
                      Material(
                        color: isOutOfStock
                            ? AppColors.border
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: (isLoading || isOutOfStock) ? null : onAdd,
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      isOutOfStock
                                          ? Icons.block_rounded
                                          : (hasMultipleVariants
                                              ? Icons.tune_rounded
                                              : Icons.add_rounded),
                                      color: isOutOfStock
                                          ? AppColors.textMuted
                                          : Colors.white,
                                      size: 18,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // In-Cart Badge Indicator
            if (cartQuantity > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        cartQuantity.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

