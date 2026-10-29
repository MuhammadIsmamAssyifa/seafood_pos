import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seafood_pos/app/theme/app_theme.dart';
import 'package:seafood_pos/core/api/api_response.dart';
import 'package:seafood_pos/core/api/dio_client.dart';
import 'package:seafood_pos/core/storage/secure_storage.dart';
import 'package:seafood_pos/features/tables/controllers/table_controller.dart';
import 'package:seafood_pos/features/tables/models/table_model.dart';
import 'package:seafood_pos/features/tables/models/table_status.dart';
import 'package:seafood_pos/features/tables/repositories/table_repository.dart';
import 'package:seafood_pos/features/tables/views/create_order_dialog.dart';
import 'package:seafood_pos/features/tables/widgets/customer_form.dart';
import 'package:seafood_pos/features/tables/widgets/guest_counter.dart';
import 'package:seafood_pos/features/tables/widgets/table_card.dart';
import 'package:seafood_pos/features/tables/widgets/table_status_badge.dart';

class FakeTableRepository extends TableRepository {
  bool shouldSucceed = true;
  List<TableModel> mockTables = [];

  FakeTableRepository({required super.dioClient});

  @override
  Future<ApiResponse<List<TableModel>>> getTables({
    String? search,
    TableStatus? status,
  }) async {
    if (!shouldSucceed) {
      return ApiResponse<List<TableModel>>.failure(message: 'Error fetching tables');
    }
    return ApiResponse<List<TableModel>>.success(data: mockTables);
  }

  @override
  Future<ApiResponse<ActiveOrderSummary>> createOrder({
    required int orderTableId,
    required String customerName,
    required int guestCount,
  }) async {
    if (!shouldSucceed) {
      return ApiResponse<ActiveOrderSummary>.failure(message: 'Gagal membuat order');
    }
    final order = ActiveOrderSummary(
      id: 99,
      orderNumber: '#ORD-99',
      customerName: customerName,
      guestCount: guestCount,
      status: 'draft',
      subtotal: 0.0,
      grandTotal: 0.0,
      createdAt: DateTime.now(),
    );
    return ApiResponse<ActiveOrderSummary>.success(data: order);
  }
}

