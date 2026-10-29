import 'package:flutter/material.dart';

enum TableStatus {
  available,
  occupied,
  reserved,
  cleaning,
  inactive;

  static TableStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'available':
      case 'kosong':
      case 'tersedia':
        return TableStatus.available;
      case 'occupied':
      case 'terisi':
        return TableStatus.occupied;
      case 'reserved':
      case 'reservasi':
        return TableStatus.reserved;
      case 'cleaning':
      case 'dibersihkan':
        return TableStatus.cleaning;
      default:
        return TableStatus.available;
    }
  }

  String get displayName {
    switch (this) {
      case TableStatus.available:
        return 'Tersedia';
      case TableStatus.occupied:
        return 'Terisi';
      case TableStatus.reserved:
        return 'Reservasi';
      case TableStatus.cleaning:
        return 'Dibersihkan';
      case TableStatus.inactive:
        return 'Non-aktif';
    }
  }

  Color get color {
    switch (this) {
      case TableStatus.available:
        return const Color(0xFF10B981); // Emerald Green
      case TableStatus.occupied:
        return const Color(0xFFEF4444); // Vibrant Red
      case TableStatus.reserved:
        return const Color(0xFF8B5CF6); // Purple
      case TableStatus.cleaning:
        return const Color(0xFFF59E0B); // Amber
      case TableStatus.inactive:
        return const Color(0xFF94A3B8); // Slate
    }
  }

  Color get backgroundColor {
    return color.withAlpha(25);
  }
}

