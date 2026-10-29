import 'package:intl/intl.dart';

class AppFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'id_ID');

  /// Format number to Indonesian Rupiah currency string, e.g. Rp 50.000
  static String formatCurrency(num amount) {
    try {
      return _currencyFormat.format(amount);
    } catch (_) {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }

  /// Format quantity cleanly (e.g. 1, 0.7, 1.5) with optional unit (e.g. 0.7 kg)
  static String formatQuantity(num qty, [String? unit]) {
    final double val = qty.toDouble();
    String qtyStr = val.truncateToDouble() == val
        ? val.toInt().toString()
        : val.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    if (unit != null && unit.isNotEmpty) {
      return '$qtyStr $unit';
    }
    return qtyStr;
  }

  /// Format DateTime to 'dd MMM yyyy'
  static String formatDate(DateTime dateTime) {
    try {
      return _dateFormat.format(dateTime);
    } catch (_) {
      return dateTime.toIso8601String().split('T').first;
    }
  }

  /// Format DateTime to 'dd MMM yyyy, HH:mm'
  static String formatDateTime(DateTime dateTime) {
    try {
      return _dateTimeFormat.format(dateTime);
    } catch (_) {
      return dateTime.toString();
    }
  }

  /// Format DateTime to 'HH:mm'
  static String formatTime(DateTime dateTime) {
    try {
      return _timeFormat.format(dateTime);
    } catch (_) {
      return '${dateTime.hour}:${dateTime.minute}';
    }
  }

  /// Parse string to num safely
  static num parseNumber(dynamic value, [num fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? fallback;
  }
}

