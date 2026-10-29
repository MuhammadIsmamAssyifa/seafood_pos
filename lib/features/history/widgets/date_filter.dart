import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../models/history_filter.dart';

class DateFilterChips extends StatelessWidget {
  final HistoryDateRange selectedRange;
  final Function(HistoryDateRange range) onSelected;
  final VoidCallback onPickCustomDate;

  const DateFilterChips({
    super.key,
    required this.selectedRange,
    required this.onSelected,
    required this.onPickCustomDate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(HistoryDateRange.all),
          const SizedBox(width: 8),
          _buildChip(HistoryDateRange.today),
          const SizedBox(width: 8),
          _buildChip(HistoryDateRange.yesterday),
          const SizedBox(width: 8),
          _buildChip(HistoryDateRange.last7Days),
          const SizedBox(width: 8),
          _buildChip(HistoryDateRange.last30Days),
          const SizedBox(width: 8),
          _buildChip(
            HistoryDateRange.custom,
            icon: Icons.date_range_rounded,
            onTap: onPickCustomDate,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    HistoryDateRange range, {
    IconData? icon,
    VoidCallback? onTap,
  }) {
    final isSelected = selectedRange == range;

    return ChoiceChip(
      avatar: icon != null
          ? Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            )
          : null,
      label: Text(range.label),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        if (onTap != null) {
          onTap();
        } else {
          onSelected(range);
        }
      },
    );
  }
}

