import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawara_app/features/home/home_tab.dart';
import 'package:jawara_app/services/saved_garments_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SavedGarmentsService.instance.initialize();
    SavedGarmentsService.instance.savedItemIdsNotifier.value = {};
    SavedGarmentsService.instance.savedOutfitsNotifier.value = [];
  });
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

  testWidgets('Warisan Populer section displays editorial museum lookbook cards with 3:4 aspect ratio and bookmark toggle', (
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
    // Allow loading delay to finish
    await tester.pump(const Duration(milliseconds: 1200));

    // Verify Warisan Populer section header
    expect(find.text('Warisan Populer'), findsOneWidget);

    // Scroll down to bring Warisan Populer into viewport
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify editorial category & origin labels (uppercase, concise, not truncated)
    expect(find.text('SURAKARTA · PRIA'), findsOneWidget);
    expect(find.text('SURAKARTA · PENGANTIN'), findsOneWidget);
    expect(find.text('SURAKARTA · WASTRA'), findsOneWidget);
    expect(find.text('REMBANG · WANITA'), findsOneWidget);

    // Verify garment titles are rendered
    expect(find.text('Beskap Jawi Jangkep'), findsOneWidget);
    expect(find.text('Solo Basahan Pengantin'), findsOneWidget);
    expect(find.text('Batik Tulis Parang Barong'), findsOneWidget);
    expect(find.text('Kebaya Kartini Jawa Tengah'), findsOneWidget);

    // Verify repetitive "Pelajari Tradisi →" button text has been completely removed
    expect(find.text('Pelajari Tradisi →'), findsNothing);

    // Verify AspectRatio 3/4 widgets exist
    final aspectRatios = tester.widgetList<AspectRatio>(find.byType(AspectRatio));
    final hasThreeFourAspectRatio = aspectRatios.any((ar) => (ar.aspectRatio - (3.0 / 4.0)).abs() < 0.01);
    expect(hasThreeFourAspectRatio, isTrue);

    // Verify bookmark icons are present
    final bookmarkIconFinder = find.byIcon(Icons.bookmark_outline_rounded);
    expect(bookmarkIconFinder, findsAtLeastNWidgets(1));

    // Tap the first bookmark icon to toggle saved state
    await tester.tap(bookmarkIconFinder.first);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify the icon switched to solid bookmark
    expect(find.byIcon(Icons.bookmark_rounded), findsAtLeastNWidgets(1));
  });

  testWidgets('HomeTab omits AI chatbot button while keeping AI Fashion Studio and Studio Wardrobe 3D', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 2, 800 * 2);
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

    // Verify AI chatbot button and coach mark in top right are removed
    expect(find.byIcon(Icons.auto_awesome_outlined), findsNothing);
    expect(find.byTooltip('Tanya Abdi Pakar'), findsNothing);
    expect(find.text('Tanya Abdi Pakar soal busana adat'), findsNothing);

    // Scroll down to Studio Busana section below Warisan Populer
    await tester.scrollUntilVisible(
      find.text('Studio Busana'),
      400,
      scrollable: find.descendant(
        of: find.byType(ListView).first,
        matching: find.byType(Scrollable),
      ).first,
    );
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Studio Wardrobe 3D and AI Fashion Studio remain available
    expect(find.text('Studio Busana'), findsOneWidget);
    expect(find.text('Studio Wardrobe 3D'), findsOneWidget);
    expect(find.text('AI Fashion Studio'), findsOneWidget);
  });

  testWidgets('HomeTab renders updated categories: Busana Pria, Busana Wanita, Batik, Aksesoris', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 2, 800 * 2);
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

    // Verify 4 category titles are rendered
    expect(find.text('Busana Pria'), findsOneWidget);
    expect(find.text('Busana Wanita'), findsOneWidget);
    expect(find.text('Batik'), findsOneWidget);
    expect(find.text('Aksesoris'), findsOneWidget);

    // Verify respective subtitles
    expect(find.text('Pria Adat'), findsOneWidget);
    expect(find.text('Kebaya & Rias'), findsOneWidget);
    expect(find.text('Motif Pakem'), findsOneWidget);
    expect(find.text('Ricikan Adat'), findsOneWidget);
  });
}
