import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/formatter.dart';
import '../models/history_filter.dart';

class HistoryFilterSheet extends StatefulWidget {
  final HistoryFilter currentFilter;
  final Function(HistoryFilter filter) onApply;

  const HistoryFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required HistoryFilter currentFilter,
    required Function(HistoryFilter filter) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HistoryFilterSheet(
        currentFilter: currentFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends State<HistoryFilterSheet> {
  late String? _selectedStatus;
  late HistoryDateRange _selectedDateRange;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, String?>> _statusOptions = [
    {'label': 'Semua Status', 'value': null},
    {'label': 'Selesai (Completed)', 'value': 'completed'},
    {'label': 'Siap Bayar (Ready)', 'value': 'ready'},
    {'label': 'Dimasak (Preparing)', 'value': 'preparing'},
    {'label': 'Draft', 'value': 'draft'},
    {'label': 'Dibatalkan (Cancelled)', 'value': 'cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentFilter.status;
    _selectedDateRange = widget.currentFilter.dateRange;
    _startDate = widget.currentFilter.startDate;
    _endDate = widget.currentFilter.endDate;
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(start: DateTime.now().subtract(const Duration(days: 7)), end: DateTime.now()),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = HistoryDateRange.custom;
        _startDate = picked.start;
        _endDate = picked.end;
      });
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
          // Drag Handle
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter Transaksi', style: AppTextStyle.h3),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Get.back()),
            ],
          ),
          const Divider(height: 20),

          // Status Filter
          Text('Status Pesanan', style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusOptions.map((opt) {
              final isSelected = _selectedStatus == opt['value'];
              return ChoiceChip(
                label: Text(opt['label']!),
                selected: isSelected,
                showCheckmark: false,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? opt['value'] : null;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Date Range Filter
          Text('Rentang Tanggal', style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HistoryDateRange.values.map((range) {
              final isSelected = _selectedDateRange == range;
              return ChoiceChip(
                label: Text(range.label),
                selected: isSelected,
                showCheckmark: false,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (range == HistoryDateRange.custom) {
                    _pickDateRange(context);
                  } else {
                    setState(() {
                      _selectedDateRange = range;
                      _startDate = null;
                      _endDate = null;
                    });
                  }
                },
              );
            }).toList(),
          ),

          if (_selectedDateRange == HistoryDateRange.custom && _startDate != null && _endDate != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_note_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${AppFormatter.formatDate(_startDate!)} - ${AppFormatter.formatDate(_endDate!)}',
                    style: AppTextStyle.caption.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedStatus = null;
                      _selectedDateRange = HistoryDateRange.all;
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Get.back();
                    widget.onApply(widget.currentFilter.copyWith(
                      status: _selectedStatus,
                      clearStatus: _selectedStatus == null,
                      dateRange: _selectedDateRange,
                      startDate: _startDate,
                      endDate: _endDate,
                    ));
                  },
                  child: const Text('Terapkan Filter'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

