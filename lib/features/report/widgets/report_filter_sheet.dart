import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../models/report_filter.dart';

class ReportFilterSheet extends StatelessWidget {
  final ReportFilter currentFilter;
  final ValueChanged<ReportFilter> onApply;

  const ReportFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required ReportFilter currentFilter,
    required ValueChanged<ReportFilter> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportFilterSheet(
        currentFilter: currentFilter,
        onApply: onApply,
      ),
    );
  }

  Future<void> _pickCustomDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: currentFilter.customStartDate ?? now.subtract(const Duration(days: 7)),
        end: currentFilter.customEndDate ?? now,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onApply(
        ReportFilter(
          period: ReportPeriod.custom,
          customStartDate: picked.start,
          customEndDate: picked.end,
        ),
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

          Text(
            'Pilih Periode Laporan',
            style: AppTextStyle.h3,
          ),
          const SizedBox(height: 4),
          Text(
            'Sesuaikan periode waktu untuk melihat performa penjualan',
            style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
          ),
          const Divider(height: 24),

          ...[
            ReportPeriod.today,
            ReportPeriod.yesterday,
            ReportPeriod.last7Days,
            ReportPeriod.last30Days,
          ].map((period) {
            final isSelected = currentFilter.period == period;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              title: Text(
                period.label,
                style: AppTextStyle.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              onTap: () {
                onApply(ReportFilter(period: period));
                Get.back();
              },
            );
          }),

          // Custom Date Range Option
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              currentFilter.period == ReportPeriod.custom
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: currentFilter.period == ReportPeriod.custom ? AppColors.primary : AppColors.textMuted,
            ),
            title: Text(
              ReportPeriod.custom.label,
              style: AppTextStyle.bodyMedium.copyWith(
                fontWeight: currentFilter.period == ReportPeriod.custom ? FontWeight.w700 : FontWeight.w500,
                color: currentFilter.period == ReportPeriod.custom ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            trailing: const Icon(Icons.calendar_today_rounded, size: 18),
            onTap: () => _pickCustomDateRange(context),
          ),
        ],
      ),
    );
  }
}

