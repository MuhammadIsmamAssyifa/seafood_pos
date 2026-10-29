import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/menu_model.dart';

class VariantSelectionDialog extends StatefulWidget {
  final MenuModel menu;
  final Function(MenuVariantModel variant, double quantity) onSelect;

  const VariantSelectionDialog({
    super.key,
    required this.menu,
    required this.onSelect,
  });

  static Future<void> show({
    required BuildContext context,
    required MenuModel menu,
    required Function(MenuVariantModel variant, double quantity) onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VariantSelectionDialog(menu: menu, onSelect: onSelect),
    );
  }

  @override
  State<VariantSelectionDialog> createState() => _VariantSelectionDialogState();
}

class _VariantSelectionDialogState extends State<VariantSelectionDialog> {
  MenuVariantModel? _selectedVariant;
  double _quantity = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.menu.variants.isNotEmpty) {
      _selectedVariant = widget.menu.variants.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Menu Title & Type
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.menu.name,
                      style: AppTextStyle.h3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pilih Varian & Jumlah',
                      style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const Divider(height: 24),

          // Variant Options List
          Text(
            'Varian Menu',
            style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          ...widget.menu.variants.map((variant) {
            final isChosen = _selectedVariant?.id == variant.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _selectedVariant = variant;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isChosen ? AppColors.primary.withAlpha(15) : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isChosen ? AppColors.primary : AppColors.border,
                      width: isChosen ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isChosen ? AppColors.primary : AppColors.textMuted,
                            width: 2,
                          ),
                        ),
                        child: isChosen
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              variant.name,
                              style: AppTextStyle.bodyMedium.copyWith(
                                fontWeight: isChosen ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                            if (variant.cookingMethod != null || variant.station != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                [
                                  if (variant.cookingMethod != null) variant.cookingMethod,
                                  if (variant.station != null) 'Stasiun: ${variant.station}',
                                ].join(' • '),
                                style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        '${AppFormatter.formatCurrency(variant.price)} / ${variant.salesUnit}',
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Quantity Adjuster
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jumlah',
                style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.remove_rounded, size: 18),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity -= 1)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _quantity.toInt().toString(),
                      style: AppTextStyle.h3,
                    ),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    onPressed: () => setState(() => _quantity += 1),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Add to Cart Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _selectedVariant == null
                ? null
                : () {
                    Get.back();
                    widget.onSelect(_selectedVariant!, _quantity);
                  },
            child: Text(
              'Tambahkan ke Pesanan (${AppFormatter.formatCurrency((_selectedVariant?.price ?? 0) * _quantity)})',
              style: AppTextStyle.button,
            ),
          ),
        ],
      ),
    );
  }
}
