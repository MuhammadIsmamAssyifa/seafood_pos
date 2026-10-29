import 'package:flutter/material.dart';

enum StockStatus {
  available,
  lowStock,
  outOfStock,
  needMarketCheck;

  String get label {
    switch (this) {
      case StockStatus.available:
        return 'Tersedia';
      case StockStatus.lowStock:
        return 'Stok Menipis';
      case StockStatus.outOfStock:
        return 'Habis';
      case StockStatus.needMarketCheck:
        return 'Perlu Cek Pasar';
    }
  }

  String get badgeText {
    switch (this) {
      case StockStatus.available:
        return 'Available';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
      case StockStatus.needMarketCheck:
        return 'Perlu Cek Pasar';
    }
  }

  Color get color {
    switch (this) {
      case StockStatus.available:
        return const Color(0xFF10B981); // Green
      case StockStatus.lowStock:
        return const Color(0xFFF59E0B); // Amber / Yellow
      case StockStatus.outOfStock:
        return const Color(0xFFEF4444); // Red
      case StockStatus.needMarketCheck:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  Color get backgroundColor {
    switch (this) {
      case StockStatus.available:
        return const Color(0xFFECFDF5);
      case StockStatus.lowStock:
        return const Color(0xFFFFFBEB);
      case StockStatus.outOfStock:
        return const Color(0xFFFEF2F2);
      case StockStatus.needMarketCheck:
        return const Color(0xFFEFF6FF);
    }
  }

  IconData get icon {
    switch (this) {
      case StockStatus.available:
        return Icons.check_circle_rounded;
      case StockStatus.lowStock:
        return Icons.warning_amber_rounded;
      case StockStatus.outOfStock:
        return Icons.cancel_rounded;
      case StockStatus.needMarketCheck:
        return Icons.storefront_rounded;
    }
  }

  static StockStatus fromString(String? val, {bool needMarketCheck = false}) {
    if (needMarketCheck) return StockStatus.needMarketCheck;
    if (val == null) return StockStatus.available;
    final normalized = val.toLowerCase().replaceAll(' ', '_');
    switch (normalized) {
      case 'low_stock':
      case 'lowstock':
      case 'low':
        return StockStatus.lowStock;
      case 'out_of_stock':
      case 'outofstock':
      case 'out':
      case 'habis':
        return StockStatus.outOfStock;
      case 'need_market_check':
      case 'needmarketcheck':
      case 'market_check':
        return StockStatus.needMarketCheck;
      case 'available':
      default:
        return StockStatus.available;
    }
  }
}

