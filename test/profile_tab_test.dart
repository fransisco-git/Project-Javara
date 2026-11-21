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
    expect(find.text('Pelestari Wastra Jawa Tengah'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Alamat Kirim'), findsOneWidget);

    // 2. Verify Fashion Activity Section
    expect(find.text('Aktivitas Busana Saya'), findsOneWidget);
    expect(find.text('Pesanan & Sewa Saya'), findsOneWidget);
    expect(find.text('Wishlist & Koleksi Tersimpan'), findsOneWidget);
    expect(find.text('Riwayat Try-On & Padu Padan'), findsOneWidget);

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
}
