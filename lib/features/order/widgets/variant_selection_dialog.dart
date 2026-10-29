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
  final TextEditingController _qtyController = TextEditingController();

  bool get _isWeighed {
    final unit = (_selectedVariant?.salesUnit ?? '').toLowerCase();
    return unit == 'kg' || unit == 'gram' || unit == 'ons';
  }

  @override
  void initState() {
    super.initState();
    if (widget.menu.variants.isNotEmpty) {
      _selectedVariant = widget.menu.variants.first;
      if (_isWeighed) {
        _quantity = 0.7; // Sensible default for weighed seafood (like 0.7 kg etong)
      } else {
        _quantity = 1.0;
      }
      _qtyController.text = AppFormatter.formatQuantity(_quantity);
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _updateQuantity(double newQty) {
    if (newQty <= 0) return;
    setState(() {
      _quantity = double.parse(newQty.toStringAsFixed(3));
      _qtyController.text = AppFormatter.formatQuantity(_quantity);
    });
  }

  void _showDirectInputDialog() {
    final textController = TextEditingController(text: AppFormatter.formatQuantity(_quantity));
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _isWeighed ? 'Masukkan Berat (${_selectedVariant?.salesUnit ?? 'kg'})' : 'Masukkan Jumlah',
          style: AppTextStyle.h3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contoh: 0.5, 0.7, 1.2',
              style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixText: _selectedVariant?.salesUnit ?? '',
                hintText: '0.0',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final val = double.tryParse(textController.text.replaceAll(',', '.'));
              if (val != null && val > 0) {
                _updateQuantity(val);
                Get.back();
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
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
                        _isWeighed ? 'Tentukan Berat Timbangan' : 'Pilih Varian & Jumlah',
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
            if (widget.menu.variants.length > 1) ...[
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
              const SizedBox(height: 12),
            ],

            // Quantity & Weight Adjuster
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isWeighed ? 'Berat Pesanan' : 'Jumlah Pesanan',
                      style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Ketuk angka untuk mengetik',
                      style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      onPressed: (_isWeighed ? _quantity > 0.15 : _quantity > 1.0)
                          ? () => _updateQuantity(_quantity - (_isWeighed ? 0.1 : 1.0))
                          : null,
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _showDirectInputDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          AppFormatter.formatQuantity(_quantity, _selectedVariant?.salesUnit),
                          style: AppTextStyle.h3.copyWith(
                            color: AppColors.primary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      onPressed: () => _updateQuantity(_quantity + (_isWeighed ? 0.1 : 1.0)),
                    ),
                  ],
                ),
              ],
            ),

            // Quick weight chips for weighed seafood (kg/gram)
            if (_isWeighed) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [0.5, 0.7, 0.8, 1.0, 1.2, 1.5].map((w) {
                  final isSelected = (_quantity - w).abs() < 0.01;
                  return ChoiceChip(
                    label: Text('${w.toStringAsFixed(1)} kg'),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) _updateQuantity(w);
                    },
                  );
                }).toList(),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [1.0, 2.0, 3.0, 5.0].map((qty) {
                  final isSelected = (_quantity - qty).abs() < 0.01;
                  return ChoiceChip(
                    label: Text('${qty.toInt()}'),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) _updateQuantity(qty);
                    },
                  );
                }).toList(),
              ),
            ],

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
      ),
    );
  }
}
