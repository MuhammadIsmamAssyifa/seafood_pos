import 'package:flutter/material.dart';
import '../../../app/theme/app_text_style.dart';
import '../models/stock_status.dart';

class StockWarningCard extends StatelessWidget {
  final StockStatus status;
  final String? customMessage;
  final VoidCallback? onDismiss;

  const StockWarningCard({
    super.key,
    required this.status,
    this.customMessage,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (status == StockStatus.available) {
      return const SizedBox.shrink();
    }

    final color = status.color;
    final bgColor = status.backgroundColor;

    String defaultTitle;
    String defaultMessage;

    switch (status) {
      case StockStatus.lowStock:
        defaultTitle = 'Stok Hampir Habis';
        defaultMessage = 'Pastikan kitchen masih memiliki bahan yang cukup. Anda tetap dapat melanjutkan pesanan.';
        break;
      case StockStatus.needMarketCheck:
        defaultTitle = 'Perlu Cek Pasar';
        defaultMessage = 'Internal stock habis. Kitchen akan memeriksa ketersediaan di pasar ikan. Pesanan tetap dapat dibuat.';
        break;
      case StockStatus.outOfStock:
        defaultTitle = 'Menu Tidak Tersedia';
        defaultMessage = 'Stok bahan habis dan menu ini tidak dapat dipesan saat ini.';
        break;
      default:
        defaultTitle = 'Perhatian Stok';
        defaultMessage = 'Kondisi stok perlu perhatian.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(status.icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  defaultTitle,
                  style: AppTextStyle.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  customMessage ?? defaultMessage,
                  style: AppTextStyle.caption.copyWith(
                    color: color.withAlpha(220),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close_rounded, size: 16, color: color),
            ),
        ],
      ),
    );
  }
}

