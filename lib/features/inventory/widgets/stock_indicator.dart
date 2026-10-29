import 'package:flutter/material.dart';
import '../models/stock_status.dart';

class StockIndicator extends StatelessWidget {
  final StockStatus status;
  final double size;

  const StockIndicator({
    super.key,
    required this.status,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: status.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: status.color.withAlpha(80),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

