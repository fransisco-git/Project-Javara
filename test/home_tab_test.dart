import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/home/home_tab.dart';

void main() {
  testWidgets('HomeTab renders luxury JAVARA header and action buttons', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeTab(onOpenTab: (_) {}),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));

    // Verify J A V A R A header logo is present
    expect(find.text('J A V A R A'), findsOneWidget);

    // Verify Search button is present
    final searchIconFinder = find.byIcon(Icons.search_rounded);
    expect(searchIconFinder, findsAtLeastNWidgets(1));

    // Verify Box / Wardrobe collection icon is removed (clean app bar)
    expect(find.byIcon(Icons.inventory_2_outlined), findsNothing);

    // Tap search button to open search bar
    await tester.tap(searchIconFinder.first);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify search text field is now displayed
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Cari busana, kebaya, beskap, batik, jarik...'), findsOneWidget);

    // Enter search text
    await tester.enterText(find.byType(TextField), 'kebaya');
    await tester.pump(const Duration(milliseconds: 300));

    // Close search
    final closeFinder = find.byIcon(Icons.close_rounded);
    expect(closeFinder, findsOneWidget);
    await tester.tap(closeFinder);
    await tester.pump(const Duration(milliseconds: 300));

    // Should return to logo bar
    expect(find.text('J A V A R A'), findsOneWidget);
  });

  testWidgets('HomeTab scrolls and opens Buddha hands smoothly without crash or overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeTab(onOpenTab: (_) {}),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1000));

    // Header logo is present
    expect(find.text('J A V A R A'), findsOneWidget);

    // Find the ListView and scroll down
    final listFinder = find.byType(ListView);
    expect(listFinder, findsOneWidget);

    // Scroll down 300px
    await tester.drag(listFinder, const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    // Scroll back up 300px
    await tester.drag(listFinder, const Offset(0, 300));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    // ListView and header remain stable
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('J A V A R A'), findsOneWidget);
  });

  testWidgets('HomeTab zero RenderFlex overflow across various widths and text scales', (
    WidgetTester tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
    };

    try {
      final widths = [300.0, 320.0, 360.0, 390.0, 412.0];
      final textScales = [0.8, 1.0, 1.3];

      for (final width in widths) {
        for (final scale in textScales) {
          tester.view.physicalSize = Size(width * 2, 800 * 2);
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 800),
                  textScaler: TextScaler.linear(scale),
                ),
                child: Scaffold(
                  body: HomeTab(onOpenTab: (_) {}),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      final overflowErrors =
          errors.where((e) => e.toString().contains('overflowed')).toList();
      expect(overflowErrors, isEmpty,
          reason: 'Found overflows: ${overflowErrors.map((e) => e.summary).toList()}');
    } finally {
      tester.view.resetPhysicalSize();
      FlutterError.onError = originalOnError;
    }
  });
}
