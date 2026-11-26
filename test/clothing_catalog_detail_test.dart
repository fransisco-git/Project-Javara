import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawara_app/features/fashion/data/javanese_clothing_data.dart';
import 'package:jawara_app/features/fashion/screens/clothing_catalog_screen.dart';
import 'package:jawara_app/features/fashion/screens/clothing_detail_screen.dart';
import 'package:jawara_app/features/fashion/widgets/garment_visual.dart';
import 'package:jawara_app/services/saved_garments_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SavedGarmentsService.instance.initialize();
    SavedGarmentsService.instance.savedItemIdsNotifier.value = {};
  });

  group('Koleksi & Detail Busana Photo, Typographic Fallback & Contrast Tests', () {
    test('ClothingItem.photoAsset resolves to assets/koleksi/<id>.jpg', () {
      final blangkon = JavaneseClothingData.getItemById(
        'blangkon_surakarta_parang',
      )!;
      expect(
        blangkon.photoAsset,
        'assets/koleksi/blangkon_surakarta_parang.jpg',
      );
    });

    testWidgets(
      'Grid & List show typographic fallback without icons for missing photos, simplify grid card, and fix contrast',
      (tester) async {
        tester.view.physicalSize = const Size(360 * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        final errors = <FlutterErrorDetails>[];
        final prevOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          errors.add(details);
        };

        try {
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: child!,
              ),
              home: const ClothingCatalogScreen(),
            ),
          );
          await tester.pumpAndSettle();

          // Contrast on "Menampilkan N warisan busana adat" (non-italic, #5C4632)
          final countTextFinder = find.textContaining('warisan busana adat');
          expect(countTextFinder, findsOneWidget);
          final countText = tester.widget<Text>(countTextFinder);
          expect(countText.style?.color, const Color(0xFF5C4632));
          expect(countText.style?.fontStyle, isNot(FontStyle.italic));

          // Grid card simplification: no forward arrow icon, combined gender · socialContext
          expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
          expect(
            find.text('Pria · Keraton & Bangsawan'),
            findsAtLeastNWidgets(1),
          );

          // Blangkon Surakarta Trepes now has its HD photo in assets/koleksi/
          expect(find.text('Blangkon Surakarta Trepes'), findsOneWidget);
          final blangkonCard = find
              .ancestor(
                of: find.text('Blangkon Surakarta Trepes'),
                matching: find.byType(GestureDetector),
              )
              .first;
          expect(
            find.descendant(
              of: blangkonCard,
              matching: find.byType(GarmentTypographyFallback),
            ),
            findsNothing,
          );

          // Kuluk Kanigaran renamed cleanly and loads its HD photo
          expect(find.text('Kuluk Kanigaran'), findsOneWidget);

          // Scroll down to an item without a photo (Surjan Lurik Tenun Prasaja Klaten) -> flat GarmentTypographyFallback (no icons)
          await tester.drag(find.byType(GridView), const Offset(0, -800));
          await tester.pumpAndSettle();
          expect(find.byType(GarmentTypographyFallback), findsAtLeastNWidgets(1));
          final fallbackVisual = find.byType(GarmentTypographyFallback).first;
          expect(
            find.descendant(of: fallbackVisual, matching: find.byType(Icon)),
            findsNothing,
          );
          final fallbackBox = tester.widget<ColoredBox>(
            find.descendant(
              of: fallbackVisual,
              matching: find.byType(ColoredBox),
            ),
          );
          final lurik = JavaneseClothingData.getItemById(
            'surjan_lurik_klaten',
          )!;
          expect(fallbackBox.color, lurik.primaryColor);

          // Switch to List View and verify category badge contrast (#6E5019) & fallback
          await tester.tap(find.byIcon(Icons.view_agenda_outlined));
          await tester.pumpAndSettle();

          final penutupKepalaLabels = tester
              .widgetList<Text>(find.text('Penutup Kepala'))
              .where((t) => t.style?.color == const Color(0xFF6E5019))
              .toList();
          expect(penutupKepalaLabels, isNotEmpty);
          await tester.drag(find.byType(ListView).last, const Offset(0, -950));
          await tester.pumpAndSettle();
          expect(find.byType(GarmentTypographyFallback), findsAtLeastNWidgets(1));
        } finally {
          FlutterError.onError = prevOnError;
        }

        final overflowErrors = errors
            .where((e) => e.exceptionAsString().contains('overflowed'))
            .toList();
        expect(overflowErrors, isEmpty);
      },
    );

    testWidgets(
      'ClothingDetailScreen shows typographic fallback for missing photo, preserves batik asset, and enforces high contrast',
      (tester) async {
        tester.view.physicalSize = const Size(360 * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        final blangkon = JavaneseClothingData.getItemById(
          'blangkon_surakarta_parang',
        )!;
        final jogjaBlangkon = JavaneseClothingData.getItemById(
          'blangkon_yogyakarta_sidomukti',
        )!;
        final banyumasBlangkon = JavaneseClothingData.getItemById(
          'blangkon_banyumasan_wirasaba',
        )!;
        final kuluk = JavaneseClothingData.getItemById(
          'kuluk_kanigaran_solo',
        )!;
        final sanggul = JavaneseClothingData.getItemById(
          'sanggul_tekuk_ronce_melati',
        )!;
        final beskap = JavaneseClothingData.getItemById(
          'beskap_landhung_solo',
        )!;
        final sikepan = JavaneseClothingData.getItemById(
          'beskap_sikepan_beludru_emas',
        )!;
        final surjan = JavaneseClothingData.getItemById(
          'surjan_ontrokusumo_sutra',
        )!;
        final lurik = JavaneseClothingData.getItemById(
          'surjan_lurik_klaten',
        )!;
        expect(kuluk.name, 'Kuluk Kanigaran');

        final errors = <FlutterErrorDetails>[];
        final prevOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          errors.add(details);
        };

        try {
          // All 8 photographed items load their real HD photos from assets/koleksi/
          for (final photoItem in [
            blangkon,
            jogjaBlangkon,
            banyumasBlangkon,
            kuluk,
            sanggul,
            beskap,
            sikepan,
            surjan,
          ]) {
            await tester.pumpWidget(
              MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.3),
                  ),
                  child: child!,
                ),
                home: ClothingDetailScreen(
                  key: ValueKey(photoItem.id),
                  item: photoItem,
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(find.byType(GarmentTypographyFallback), findsNothing);
          }

          // Item without photo shows typographic fallback with no category icon
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: child!,
              ),
              home: ClothingDetailScreen(
                key: ValueKey(lurik.id),
                item: lurik,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(GarmentTypographyFallback), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(GarmentTypographyFallback),
              matching: find.byType(Icon),
            ),
            findsNothing,
          );

          // Contrast checks on cream background
          final titleWidget = tester.widget<Text>(
            find.text(lurik.name),
          );
          expect(titleWidget.style?.color, const Color(0xFF2C2219));

          final scriptTexts = tester
              .widgetList<Text>(find.text(lurik.javaneseScript))
              .where((t) => t.style?.color == const Color(0xFF5C4632))
              .toList();
          expect(scriptTexts, isNotEmpty);

          final periodWidget = tester.widget<Text>(
            find.text('Periode: ${lurik.period}'),
          );
          expect(periodWidget.style?.color, const Color(0xFF5C4632));
          expect(periodWidget.style?.fontStyle, isNot(FontStyle.italic));

          // Scroll down to Keselarasan Busana Pendamping section
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -1200),
          );
          await tester.pumpAndSettle();

          final sectionTitle = tester.widget<Text>(
            find.text('Keselarasan Busana Pendamping'),
          );
          expect(sectionTitle.style?.color, const Color(0xFF2C2219));

          final sectionSub = tester.widget<Text>(
            find.text('Padanan busana yang selaras menurut tatakrama tradisi'),
          );
          expect(sectionSub.style?.color, const Color(0xFF5C4632));

          // Batik jarik with assetImagePath still loads its batik photo (no fallback)
          final jarik = JavaneseClothingData.getItemById(
            'jarik_batik_parang_barong_solo',
          )!;
          expect(jarik.assetImagePath, isNotNull);
          await tester.pumpWidget(
            MaterialApp(
              home: ClothingDetailScreen(item: jarik),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(GarmentTypographyFallback), findsNothing);
        } finally {
          FlutterError.onError = prevOnError;
        }

        final overflowErrors = errors
            .where((e) => e.exceptionAsString().contains('overflowed'))
            .toList();
        expect(overflowErrors, isEmpty);
      },
    );
  });
}
