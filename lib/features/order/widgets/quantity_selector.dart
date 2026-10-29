import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';

class QuantitySelector extends StatelessWidget {
  final double quantity;
  final String unit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isLoading;
  final bool isCompact;

  const QuantitySelector({
    super.key,
    required this.quantity,
    this.unit = 'portion',
    required this.onIncrement,
    required this.onDecrement,
    this.isLoading = false,
    this.isCompact = false,
  });

  String _formatQty(double val) {
    if (val.truncateToDouble() == val) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final isMinOne = quantity <= 1.0;
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

          // Quantity Display
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12),
            child: Text(
              _formatQty(quantity),
              style: (isCompact ? AppTextStyle.bodySmall : AppTextStyle.bodyMedium).copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
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

