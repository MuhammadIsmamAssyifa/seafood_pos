import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';

class QuantitySelector extends StatelessWidget {
  final double quantity;
  final String unit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<double>? onQuantityChanged;
  final bool isLoading;
  final bool isCompact;

  const QuantitySelector({
    super.key,
    required this.quantity,
    this.unit = 'portion',
    required this.onIncrement,
    required this.onDecrement,
    this.onQuantityChanged,
    this.isLoading = false,
    this.isCompact = false,
  });

  bool get _isWeighed {
    final u = unit.toLowerCase();
    return u == 'kg' || u == 'gram' || u == 'ons';
  }

  void _showQuantityEditDialog(BuildContext context) {
    if (onQuantityChanged == null) return;

    final controller = TextEditingController(text: AppFormatter.formatQuantity(quantity));
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _isWeighed ? 'Ubah Berat ($unit)' : 'Ubah Jumlah',
          style: AppTextStyle.h3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isWeighed ? 'Masukkan berat (misal: 0.5, 0.7, 1.2)' : 'Masukkan jumlah pesanan',
              style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixText: unit,
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
              final val = double.tryParse(controller.text.replaceAll(',', '.'));
              if (val != null && val > 0) {
                Get.back();
                onQuantityChanged!(double.parse(val.toStringAsFixed(3)));
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
    final isMinOne = _isWeighed ? quantity <= 0.15 : quantity <= 1.0;
    final buttonSize = isCompact ? 30.0 : 36.0;
    final iconSize = isCompact ? 16.0 : 18.0;

    if (isLoading) {
      return SizedBox(
        width: isCompact ? 90 : 110,
        height: buttonSize,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement or Delete
          _buildActionButton(
            icon: isMinOne ? Icons.delete_outline_rounded : Icons.remove_rounded,
            iconColor: isMinOne ? AppColors.error : AppColors.textPrimary,
            size: buttonSize,
            iconSize: iconSize,
            onTap: onDecrement,
            tooltip: isMinOne ? 'Hapus' : 'Kurangi',
          ),

          // Quantity Display (tap to edit)
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: onQuantityChanged != null ? () => _showQuantityEditDialog(context) : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12, vertical: 4),
              child: Text(
                AppFormatter.formatQuantity(quantity),
                style: (isCompact ? AppTextStyle.bodySmall : AppTextStyle.bodyMedium).copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // Increment
          _buildActionButton(
            icon: Icons.add_rounded,
            iconColor: AppColors.primary,
            size: buttonSize,
            iconSize: iconSize,
            onTap: onIncrement,
            tooltip: 'Tambah',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required double size,
    required double iconSize,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}
