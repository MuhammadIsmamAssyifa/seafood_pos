import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seafood_pos/core/api/api_response.dart';
import 'package:seafood_pos/core/api/dio_client.dart';
import 'package:seafood_pos/features/report/controllers/report_controller.dart';
import 'package:seafood_pos/features/report/models/dashboard_summary_model.dart';
import 'package:seafood_pos/features/report/models/payment_summary_model.dart';
import 'package:seafood_pos/features/report/models/report_filter.dart';
import 'package:seafood_pos/features/report/models/sales_report_model.dart';
import 'package:seafood_pos/features/report/models/top_menu_model.dart';
import 'package:seafood_pos/features/report/repositories/report_repository.dart';
import 'package:seafood_pos/features/report/views/report_page.dart';
import 'package:seafood_pos/features/report/widgets/payment_chart.dart';
import 'package:seafood_pos/features/report/widgets/sales_chart.dart';
import 'package:seafood_pos/features/report/widgets/statistic_card.dart';
import 'package:seafood_pos/features/report/widgets/summary_card.dart';
import 'package:seafood_pos/features/report/widgets/top_menu_card.dart';

class FakeReportRepository implements ReportRepository {
  DashboardSummaryModel? mockDashboard;
  SalesReportModel? mockSales;
  PaymentSummaryModel? mockPayments;
  List<TopMenuModel> mockTopMenus;
  bool shouldSucceed;

  FakeReportRepository({
    this.mockDashboard,
    this.mockSales,
    this.mockPayments,
    this.mockTopMenus = const [],
    this.shouldSucceed = true,
  });

  @override
  DioClient get dioClient => throw UnimplementedError();

  @override
  Future<ApiResponse<DashboardSummaryModel>> getDashboard({String? date}) async {
    if (!shouldSucceed) {
      return ApiResponse<DashboardSummaryModel>.failure(message: 'Error fetching dashboard');
    }
    return ApiResponse<DashboardSummaryModel>.success(
      data: mockDashboard ??
          const DashboardSummaryModel(
            outletId: 1,
            date: '2026-10-29',
            todayRevenue: 18250000.0,
            averageTransaction: 325000.0,
            totalOrdersToday: 56,
            completedOrdersToday: 50,
          ),
    );
  }

  @override
  Future<ApiResponse<SalesReportModel>> getSales({ReportFilter? filter}) async {
    if (!shouldSucceed) {
      return ApiResponse<SalesReportModel>.failure(message: 'Error fetching sales');
    }
    return ApiResponse<SalesReportModel>.success(
      data: mockSales ??
          const SalesReportModel(
            outletId: 1,
            startDate: '2026-10-22',
            endDate: '2026-10-29',
            grossSales: 120000000.0,
            totalDiscounts: 5000000.0,
            netSales: 115000000.0,
            totalOrders: 350,
            averageOrderValue: 328571.43,
          ),
    );
  }

  @override
  Future<ApiResponse<PaymentSummaryModel>> getPayments({ReportFilter? filter}) async {
    if (!shouldSucceed) {
      return ApiResponse<PaymentSummaryModel>.failure(message: 'Error fetching payments');
    }
    return ApiResponse<PaymentSummaryModel>.success(
      data: mockPayments ??
          const PaymentSummaryModel(
            outletId: 1,
            startDate: '2026-10-22',
            endDate: '2026-10-29',
            totalCollected: 115000000.0,
            totalTransactions: 350,
            methodBreakdown: [
              PaymentMethodBreakdownModel(
                method: 'cash',
                totalAmount: 50000000.0,
                transactionCount: 150,
                percentage: 43.5,
              ),
              PaymentMethodBreakdownModel(
                method: 'transfer',
                totalAmount: 65000000.0,
                transactionCount: 200,
                percentage: 56.5,
              ),
            ],
          ),
    );
  }

