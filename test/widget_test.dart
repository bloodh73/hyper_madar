import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:product_manager/main.dart';
import 'package:product_manager/providers/product_provider.dart';

void main() {
  group('Product Manager App Tests', () {
    testWidgets('App should start without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProductProvider(),
          child: const MyApp(),
        ),
      );

      // Verify that the app starts correctly
      expect(find.text('مدیریت محصولات'), findsOneWidget);
    });

    testWidgets('Home screen should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProductProvider(),
          child: const MyApp(),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Check if main elements are present
      expect(find.text('مدیریت محصولات'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.file_upload), findsOneWidget);
    });

    testWidgets('Settings screen should be accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ProductProvider(),
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('تنظیمات'));
      await tester.pumpAndSettle();

      // Check if settings screen is displayed
      expect(find.text('تنظیمات دیتابیس'), findsOneWidget);
    });
  });
}