import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawara_app/features/fashion/models/javanese_clothing_models.dart';
import 'package:jawara_app/features/fashion/screens/wardrobe_tab.dart';
import 'package:jawara_app/features/home/home_screen.dart';
import 'package:jawara_app/features/home/javara_bottom_nav.dart';
import 'package:jawara_app/services/saved_garments_service.dart';
import 'package:jawara_app/widgets/navigation/nav_icon_hanger.dart';
import 'package:jawara_app/widgets/navigation/nav_icon_home.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SavedGarmentsService.instance.initialize();
    SavedGarmentsService.instance.savedItemIdsNotifier.value = {};
    SavedGarmentsService.instance.savedOutfitsNotifier.value = [];
  });

  group('4-Tab Floating Capsule Navigation Bar & HomeScreen Tests', () {
    testWidgets('HomeScreen renders exactly 4 tabs: Beranda, Koleksi, Tersimpan, Profil without Wardrobe pill', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      // Verifikasi navbar bersih hanya ikon (tanpa teks label di dalam JavaraBottomNav)
      final navFinder = find.byType(JavaraBottomNav);
      expect(
        find.descendant(of: navFinder, matching: find.byType(Text)),
        findsNothing,
      );

      // Verifikasi 4 slot tab tetap tersedia melalui semantics label
      final berandaTab = find.descendant(
        of: navFinder,
        matching: find.bySemanticsLabel('Beranda'),
      );
      final koleksiTab = find.descendant(
        of: navFinder,
        matching: find.bySemanticsLabel('Koleksi'),
      );
      final tersimpanTab = find.descendant(
        of: navFinder,
        matching: find.bySemanticsLabel('Tersimpan'),
      );
      final profilTab = find.descendant(
        of: navFinder,
        matching: find.bySemanticsLabel('Profil'),
      );
      expect(berandaTab, findsOneWidget);
      expect(koleksiTab, findsOneWidget);
      expect(tersimpanTab, findsOneWidget);
      expect(profilTab, findsOneWidget);

      // Verifikasi custom icons untuk Beranda (NavIconHome) & Koleksi (NavIconHanger) 24x24
      final homeIconFinder = find.byType(NavIconHome);
      final hangerIconFinder = find.byType(NavIconHanger);
      expect(homeIconFinder, findsOneWidget);
      expect(hangerIconFinder, findsOneWidget);
      expect(tester.getSize(homeIconFinder), const Size(24, 24));
      expect(tester.getSize(hangerIconFinder), const Size(24, 24));
      final homeIcon = tester.widget<NavIconHome>(homeIconFinder);
      final hangerIcon = tester.widget<NavIconHanger>(hangerIconFinder);
      expect(homeIcon.isActive, isTrue);
      expect(hangerIcon.isActive, isFalse);
      expect(homeIcon.activeColor, JavaraBottomNav.activeColor);
      expect(hangerIcon.activeColor, JavaraBottomNav.activeColor);
      expect(homeIcon.activeColor, isNot(Colors.white));
      expect(hangerIcon.activeColor, isNot(Colors.white));

      // Verifikasi titik indikator aktif bawah sudah dihapus & semua ikon sejajar vertikal
      expect(
        find.descendant(
          of: navFinder,
          matching: find.byType(AnimatedAlign),
        ),
        findsNothing,
      );
      final centerY = tester.getCenter(homeIconFinder).dy;
      expect(tester.getCenter(hangerIconFinder).dy, centerY);
      expect(tester.getCenter(find.byIcon(Icons.bookmark_outline_rounded)).dy, centerY);
      expect(tester.getCenter(find.byIcon(Icons.person_outline_rounded)).dy, centerY);

      // Verifikasi tombol Wardrobe pill di navbar sudah dihapus
      expect(find.text('Wardrobe'), findsNothing);
      expect(find.byIcon(Icons.checkroom_outlined), findsNothing);

      // Switch ke Tab Koleksi (Tab 1) -> NavIconHanger menjadi aktif, NavIconHome nonaktif
      await tester.tap(koleksiTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      expect(tester.widget<NavIconHome>(homeIconFinder).isActive, isFalse);
      expect(tester.widget<NavIconHanger>(hangerIconFinder).isActive, isTrue);

      // Switch ke Tab Tersimpan (Tab 2)
      await tester.tap(tersimpanTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Koleksi Tersimpan'), findsOneWidget);
      expect(find.text('Item Busana'), findsOneWidget);
      expect(find.text('Setelan Pusaka'), findsNothing);

      // Switch ke Tab Profil (Tab 3)
      await tester.tap(profilTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Profil Pengguna'), findsOneWidget);

      // Pastikan timer di HomeTab selesai
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('Unified Wardrobe Tab Tests', () {
    testWidgets('Top Styling Canvas renders with neutral background and layer slots', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WardrobeTab()),
        ),
      );
      await tester.pump();

      // Verifikasi elemen Kanvas
      expect(find.text('Wardrobe Pribadi'), findsOneWidget);
      expect(find.text('Simpan Setelan'), findsOneWidget);
      expect(find.text('Kanvas Gaya'), findsOneWidget);
      expect(find.text('Item Tersimpan'), findsOneWidget);
      expect(find.text('Setelan Saya'), findsOneWidget);

      // Reset kanvas
      await tester.tap(find.byTooltip('Atur Ulang Kanvas'));
      await tester.pump();
      expect(find.text('Kanvas kosong'), findsOneWidget);
    });

    testWidgets('Item Tersimpan shows clean empty state with CTA to Koleksi when empty', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 2000);
      tester.view.devicePixelRatio = 2.0;

      bool catalogOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WardrobeTab(
              onOpenCatalog: () {
                catalogOpened = true;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Pindah ke segment "Item Tersimpan"
      await tester.tap(find.text('Item Tersimpan'));
      await tester.pump();

      expect(find.text('Belum Ada Busana Tersimpan'), findsOneWidget);
      expect(find.text('Jelajahi Koleksi Busana'), findsOneWidget);

      // Ketuk tombol CTA Jelajahi Koleksi
      await tester.ensureVisible(find.text('Jelajahi Koleksi Busana'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jelajahi Koleksi Busana'));
      await tester.pump();
      expect(catalogOpened, isTrue);
    });

    testWidgets('Saving an item syncs immediately to Item Tersimpan and equips on Canvas', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WardrobeTab()),
        ),
      );
      await tester.pump();

      // Simpan satu item busana
      const sampleId = 'kebaya_kutubaru_beludru_solo';
      await SavedGarmentsService.instance.toggleSave(sampleId);
      await tester.pump();

      // Buka segment Item Tersimpan
      await tester.tap(find.text('Item Tersimpan'));
      await tester.pump();

      // Item harus muncul di daftar Item Tersimpan
      expect(find.textContaining('Kebaya Kutubaru'), findsWidgets);
      expect(find.text('Pakai'), findsOneWidget);

      // Ketuk tombol Pakai
      await tester.ensureVisible(find.text('Pakai'));
      await tester.tap(find.text('Pakai'));
      await tester.pump();

      // Tombol berubah jadi Terpasang
      expect(find.text('Terpasang'), findsOneWidget);
    });

    testWidgets('Setelan Saya shows empty state and can save custom outfit from canvas', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 1600);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WardrobeTab()),
        ),
      );
      await tester.pump();

      // Cek tab Setelan Saya saat kosong
      await tester.tap(find.text('Setelan Saya'));
      await tester.pump();
      expect(find.text('Belum Ada Setelan Tersimpan'), findsOneWidget);

      // Simpan setelan baru langsung via service
      final outfit = SavedOutfit(
        id: 'test_outfit_1',
        customName: 'Setelan Kasunanan Uji Coba',
        savedDate: DateTime.now(),
        gender: GenderTarget.pria,
        headwearId: 'blangkon_surakarta_parang',
        upperBodyId: 'beskap_landhung_solo',
        lowerBodyId: 'jarik_batik_parang_barong_solo',
        accessoryIds: [],
        isHistoricallyVerified: true,
        harmonyRating: 5,
      );
      await SavedGarmentsService.instance.saveOutfit(outfit);
      await tester.pump();

      expect(find.text('Setelan Kasunanan Uji Coba'), findsOneWidget);
      expect(find.text('Terapkan ke Kanvas'), findsOneWidget);

      // Terapkan ke kanvas
      await tester.ensureVisible(find.text('Terapkan ke Kanvas'));
      await tester.tap(find.text('Terapkan ke Kanvas'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('Zero RenderFlex overflow across widths 300, 320, 360, 412 and text scale 1.3', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      try {
        final widths = [300.0, 320.0, 360.0, 412.0];

        for (final width in widths) {
          tester.view.physicalSize = Size(width * 2, 800 * 2);
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 800),
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: const Scaffold(
                  body: WardrobeTab(),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(errors, isEmpty, reason: 'RenderFlex overflow in WardrobeTab at width $width');
        }
      } finally {
        FlutterError.onError = originalOnError;
      }
    });
  });
}