void main() {
  late SecureStorageService storageService;
  late DioClient dioClient;
  late FakeTableRepository tableRepository;
  late TableController tableController;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    storageService = SecureStorageService(isTest: true);
    dioClient = DioClient(storageService: storageService);
    tableRepository = FakeTableRepository(dioClient: dioClient);

    tableRepository.mockTables = [
      const TableModel(
        id: 1,
        number: '1',
        status: TableStatus.available,
      ),
      const TableModel(
        id: 2,
        number: '2',
        status: TableStatus.occupied,
        activeOrder: ActiveOrderSummary(
          id: 101,
          orderNumber: '#ORD-101',
          customerName: 'Pak Budi',
          guestCount: 4,
          status: 'submitted',
          subtotal: 250000.0,
        ),
      ),
    ];

    tableController = TableController(tableRepository: tableRepository);
    Get.put<TableController>(tableController);
  });

  tearDown(() {
    Get.reset();
  });

  group('Sprint 04 - TableModel & Enum Tests', () {
    test('TableStatus string parsing and properties', () {
      expect(TableStatus.fromString('available'), equals(TableStatus.available));
      expect(TableStatus.fromString('occupied'), equals(TableStatus.occupied));
      expect(TableStatus.available.displayName, equals('Tersedia'));
      expect(TableStatus.occupied.displayName, equals('Terisi'));
    });

    test('TableModel parses and sets status correctly', () {
      final json = {
        'id': 5,
        'number': '05',
        'status': 'available',
        'active_order': null,
      };

      final table = TableModel.fromJson(json);
      expect(table.id, equals(5));
      expect(table.number, equals('05'));
      expect(table.isAvailable, isTrue);
      expect(table.displayName, equals('Meja 05'));
    });

    test('Occupied TableModel parses active order', () {
      final json = {
        'id': 6,
        'number': '06',
        'status': 'occupied',
        'active_order': {
          'id': 12,
          'order_number': '#ORD-12',
          'customer_name': 'Dewi',
          'guest_count': 3,
          'status': 'draft',
          'subtotal': 180000,
        },
      };

      final table = TableModel.fromJson(json);
      expect(table.isOccupied, isTrue);
      expect(table.activeOrder?.customerName, equals('Dewi'));
      expect(table.activeOrder?.guestCount, equals(3));
      expect(table.activeOrder?.subtotal, equals(180000.0));
    });
  });

  group('Sprint 04 - TableController Tests', () {
    test('Loads tables into state and filter lists', () async {
      await tableController.loadTables();
      expect(tableController.tables.length, equals(2));
      expect(tableController.filteredTables.length, equals(2));
    });

    test('Filters tables by status', () async {
      await tableController.loadTables();

      tableController.filterByStatus(TableStatus.available);
      expect(tableController.filteredTables.length, equals(1));
      expect(tableController.filteredTables.first.id, equals(1));

      tableController.filterByStatus(TableStatus.occupied);
      expect(tableController.filteredTables.length, equals(1));
      expect(tableController.filteredTables.first.id, equals(2));

      tableController.filterByStatus(null);
      expect(tableController.filteredTables.length, equals(2));
    });

    test('Searches tables by number or customer name', () async {
      await tableController.loadTables();

      tableController.searchTables('Budi');
      expect(tableController.filteredTables.length, equals(1));
      expect(tableController.filteredTables.first.activeOrder?.customerName, equals('Pak Budi'));

      tableController.searchTables('1');
      expect(tableController.filteredTables.length, greaterThanOrEqualTo(1));
    });

    test('Creates new order successfully', () async {
      final success = await tableController.createOrder(
        tableId: 1,
        tableNumber: '1',
        customerName: 'Andi',
        guestCount: 2,
      );

      expect(success, isTrue);
    });
  });

  group('Sprint 04 - UI Widgets Tests', () {
    testWidgets('TableStatusBadge displays label and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TableStatusBadge(status: TableStatus.available),
          ),
        ),
      );

      expect(find.text('Tersedia'), findsOneWidget);
    });

    testWidgets('GuestCounter increments and decrements count', (tester) async {
      int count = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => GuestCounter(
                count: count,
                onChanged: (newCount) => setState(() => count = newCount),
              ),
            ),
          ),
        ),
      );

      expect(find.text('2 Orang'), findsOneWidget);

      // Increment
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();
      expect(find.text('3 Orang'), findsOneWidget);

      // Decrement
      await tester.tap(find.byIcon(Icons.remove_circle_outline));
      await tester.pump();
      expect(find.text('2 Orang'), findsOneWidget);
    });

    testWidgets('CustomerForm renders name field and guest counter', (tester) async {
      final nameController = TextEditingController();
      int guestCount = 2;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomerForm(
              nameController: nameController,
              guestCount: guestCount,
              onGuestCountChanged: (val) => guestCount = val,
            ),
          ),
        ),
      );

      expect(find.text('Nama Pelanggan'), findsOneWidget);
      expect(find.text('Jumlah Tamu'), findsOneWidget);
    });

    testWidgets('TableCard renders table number and active order', (tester) async {
      const table = TableModel(
        id: 2,
        number: '02',
        status: TableStatus.occupied,
        activeOrder: ActiveOrderSummary(
          id: 50,
          orderNumber: '#ORD-50',
          customerName: 'Joko',
          guestCount: 4,
          status: 'draft',
          subtotal: 150000,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: TableCard(table: table, onTap: () {}),
          ),
        ),
      );

      expect(find.text('Meja 02'), findsOneWidget);
      expect(find.text('Joko'), findsOneWidget);
      expect(find.text('4 Tamu'), findsOneWidget);
    });

    testWidgets('CreateOrderDialog validates input', (tester) async {
      const table = TableModel(id: 3, number: '03');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CreateOrderDialog(
              table: table,
              onSubmit: (name, count) async {},
            ),
          ),
        ),
      );

      expect(find.text('Buka Order Baru'), findsOneWidget);
      expect(find.text('Meja 03'), findsOneWidget);

      // Tap submit with empty name
      await tester.tap(find.text('Buat Order'));
      await tester.pump();

      expect(find.text('Nama pelanggan wajib diisi'), findsOneWidget);
    });
  });
}