  @override
  Future<ApiResponse<List<TopMenuModel>>> getTopMenu({ReportFilter? filter}) async {
    if (!shouldSucceed) {
      return ApiResponse<List<TopMenuModel>>.failure(message: 'Error fetching top menu');
    }
    return ApiResponse<List<TopMenuModel>>.success(data: mockTopMenus);
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('Sprint 11 - Report Models & Serialization Tests', () {
    test('ReportFilter generates correct labels and query parameters', () {
      const todayFilter = ReportFilter(period: ReportPeriod.today);
      expect(todayFilter.period.label, equals('Hari Ini'));
      final todayParams = todayFilter.toQueryParams();
      expect(todayParams.containsKey('start_date'), isTrue);
      expect(todayParams.containsKey('end_date'), isTrue);

      const weekFilter = ReportFilter(period: ReportPeriod.last7Days);
      expect(weekFilter.period.label, equals('7 Hari'));
      final weekParams = weekFilter.toQueryParams();
      expect(weekParams['start_date'], isNotEmpty);
      expect(weekParams['end_date'], isNotEmpty);

      final customFilter = ReportFilter(
        period: ReportPeriod.custom,
        customStartDate: DateTime(2026, 10, 1),
        customEndDate: DateTime(2026, 10, 15),
      );
      expect(customFilter.toQueryParams()['start_date'], equals('2026-10-01'));
      expect(customFilter.toQueryParams()['end_date'], equals('2026-10-15'));
    });

    test('DashboardSummaryModel parses JSON correctly with status and payment breakdowns', () {
      final json = {
        'outlet_id': 1,
        'date': '2026-10-29',
        'sales': {
          'today_revenue': 18250000.0,
          'today_cogs': 6000000.0,
          'today_gross_profit': 12250000.0,
          'today_profit_margin': 67.12,
          'average_transaction': 365000.0,
        },
        'orders': {
          'total_today': 56,
          'completed_today': 50,
          'active_orders': 6,
          'guests_today': 120,
          'status_breakdown': {
            'draft': 1,
            'submitted': 2,
            'preparing': 3,
            'ready': 0,
            'completed': 50,
          },
        },
        'payments': {
          'today_cash': 8200000.0,
          'today_transfer': 10050000.0,
          'today_qris': 0.0,
          'total_collected': 18250000.0,
        },
        'tables': {
          'total_tables': 10,
          'occupied_tables': 4,
          'available_tables': 6,
          'occupancy_rate': 40.0,
        },
        'inventory_alerts': {
          'low_stock_count': 2,
        },
      };

      final model = DashboardSummaryModel.fromJson(json);
      expect(model.todayRevenue, equals(18250000.0));
      expect(model.averageTransaction, equals(365000.0));
      expect(model.completedOrdersToday, equals(50));
      expect(model.statusBreakdown['completed'], equals(50));
      expect(model.todayCash, equals(8200000.0));
      expect(model.todayTransfer, equals(10050000.0));
      expect(model.occupancyRate, equals(40.0));
      expect(model.lowStockCount, equals(2));
    });

    test('SalesReportModel parses gross sales, net sales, and daily trends correctly', () {
      final json = {
        'outlet_id': 1,
        'start_date': '2026-10-22',
        'end_date': '2026-10-29',
        'summary': {
          'total_orders': 100,
          'total_guests': 250,
          'gross_sales': 35000000.0,
          'total_discounts': 1000000.0,
          'net_sales': 34000000.0,
          'average_order_value': 340000.0,
          'average_spend_per_guest': 136000.0,
        },
        'daily_trends': [
          {
            'date': '2026-10-29',
            'total_orders': 15,
            'gross_sales': 5000000.0,
            'discounts': 200000.0,
            'net_sales': 4800000.0,
          },
        ],
      };

      final sales = SalesReportModel.fromJson(json);
      expect(sales.grossSales, equals(35000000.0));
      expect(sales.netSales, equals(34000000.0));
      expect(sales.totalDiscounts, equals(1000000.0));
      expect(sales.dailyTrends.length, equals(1));
      expect(sales.dailyTrends.first.netSales, equals(4800000.0));
    });

    test('PaymentSummaryModel parses breakdown and helper getters', () {
      final json = {
        'outlet_id': 1,
        'start_date': '2026-10-29',
        'end_date': '2026-10-29',
        'summary': {
          'total_collected': 18250000.0,
          'total_transactions': 50,
        },
        'method_breakdown': [
          {
            'method': 'cash',
            'total_amount': 8200000.0,
            'transaction_count': 25,
            'percentage': 44.93,
          },
          {
            'method': 'transfer',
            'total_amount': 10050000.0,
            'transaction_count': 25,
            'percentage': 55.07,
          },
        ],
      };

      final payment = PaymentSummaryModel.fromJson(json);
      expect(payment.totalCollected, equals(18250000.0));
      expect(payment.cashTotal, equals(8200000.0));
      expect(payment.transferTotal, equals(10050000.0));
      expect(payment.methodBreakdown.first.methodLabel, equals('Tunai (Cash)'));
      expect(payment.methodBreakdown.last.methodLabel, equals('Transfer Bank'));
    });

    test('TopMenuModel parses ranking and display name correctly', () {
      final json = {
        'variant_id': 12,
        'menu_name': 'Ikan Etong Bakar',
        'variant_name': 'Bakar Kecap',
        'sales_unit': 'kg',
        'quantity_sold': 120.5,
        'total_revenue': 14400000.0,
        'percentage_of_sales': 25.4,
      };

      final top = TopMenuModel.fromJson(json);
      expect(top.menuName, equals('Ikan Etong Bakar'));
      expect(top.displayName, equals('Ikan Etong Bakar (Bakar Kecap)'));
      expect(top.quantitySold, equals(120.5));
      expect(top.salesUnit, equals('kg'));
      expect(top.totalRevenue, equals(14400000.0));
    });
  });

  group('Sprint 11 - ReportController Logic Tests', () {
    late FakeReportRepository repository;
    late ReportController controller;

    setUp(() {
      repository = FakeReportRepository(
        mockTopMenus: const [
          TopMenuModel(
            menuName: 'Ikan Etong Bakar',
            salesUnit: 'kg',
            quantitySold: 120,
            totalRevenue: 14400000,
          ),
          TopMenuModel(
            menuName: 'Cumi Crispy',
            salesUnit: 'portion',
            quantitySold: 95,
            totalRevenue: 3325000,
          ),
        ],
      );
      controller = ReportController(repository: repository);
    });

    test('loadAllReports loads dashboard, sales, payments, and top menu', () async {
      await controller.loadAllReports();
      expect(controller.dashboard.value, isNotNull);
      expect(controller.sales.value, isNotNull);
      expect(controller.payments.value, isNotNull);
      expect(controller.topMenus.length, equals(2));
      expect(controller.isLoading.value, isFalse);
    });

    test('changeFilter updates selectedFilter and triggers reload', () async {
      const newFilter = ReportFilter(period: ReportPeriod.last30Days);
      await controller.changeFilter(newFilter);
      expect(controller.selectedFilter.value.period, equals(ReportPeriod.last30Days));
      expect(controller.topMenus.length, equals(2));
    });

    test('refreshReport triggers full reload', () async {
      await controller.refreshReport();
      expect(controller.dashboard.value?.todayRevenue, equals(18250000.0));
    });
  });

  group('Sprint 11 - UI Widgets Tests', () {
    testWidgets('SummaryCard renders title, value, and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SummaryCard(
              title: "Today's Sales",
              value: 'Rp 18.250.000',
              subtitle: '50 order selesai',
              icon: Icons.monetization_on_rounded,
            ),
          ),
        ),
      );

