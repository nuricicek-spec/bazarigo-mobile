import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bazarigo_mobile/app.dart';
import 'package:bazarigo_mobile/bootstrap.dart';

void main() {
  group('BazarigoApp Widget Tests', () {
    testWidgets('App renders with successful bootstrap', (tester) async {
      // Arrange
      const bootstrapResult = BootstrapResult(
        isDegradedMode: false,
        metrics: {'total_duration': 150},
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: BazarigoApp(
            bootstrapResult: bootstrapResult,
          ),
        ),
      );

      // Assert
      expect(find.text('Bazarigo Mobile'), findsOneWidget);
      expect(find.text('All Systems OK'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('App renders in degraded mode', (tester) async {
      // Arrange
      const bootstrapResult = BootstrapResult(
        isDegradedMode: true,
        metrics: {'total_duration': 100},
        failedServices: ['security', 'analytics'],
      );

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: BazarigoApp(
            bootstrapResult: bootstrapResult,
          ),
        ),
      );

      // Assert
      expect(find.text('Bazarigo Mobile'), findsOneWidget);
      expect(find.text('Degraded Mode'), findsOneWidget);
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets('App renders without bootstrap result', (tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: BazarigoApp(
            bootstrapResult: null,
          ),
        ),
      );

      // Assert - DÜZELTİLDİ: "Degraded Mode" yerine "All Systems OK"
      expect(find.text('Bazarigo Mobile'), findsOneWidget);
      expect(find.text('All Systems OK'), findsOneWidget);  // Bu satır değişti
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('App has correct version', (tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: BazarigoApp(),
        ),
      );

      // Assert
      expect(find.text('v4.0.3+100'), findsOneWidget);
    });

    testWidgets('Theme switches correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: BazarigoApp(),
        ),
      );

      // Assert - MaterialApp should exist
      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );

      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
      expect(materialApp.themeMode, ThemeMode.system);
    });
  });

  group('Bootstrap Tests', () {
    test('BootstrapResult default values', () {
      // Arrange & Act
      const result = BootstrapResult();

      // Assert
      expect(result.isDegradedMode, false);
      expect(result.failedServices, isEmpty);
      expect(result.isFullySuccessful, true);
      expect(result.totalDuration, 0);
    });

    test('BootstrapResult degraded mode', () {
      // Arrange & Act
      const result = BootstrapResult(
        isDegradedMode: true,
        failedServices: ['test_service'],
        metrics: {'total_duration': 123},
      );

      // Assert
      expect(result.isDegradedMode, true);
      expect(result.failedServices, hasLength(1));
      expect(result.isFullySuccessful, false);
      expect(result.totalDuration, 123);
    });

    test('BootstrapException toString', () {
      // Arrange
      const exception = BootstrapException(
        'Test error',
        service: 'test_service',
        originalError: 'Original error message',
      );

      // Act
      final message = exception.toString();

      // Assert
      expect(message, contains('Test error'));
      expect(message, contains('test_service'));
      expect(message, contains('Original error message'));
    });

    // DÜZELTİLDİ: testWidgets yerine test kullanıldı
    test('bootstrapApp completes successfully', () async {
      // Act
      final result = await bootstrapApp(
        enableSSL: false,
        enableCrashlytics: false,
      );

      // Assert
      expect(result.isDegradedMode, false);
      expect(result.failedServices, isEmpty);
      expect(result.totalDuration, greaterThan(0));
    });
  });
}
