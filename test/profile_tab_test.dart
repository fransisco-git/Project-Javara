import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/home/profile_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'javara_pref_aksara': true,
      'javara_pref_gamelan': true,
      'javara_size_top': 'L (LD 98 cm)',
      'javara_size_head': 'No. 7 (57 cm)',
      'javara_size_jarik': 'Standar (220 cm)',
      'javara_profile_name': 'Raden Mas Aryo',
      'javara_profile_email': 'aryo.kusumo@javara.id',
    });
  });

  testWidgets('ProfileTab displays streamlined fashion-focused UI without old gamification elements', (tester) async {
    tester.view.physicalSize = const Size(500, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Header and Fashion Identity
    expect(find.text('Profil Pengguna'), findsOneWidget);
    expect(find.byIcon(Icons.edit_note_rounded), findsNothing);
    expect(find.byTooltip('Ubah Profil'), findsNothing);
    expect(find.text('Pelestari Wastra Jawa Tengah'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Alamat Kirim'), findsOneWidget);

    // 2. Verify Aktivitas Busana Saya section is removed
    expect(find.text('Aktivitas Busana Saya'), findsNothing);
    expect(find.text('Pesanan & Sewa Saya'), findsNothing);
    expect(find.text('Wishlist & Koleksi Tersimpan'), findsNothing);
    expect(find.text('Riwayat Try-On & Padu Padan'), findsNothing);

    // 3. Verify My Size Section
    expect(find.text('Ukuran Busana Saya (My Size)'), findsOneWidget);
    expect(find.text('Baju / Kebaya'), findsOneWidget);
    expect(find.text('Blangkon'), findsOneWidget);
    expect(find.text('Kain Jarik'), findsOneWidget);
    expect(find.text('Ubah Ukuran Busana Saya'), findsOneWidget);

    // 4. Verify Preferences
    expect(find.text('Preferensi & Bantuan'), findsOneWidget);
    expect(find.textContaining('Aksara Jawa'), findsOneWidget);
    expect(find.textContaining('Musik Gamelan'), findsOneWidget);
    expect(find.text('Keluar dari Akun'), findsOneWidget);

    // 5. Verify Old Gamification Elements are REMOVED
    expect(find.text('Skor Budaya'), findsNothing);
    expect(find.text('Wilayah Dijelajahi'), findsNothing);
    expect(find.text('Tantangan Tuntas'), findsNothing);
    expect(find.text('Lencana Kehormatan'), findsNothing);
    expect(find.text('Penjelajah Candi'), findsNothing);
    expect(find.text('Pamor Tosan Aji'), findsNothing);
    expect(find.text('Pemutar Lagu Jawa (Swara Jawa)'), findsNothing);
    expect(find.text('DJ Negoro Angin, Rungkad, Pop Jawa & Gamelan'), findsNothing);
  });

  testWidgets('ProfileTab displays Guest Account (Tamu JAVARA) mode and conversion banner when in guest mode', (tester) async {
    SharedPreferences.setMockInitialValues({
      'javara_pref_aksara': true,
      'javara_pref_gamelan': true,
      'javara_is_guest': true,
      'javara_profile_name': 'Tamu JAVARA',
      'javara_profile_email': 'tamu.budaya@javara.id',
    });

    tester.view.physicalSize = const Size(500, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Guest Profile Name & Email
    expect(find.text('Tamu JAVARA'), findsOneWidget);
    expect(find.text('tamu.budaya@javara.id'), findsOneWidget);

    // 2. Verify Guest Badge
    expect(find.text('Akun Tamu · Penjelajah Budaya'), findsOneWidget);

    // 3. Verify Guest Conversion Banner
    expect(find.text('Anda Menggunakan Akun Tamu'), findsOneWidget);
    expect(find.text('Masuk atau Daftar Akun'), findsOneWidget);

    // 4. Verify Logout Button label for Guest
    expect(find.text('Keluar dari Mode Tamu'), findsOneWidget);
  });
}