      expect(find.text("Today's Sales"), findsOneWidget);
      expect(find.text('Rp 18.250.000'), findsOneWidget);
      expect(find.text('50 order selesai'), findsOneWidget);
      expect(find.byIcon(Icons.monetization_on_rounded), findsOneWidget);
    });

    testWidgets('StatisticCard renders metric label and formatted value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatisticCard(
              label: 'Total Orders',
              value: '56',
              icon: Icons.receipt_long_rounded,
            ),
          ),
        ),
      );

      expect(find.text('Total Orders'), findsOneWidget);
      expect(find.text('56'), findsOneWidget);
    });

    testWidgets('SalesChart renders trends with date labels', (tester) async {
      final trends = [
        const DailySalesTrendModel(
          date: '2026-10-28',
          totalOrders: 20,
          grossSales: 5000000,
          netSales: 4800000,
        ),
        const DailySalesTrendModel(
          date: '2026-10-29',
          totalOrders: 30,
          grossSales: 8000000,
          netSales: 7500000,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesChart(trends: trends),
          ),
        ),
      );

      expect(find.text('Tren Penjualan Harian'), findsOneWidget);
      expect(find.byType(SalesChart), findsOneWidget);
    });

    testWidgets('PaymentChart renders breakdown items and total', (tester) async {
      const summary = PaymentSummaryModel(
        outletId: 1,
        startDate: '2026-10-29',
        endDate: '2026-10-29',
        totalCollected: 18250000.0,
        totalTransactions: 50,
        methodBreakdown: [
          PaymentMethodBreakdownModel(
            method: 'cash',
            totalAmount: 8200000.0,
            transactionCount: 25,
            percentage: 44.9,
          ),
          PaymentMethodBreakdownModel(
            method: 'transfer',
            totalAmount: 10050000.0,
            transactionCount: 25,
            percentage: 55.1,
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaymentChart(paymentSummary: summary),
          ),
        ),
      );

      expect(find.text('Komposisi Metode Pembayaran'), findsOneWidget);
      expect(find.text('Tunai (Cash)'), findsOneWidget);
      expect(find.text('Transfer Bank'), findsOneWidget);
    });

    testWidgets('TopMenuCard renders rank, menu name, and quantity', (tester) async {
      const item = TopMenuModel(
        menuName: 'Ikan Etong Bakar',
        salesUnit: 'kg',
        quantitySold: 120,
        totalRevenue: 14400000,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TopMenuCard(rank: 1, item: item),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Ikan Etong Bakar'), findsOneWidget);
      expect(find.text('120 kg'), findsOneWidget);
    });

    testWidgets('ReportPage renders TabBar and dashboard summary cards', (tester) async {
      final repository = FakeReportRepository();
      Get.put<ReportController>(ReportController(repository: repository));

      await tester.pumpWidget(
        const MaterialApp(
          home: ReportPage(),
        ),
      );

      // Verify Tab headers
      expect(find.text('Ringkasan'), findsOneWidget);
      expect(find.text('Penjualan'), findsOneWidget);
      expect(find.text('Pembayaran'), findsOneWidget);
      expect(find.text('Menu Terlaris'), findsOneWidget);

      // Verify dashboard content rendered
      expect(find.text('Penjualan Hari Ini'), findsOneWidget);
      expect(find.text('Rata-rata Transaksi'), findsOneWidget);
      expect(find.text('Distribusi Status Order Hari Ini'), findsOneWidget);
    });
  });
}
