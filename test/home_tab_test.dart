import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawara_app/data/culture_items.dart';
import 'package:jawara_app/features/heritage/culture_detail_screen.dart';
import 'package:jawara_app/features/home/home_tab.dart';
import 'package:jawara_app/features/home/widgets/category_theme_icons.dart';
import 'package:jawara_app/features/home/widgets/hero_slide.dart';
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
        home: Scaffold(body: HomeTab(onOpenTab: (_) {})),
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
    expect(
      find.text('Cari busana, kebaya, beskap, batik, jarik...'),
      findsOneWidget,
    );

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

  testWidgets(
    'HomeTab scrolls and opens Buddha hands smoothly without crash or overflow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HomeTab(onOpenTab: (_) {})),
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
    },
  );

  testWidgets(
    'HomeTab zero RenderFlex overflow across various widths and text scales',
    (WidgetTester tester) async {
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
                  child: Scaffold(body: HomeTab(onOpenTab: (_) {})),
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 100));
          }
        }

        final overflowErrors = errors
            .where((e) => e.toString().contains('overflowed'))
            .toList();
        expect(
          overflowErrors,
          isEmpty,
          reason:
              'Found overflows: ${overflowErrors.map((e) => e.summary).toList()}',
        );
      } finally {
        tester.view.resetPhysicalSize();
        FlutterError.onError = originalOnError;
      }
    },
  );

  testWidgets(
    'Warisan Populer section displays editorial museum lookbook cards with 3:4 aspect ratio and bookmark toggle',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HomeTab(onOpenTab: (_) {})),
        ),
      );
      // Allow loading delay to finish
      await tester.pump(const Duration(milliseconds: 1200));

      // Scroll down to bring Warisan Populer and its cards into viewport
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Warisan Populer section header
      expect(find.text('Warisan Populer'), findsOneWidget);

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
      final aspectRatios = tester.widgetList<AspectRatio>(
        find.byType(AspectRatio),
      );
      final hasThreeFourAspectRatio = aspectRatios.any(
        (ar) => (ar.aspectRatio - (3.0 / 4.0)).abs() < 0.01,
      );
      expect(hasThreeFourAspectRatio, isTrue);

      // Verify bookmark icons are present
      final bookmarkIconFinder = find.byIcon(Icons.bookmark_outline_rounded);
      expect(bookmarkIconFinder, findsAtLeastNWidgets(1));

      // Tap the first bookmark icon to toggle saved state
      await tester.tap(bookmarkIconFinder.first);
      await tester.pump(const Duration(milliseconds: 300));

      // Verify the icon switched to solid bookmark
      expect(find.byIcon(Icons.bookmark_rounded), findsAtLeastNWidgets(1));
    },
  );

  testWidgets(
    'HomeTab omits AI chatbot button and removed wardrobe section while keeping featured outfit',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HomeTab(onOpenTab: (_) {})),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1200));

      // Verify AI chatbot button and coach mark in top right are removed
      expect(find.byIcon(Icons.auto_awesome_outlined), findsNothing);
      expect(find.byTooltip('Tanya Abdi Pakar'), findsNothing);
      expect(find.text('Tanya Abdi Pakar soal busana adat'), findsNothing);

      // Scroll down to Panduan Acara below Warisan Populer
      await tester.scrollUntilVisible(
        find.text('PANDUAN ACARA'),
        400,
        scrollable: find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pump(const Duration(milliseconds: 400));

      // Verify Studio Busana / Wardrobe section has been removed from HomeTab
      expect(find.text('Studio Busana'), findsNothing);
      expect(find.text('Studio Wardrobe 3D'), findsNothing);
      expect(find.text('AI Fashion Studio'), findsNothing);

      // Verify Panduan Acara card replaced Busana Pilihan Hari Ini
      expect(find.text('BUSANA PILIHAN HARI INI'), findsNothing);
      expect(find.text('PANDUAN ACARA'), findsOneWidget);
      expect(find.text('Pilih Busana Sesuai Acara'), findsOneWidget);
      expect(find.text('Pernikahan'), findsOneWidget);
      expect(find.text('Kondangan'), findsOneWidget);
      expect(find.text('Wisuda'), findsOneWidget);
      expect(find.text('Upacara Adat'), findsOneWidget);
    },
  );

  testWidgets(
    'Panduan Acara opens bottom sheet without overflow at 360dp and 1.3 text scale',
    (WidgetTester tester) async {
      final errors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      try {
        tester.view.physicalSize = const Size(360 * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 800),
                textScaler: TextScaler.linear(1.3),
              ),
              child: Scaffold(body: HomeTab(onOpenTab: (_) {})),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 1200));

        await tester.scrollUntilVisible(
          find.text('Pernikahan'),
          350,
          scrollable: find
              .descendant(
                of: find.byType(ListView).first,
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.text('Pernikahan'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Pakem & Etika'), findsOneWidget);
        expect(find.textContaining('Solo Basahan'), findsAtLeastNWidgets(1));
        expect(find.text('Untuk mempelai'), findsNWidgets(2));
        expect(find.text('Untuk orang tua pengantin'), findsOneWidget);
        expect(
          find.text('Kain Jarik Batik Sidomukti Pengantin'),
          findsOneWidget,
        );
        expect(find.text('Kain Jarik Batik Truntum'), findsOneWidget);

        final overflowErrors = errors
            .where((e) => e.toString().contains('overflowed'))
            .toList();
        expect(
          overflowErrors,
          isEmpty,
          reason:
              'Found overflows: ${overflowErrors.map((e) => e.summary).toList()}',
        );
      } finally {
        tester.view.resetPhysicalSize();
        FlutterError.onError = originalOnError;
      }
    },
  );

  testWidgets(
    'CultureDetailScreen tabs Sejarah, Sorotan, Lokasi render without clipping at 360dp and 1.3 text scale',
    (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      final tabBarErrors = <FlutterErrorDetails>[];
      FlutterError.onError = (details) {
        if (details.toString().contains('TabBar') ||
            details.toString().contains('culture_detail_screen.dart:2')) {
          tabBarErrors.add(details);
        }
      };

      try {
        tester.view.physicalSize = const Size(360 * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 800),
                textScaler: TextScaler.linear(1.3),
              ),
              child: CultureDetailScreen(item: popularItems.first),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));

        final tabBarRect = tester.getRect(find.byType(TabBar));
        for (final label in ['Sejarah', 'Sorotan', 'Lokasi']) {
          final labelFinder = find.text(label);
          expect(labelFinder, findsOneWidget);
          final rect = tester.getRect(labelFinder);
          expect(rect.left, greaterThanOrEqualTo(tabBarRect.left));
          expect(rect.right, lessThanOrEqualTo(tabBarRect.right));
          expect(rect.top, greaterThanOrEqualTo(tabBarRect.top));
          expect(rect.bottom, lessThanOrEqualTo(tabBarRect.bottom));
        }

        await tester.tap(find.text('Sorotan'));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.text('Lokasi'));
        await tester.pump(const Duration(milliseconds: 300));

        expect(tabBarErrors, isEmpty);
      } finally {
        tester.view.resetPhysicalSize();
        FlutterError.onError = originalOnError;
      }
    },
  );

  testWidgets('HomeTab renders 3 merged categories: Busana, Aksesoris, Batik', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 2, 800 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HomeTab(onOpenTab: (_) {})),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));

    // Verify Busana Pria & Busana Wanita are merged into Busana
    expect(find.text('Busana Pria'), findsNothing);
    expect(find.text('Busana Wanita'), findsNothing);

    // Verify 3 category titles are rendered
    final busanaFinder = find.text('Busana');
    final aksesorisFinder = find.text('Aksesoris');
    final batikFinder = find.text('Batik');
    expect(busanaFinder, findsOneWidget);
    expect(aksesorisFinder, findsOneWidget);
    expect(batikFinder, findsOneWidget);

    // Verify left-to-right order: Busana, Aksesoris, Batik
    expect(
      tester.getCenter(busanaFinder).dx,
      lessThan(tester.getCenter(aksesorisFinder).dx),
    );
    expect(
      tester.getCenter(aksesorisFinder).dx,
      lessThan(tester.getCenter(batikFinder).dx),
    );

    // Verify respective subtitles
    expect(find.text('Pria & Wanita'), findsOneWidget);
    expect(find.text('Ricikan Adat'), findsOneWidget);
    expect(find.text('Motif Pakem'), findsOneWidget);

    // Verify bespoke themed Javanese vector icons are rendered instead of generic Material icons
    expect(find.byKey(const ValueKey('category_icon_busana')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('category_icon_aksesoris')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('category_icon_batik')), findsOneWidget);
    expect(find.byType(JavaraCategoryThemeIcon), findsNWidgets(3));
    expect(find.byIcon(Icons.military_tech_rounded), findsNothing);
    expect(find.byIcon(Icons.texture_rounded), findsNothing);
  });

  testWidgets(
    'HomeTab hero carousel uses unified full-width HeroSlide across all 3 slides',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HomeTab(onOpenTab: (_) {})),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1200));

      // Slide 1: full-width HeroSlide, height clamped 240-300 (32% of 844 = 270.08),
      // exact eyebrow, title, Alignment(0,-0.6), scale 1.0, and 40 dp LIHAT KOLEKSI button
      final heroSlideFinder = find.byType(HeroSlide);
      expect(heroSlideFinder, findsOneWidget);
      final heroSlide = tester.widget<HeroSlide>(heroSlideFinder);
      expect(heroSlide.data.imageAlignment, const Alignment(0, -0.6));
      expect(heroSlide.data.imageScale, 1.0);
      expect(
        find.descendant(of: heroSlideFinder, matching: find.byType(ClipRect)),
        findsOneWidget,
      );
      final heroSize = tester.getSize(heroSlideFinder);
      expect(heroSize.width, 390.0);
      expect(heroSize.height, inInclusiveRange(240.0, 300.0));
      expect(find.text('ARSIP 01 · BUSANA PUTRI'), findsOneWidget);
      expect(find.text('Kebaya Beludru Solo Putri'), findsOneWidget);
      expect(find.text('LIHAT KOLEKSI'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsNothing);

      // Categories row sits pushed down near the bottom of the first viewport above navbar,
      // leaving open vertical space below the hero carousel for the temple background
      final busanaBottom = tester.getBottomLeft(find.text('Busana')).dy;
      expect(busanaBottom, greaterThan(550.0));
      expect(busanaBottom, lessThan(760.0));

      // Swipe horizontally to Slide 2
      final pageViewFinder = find.byType(PageView);
      await tester.drag(pageViewFinder, const Offset(-390, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('ARSIP 02 · BUSANA PRIA'), findsOneWidget);
      expect(find.text('Beskap Surakarta Klasik'), findsOneWidget);
      expect(find.text('LIHAT KOLEKSI'), findsOneWidget);

      // Swipe horizontally to Slide 3
      await tester.drag(pageViewFinder, const Offset(-390, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('ARSIP 03 · BUSANA PENGANTIN'), findsOneWidget);
      expect(find.text('Solo Basahan Kampuhan'), findsOneWidget);
      expect(find.text('LIHAT KOLEKSI'), findsOneWidget);
    },
  );
}
