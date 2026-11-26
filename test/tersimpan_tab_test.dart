import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawara_app/data/culture_items.dart';
import 'package:jawara_app/features/fashion/data/javanese_clothing_data.dart';
import 'package:jawara_app/features/fashion/screens/tersimpan_tab.dart';
import 'package:jawara_app/features/fashion/widgets/garment_visual.dart';
import 'package:jawara_app/features/heritage/culture_detail_screen.dart';
import 'package:jawara_app/services/saved_garments_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SavedGarmentsService.instance.initialize();
    SavedGarmentsService.instance.savedItemIdsNotifier.value = {};
    SavedGarmentsService.instance.savedOutfitsNotifier.value = [];
  });

  group('Saved Garments Image Parity (Koleksi & Beranda -> Tersimpan)', () {
    test('Every Koleksi ClothingItem.imageAsset matches GarmentPhotoVisual effectiveAssetPath', () {
      for (final item in JavaneseClothingData.clothingItems) {
        final expectedPath = GarmentPhotoVisual(item: item).effectiveAssetPath;
        expect(item.imageAsset, equals(expectedPath));
        expect(item.imageAsset, isNot(contains('assets/garments/')));
        expect(item.imageAsset, isNot(contains('candi_3d_hero.jpg')));
        expect(item.imageAsset, isNot(contains('wayang.png')));
      }
    });

    test('Surjan Lurik on Beranda uses surjan asset rather than kebaya', () {
      final surjan = allCultureItems.firstWhere(
        (item) => item.id == 'surjan_lurik_tradisi',
      );
      expect(surjan.imageAssetPath, 'assets/images/model_surjan_pranakan_solo.jpg');
    });

    testWidgets(
      'Koleksi garments saved to Tersimpan render exact Koleksi photos via GarmentPhotoVisual',
      (tester) async {
        tester.view.physicalSize = const Size(412 * 2, 915 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        const sampleIds = [
          'blangkon_surakarta_parang',
          'beskap_landhung_solo',
          'jarik_batik_parang_barong_solo',
          'keris_ladrang_solo_kayu_timoho',
          'selop_beludru_sulam_emas',
        ];
        for (final id in sampleIds) {
          await SavedGarmentsService.instance.toggleSave(id);
        }

        await tester.pumpWidget(
          const MaterialApp(home: TersimpanTab()),
        );
        await tester.pumpAndSettle();

        expect(find.text('${sampleIds.length}'), findsOneWidget);
        expect(find.byType(GarmentTypographyFallback), findsNothing);

        final visuals = tester
            .widgetList<GarmentPhotoVisual>(find.byType(GarmentPhotoVisual))
            .toList();
        expect(visuals, isNotEmpty);

        for (final visual in visuals) {
          final expected = visual.effectiveAssetPath;
          final matchingImage = tester
              .widgetList<Image>(
                find.descendant(
                  of: find.byWidget(visual),
                  matching: find.byType(Image),
                ),
              )
              .first;
          final provider = matchingImage.image;
          final assetName = provider is ResizeImage
              ? (provider.imageProvider as AssetImage).assetName
              : (provider as AssetImage).assetName;
          expect(assetName, equals(expected));
          expect(assetName, isNot(contains('assets/garments/')));
          expect(assetName, isNot(contains('candi_3d_hero.jpg')));
        }
      },
    );

    testWidgets(
      'Beranda items saved to Tersimpan appear with exact Beranda images and support remove + undo',
      (tester) async {
        tester.view.physicalSize = const Size(412 * 2, 915 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        for (final culture in popularItems) {
          await SavedGarmentsService.instance.toggleSave(culture.id);
        }

        await tester.pumpWidget(
          const MaterialApp(home: TersimpanTab()),
        );
        await tester.pumpAndSettle();

        // Badge count matches exact number of visible Beranda items
        expect(find.text('${popularItems.length}'), findsOneWidget);
        expect(find.text('Belum Ada Busana Tersimpan'), findsNothing);

        for (final culture in popularItems) {
          expect(find.text(culture.title), findsOneWidget);
          final imageFinder = find.byKey(ValueKey(culture.imageAssetPath));
          expect(imageFinder, findsOneWidget);
          final img = tester.widget<Image>(imageFinder);
          final provider = img.image;
          final assetName = provider is ResizeImage
              ? (provider.imageProvider as AssetImage).assetName
              : (provider as AssetImage).assetName;
          expect(assetName, equals('assets/images/${culture.image}'));
        }

        // Remove the first visible item and undo via snackbar
        final removeButtons = find.byTooltip('Hapus dari Tersimpan');
        expect(removeButtons, findsNWidgets(popularItems.length));
        await tester.tap(removeButtons.first);
        await tester.pumpAndSettle();
        expect(find.text('${popularItems.length - 1}'), findsOneWidget);

        await tester.tap(find.text('Urungkan'));
        await tester.pumpAndSettle();
        expect(find.text('${popularItems.length}'), findsOneWidget);
      },
    );

    testWidgets(
      'Bookmarking from CultureDetailScreen syncs with SavedGarmentsService',
      (tester) async {
        tester.view.physicalSize = const Size(412 * 2, 915 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        final target = popularItems.first;
        await tester.pumpWidget(
          MaterialApp(home: CultureDetailScreen(item: target)),
        );
        await tester.pumpAndSettle();

        expect(SavedGarmentsService.instance.isSaved(target.id), isFalse);
        await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
        await tester.pumpAndSettle();

        expect(SavedGarmentsService.instance.isSaved(target.id), isTrue);
        expect(
          SavedGarmentsService.instance
              .getSavedEntries()
              .map((e) => e.imageAssetPath),
          contains(target.imageAssetPath),
        );
      },
    );

    testWidgets(
      'TersimpanTab renders mixed Koleksi + Beranda items with zero overflow at 360dp and 1.3 text scale',
      (tester) async {
        final errors = <FlutterErrorDetails>[];
        final prevOnError = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        try {
          await SavedGarmentsService.instance.toggleSave('beskap_landhung_solo');
          await SavedGarmentsService.instance.toggleSave('selop_beludru_sulam_emas');
          await SavedGarmentsService.instance.toggleSave('beskap_jawi_jangkep_solo');
          await SavedGarmentsService.instance.toggleSave('busana_pengantin_solo_basahan');

          for (final size in const [Size(360, 640), Size(412, 915)]) {
            tester.view.physicalSize = Size(size.width * 2, size.height * 2);
            tester.view.devicePixelRatio = 2.0;

            await tester.pumpWidget(
              MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.3),
                  ),
                  child: child!,
                ),
                home: const TersimpanTab(),
              ),
            );
            await tester.pumpAndSettle();
          }
        } finally {
          tester.view.reset();
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
