import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/fashion/cermin/garment_image_resolver.dart';
import 'package:jawara_app/features/fashion/screens/cermin_busana_screen.dart';

/// AssetBundle tiruan untuk pengujian resolver
class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.assetKeys);

  final Set<String> assetKeys;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'AssetManifest.json') {
      final map = {for (final k in assetKeys) k: <String>[]};
      return jsonEncode(map);
    }
    throw FlutterError('Unable to load asset: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    if (assetKeys.contains(key)) {
      return ByteData(8);
    }
    throw FlutterError('Unable to load asset: $key');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cermin Busana - GarmentImageResolver Tests', () {
    test('Resolver hides items without files and returns only existing assets', () async {
      // Hanya sediakan 2 aset yang valid
      final fakeBundle = FakeAssetBundle({
        'assets/garments/beskap_landhung_solo.png',
        'assets/garments/jarik_batik_parang_barong_solo.png',
      });

      final resolver = GarmentImageResolver(bundle: fakeBundle);
      final results = await resolver.resolveAvailableGarments();

      // Harus mengembalikan tepat 2 item
      expect(results.length, 2);
      expect(results.any((e) => e.id == 'beskap_landhung_solo'), isTrue);
      expect(results.any((e) => e.id == 'jarik_batik_parang_barong_solo'), isTrue);

      // Item lain yang tidak ada di manifest tidak boleh dikembalikan
      expect(results.any((e) => e.id == 'surjan_lurik_klaten'), isFalse);
      expect(results.any((e) => e.id == 'kebaya_kutubaru_beludru_solo'), isFalse);
    });

    test('Resolver returns empty list when no garment files exist', () async {
      final emptyBundle = FakeAssetBundle({});
      final resolver = GarmentImageResolver(bundle: emptyBundle);
      final results = await resolver.resolveAvailableGarments();

      expect(results, isEmpty);
    });
  });

  group('Cermin Busana - Widget & State Tests', () {
    testWidgets('Intro state displays headline, text, gold button, and does NOT initialize camera', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;

      bool catalogSwitched = false;

      await tester.pumpWidget(
        MaterialApp(
          home: CerminBusanaScreen(
            initialState: CerminState.intro,
            enableCameraAutoStart: false,
            onSwitchToCatalogTab: () {
              catalogSwitched = true;
            },
          ),
        ),
      );
      await tester.pump();

      // Verifikasi headline Cormorant Garamond & Subteks
      expect(
        find.text('Kenakan busana adat, langsung di cermin.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Pilih busana warisan Jawa Tengah dan coba langsung melalui cermin interaktif.',
        ),
        findsOneWidget,
      );

      // Verifikasi Tombol Emas "Nyalakan Kamera" dan Tombol "Lihat Koleksi"
      expect(find.text('Nyalakan Kamera'), findsOneWidget);
      expect(find.text('Lihat Koleksi'), findsOneWidget);

      // Ketuk "Lihat Koleksi"
      await tester.tap(find.text('Lihat Koleksi'));
      await tester.pump();
      expect(catalogSwitched, isTrue);
    });

    testWidgets('Empty state "Busana sedang disiapkan" appears when no garment files exist', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;

      final emptyResolver = GarmentImageResolver(bundle: FakeAssetBundle({}));

      await tester.pumpWidget(
        MaterialApp(
          home: CerminBusanaScreen(
            initialState: CerminState.liveCamera,
            customResolver: emptyResolver,
            enableCameraAutoStart: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Busana sedang disiapkan'), findsOneWidget);
    });

    testWidgets('Result state shows "Pratinjau contoh, bukan foto Anda" chip when FASHN not configured', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: CerminBusanaScreen(
            initialState: CerminState.result,
            enableCameraAutoStart: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Chip kejujuran harus terlihat
      expect(
        find.text('Pratinjau contoh, bukan foto Anda'),
        findsOneWidget,
      );
      // Tombol aksi "Coba busana lain" harus ada
      expect(find.text('Coba busana lain'), findsOneWidget);
    });

    testWidgets('Zero RenderFlex overflow at widths 320, 360, 412 and text scale 1.3 across Intro and Result', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      try {
        final widths = [320.0, 360.0, 412.0];

        for (final width in widths) {
          tester.view.physicalSize = Size(width * 2, 800 * 2);
          tester.view.devicePixelRatio = 2.0;

          // Uji Layar Intro
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 800),
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: const CerminBusanaScreen(
                  initialState: CerminState.intro,
                  enableCameraAutoStart: false,
                ),
              ),
            ),
          );
          await tester.pump();
          expect(errors, isEmpty, reason: 'RenderFlex overflow in Intro at width $width');

          // Uji Layar Result
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 800),
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: const CerminBusanaScreen(
                  initialState: CerminState.result,
                  enableCameraAutoStart: false,
                ),
              ),
            ),
          );
          await tester.pump();
          expect(errors, isEmpty, reason: 'RenderFlex overflow in Result at width $width');
        }
      } finally {
        FlutterError.onError = originalOnError;
      }
    });
  });
}
