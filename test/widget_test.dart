import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seafood_pos/app/theme/app_theme.dart';
import 'package:seafood_pos/core/widgets/app_button.dart';
import 'package:seafood_pos/core/widgets/app_error.dart';
import 'package:seafood_pos/core/widgets/app_loading.dart';
import 'package:seafood_pos/core/widgets/app_text_field.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('Global Component Widget Tests', () {
    testWidgets('AppButton renders text and triggers callback', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        createTestWidget(
          AppButton(
            text: 'Simpan',
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Simpan'), findsOneWidget);
      await tester.tap(find.text('Simpan'));
      expect(pressed, isTrue);
    });

    testWidgets('AppTextField renders label and hint', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AppTextField(
            label: 'Nama Kasir',
            hint: 'Masukkan nama',
          ),
        ),
      );

      expect(find.text('Nama Kasir'), findsOneWidget);
      expect(find.text('Masukkan nama'), findsOneWidget);
    });

    testWidgets('AppLoading renders message', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AppLoading(message: 'Memuat data menu...'),
        ),
      );

      expect(find.text('Memuat data menu...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppErrorWidget renders error message and retry button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        createTestWidget(
          AppErrorWidget(
            message: 'Gagal memuat katalog',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Gagal memuat katalog'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      expect(retried, isTrue);
    });
  });
}
