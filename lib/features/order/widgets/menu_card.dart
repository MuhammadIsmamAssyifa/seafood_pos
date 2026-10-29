import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
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
      color: cartQuantity > 0 ? AppColors.surface : AppColors.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onAdd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon Header with Type Badge
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
                      if (stationName != null && stationName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border, width: 0.8),
                          ),
                          child: Text(
                            stationName,
                            style: AppTextStyle.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
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
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasMultipleVariants
                              ? '${menu.variants.length} Varian'
                              : (primaryVariant?.name ?? menu.type.toUpperCase()),
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: isLoading ? null : onAdd,
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
                                      hasMultipleVariants
                                          ? Icons.tune_rounded
                                          : Icons.add_rounded,
                                      color: Colors.white,
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

