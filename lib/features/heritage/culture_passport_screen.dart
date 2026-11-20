import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';

/// Model Cap Wilayah Paspor Budaya Keraton Jawa.
class PassportStamp {
  const PassportStamp({
    required this.id,
    required this.regencyName,
    required this.javaneseScript,
    required this.regionCategory, // Solo Raya, Kedu, Semarang Raya, Banyumasan, Pantura
    required this.capital,
    required this.sealEmblem,
    required this.sealColor,
    required this.heritageHighlight,
    required this.historicalNote,
    required this.isCollected,
    required this.visitedDate,
    required this.passportPage,
  });

  final String id;
  final String regencyName;
  final String javaneseScript;
  final String regionCategory;
  final String capital;
  final IconData sealEmblem;
  final Color sealColor;
  final String heritageHighlight;
  final String historicalNote;
  final bool isCollected;
  final String visitedDate;
  final int passportPage;
}

/// Halaman Paspor Budaya Digital Jawa Tengah (Digital Cultural Passport & Stamp Collection).
/// Desain layout buku paspor perkamen kuno (antique vintage parchment) dengan segel lilin kerajaan (wax seals),
/// filigri emas prada, dan stempel deboss untuk wilayah terkunci.
class CulturePassportScreen extends StatefulWidget {
  const CulturePassportScreen({super.key});

  @override
  State<CulturePassportScreen> createState() => _CulturePassportScreenState();
}

class _CulturePassportScreenState extends State<CulturePassportScreen>
    with SingleTickerProviderStateMixin {
  // Palet Warna Khas Paspor Perkamen Kuno & Kulit Sogan Jawa (Brown & Cream Luxury)
  static const Color leatherDark = Color(0xFF241711); // Kulit luar buku paspor
  static const Color parchmentLight = Color(0xFFFBF6ED); // Kertas perkamen kuno
  static const Color parchmentBase = Color(0xFFF4E9D8);
  static const Color parchmentDarker = Color(0xFFE4D2B8);
  static const Color inkDark = Color(0xFF281A12); // Tinta cap kuno
  static const Color inkMuted = Color(0xFF6E5949);
  static const Color antiqueGold = Color(0xFFC79B3A); // Emas filigri prada
  static const Color goldLight = Color(0xFFFFE8B3);
  static const Color redRibbon = Color(0xFF8F1D1D); // Pita pembatas buku

  late List<PassportStamp> _stamps;
  String _selectedRegion = 'Semua';
  int _activeBookTab = 0; // 0: Lembar Cap Segel, 1: Catatan Perjalanan

  static const List<String> _regionFilters = [
    'Semua',
    'Solo Raya',
    'Kedu',
    'Semarang Raya',
    'Pantura',
    'Banyumasan',
  ];

  @override
  void initState() {
    super.initState();
    _stamps = [
      // 1. SURAKARTA / SOLO
      const PassportStamp(
        id: 'solo',
        regencyName: 'Kota Surakarta (Solo)',
        javaneseScript: 'ꦱꦸꦫꦏꦂꦠ',
        regionCategory: 'Solo Raya',
        capital: 'Surakarta Hadiningrat',
        sealEmblem: Icons.castle_rounded,
        sealColor: Color(0xFF8B1E1E), // Ruby Keraton Red
        heritageHighlight: 'Keraton Kasunanan & Kampung Batik Laweyan',
        historicalNote:
            'Pusat kebudayaan adiluhung Mataram Islam Dinasti Pakubuwana. Memiliki tradisi Sekaten, gamelan pusaka Kyai Guntur Madu, dan wastra batik sogan klasik tertua.',
        isCollected: true,
        visitedDate: '05 NOV 2026',
        passportPage: 1,
      ),
      // 2. MAGELANG
      const PassportStamp(
        id: 'magelang',
        regencyName: 'Kabupaten Magelang',
        javaneseScript: 'ꦩꦒꦼꦭꦁ',
        regionCategory: 'Kedu',
        capital: 'Kota Mungkid',
        sealEmblem: Icons.temple_buddhist_rounded,
        sealColor: Color(0xFFB8731F), // Amber Borobudur Gold
        heritageHighlight: 'Candi Borobudur, Mendut & Pawon',
        historicalNote:
            'Mahakarya wangsa Syailendra abad ke-8 di lembah subur Kedu, dikelilingi Gunung Merapi, Merbabu, Sumbing, Sindoro, dan Pegunungan Menoreh.',
        isCollected: true,
        visitedDate: '04 NOV 2026',
        passportPage: 1,
      ),
      // 3. JEPARA
      const PassportStamp(
        id: 'jepara',
        regencyName: 'Kabupaten Jepara',
        javaneseScript: 'ꦗꦼꦥꦫ',
        regionCategory: 'Pantura',
        capital: 'Jepara',
        sealEmblem: Icons.carpenter_rounded,
        sealColor: Color(0xFF784A22), // Teak Wood Ochre
        heritageHighlight: 'Seni Ukir Kayu Jati & Bumi Ratu Kalinyamat',
        historicalNote:
            'Pusat ukiran kayu kelas dunia peninggalan kemaritiman Kesultanan Kalinyamat dan tempat lahir pelopor emansipasi RA Kartini.',
        isCollected: true,
        visitedDate: '06 NOV 2026',
        passportPage: 1,
      ),
      // 4. SEMARANG
      const PassportStamp(
        id: 'semarang',
        regencyName: 'Kota Semarang',
        javaneseScript: 'ꦱꦼꦩꦫꦁ',
        regionCategory: 'Semarang Raya',
        capital: 'Semarang',
        sealEmblem: Icons.account_balance_rounded,
        sealColor: Color(0xFF1C5242), // Kota Lama Emerald Pine
        heritageHighlight: 'Kota Lama, Lawang Sewu & Sam Poo Kong',
        historicalNote:
            'Kota pelabuhan kosmopolit perjumpaan budaya Jawa, Tionghoa, Arab, dan Eropa dengan arsitektur cagar budaya Little Netherland.',
        isCollected: true,
        visitedDate: '06 NOV 2026',
        passportPage: 2,
      ),
      // 5. PEKALONGAN
      const PassportStamp(
        id: 'pekalongan',
        regencyName: 'Kota Pekalongan',
        javaneseScript: 'ꦥꦼꦏꦭꦺꦴꦔꦤ꧀',
        regionCategory: 'Pantura',
        capital: 'Pekalongan',
        sealEmblem: Icons.palette_rounded,
        sealColor: Color(0xFF183457), // Indigo Batik Blue
        heritageHighlight: 'Kota Kreatif Batik Dunia UNESCO',
        historicalNote:
            'Sentra batik pesisir warna-warni cerah akulturasi budaya Tionghoa dan Belanda dengan motif legendaris Buketan dan Jlamprang.',
        isCollected: true,
        visitedDate: '06 NOV 2026',
        passportPage: 2,
      ),
      // 6. KUDUS
      const PassportStamp(
        id: 'kudus',
        regencyName: 'Kabupaten Kudus',
        javaneseScript: 'ꦏꦸꦢꦸꦱ꧀',
        regionCategory: 'Pantura',
        capital: 'Kudus',
        sealEmblem: Icons.mosque_rounded,
        sealColor: Color(0xFF943B26), // Terakota Red Brick
        heritageHighlight: 'Menara Kudus & Rumah Adat Joglo Pencu',
        historicalNote:
            'Menara masjid bercorak candi Majapahit abad ke-16 warisan Sunan Kudus, simbol toleransi dan harmonisasi antarumat beragama.',
        isCollected: true,
        visitedDate: '07 NOV 2026',
        passportPage: 2,
      ),
      // 7. BANYUMAS
      const PassportStamp(
        id: 'banyumas',
        regencyName: 'Kabupaten Banyumas',
        javaneseScript: 'ꦧꦚꦸꦩꦱ꧀',
        regionCategory: 'Banyumasan',
        capital: 'Purwokerto',
        sealEmblem: Icons.theater_comedy_rounded,
        sealColor: Color(0xFF4E3324), // Dark Walnut
        heritageHighlight: 'Kesenian Bawor, Wayang Kulit Gagrag Banyumasan',
        historicalNote:
            'Karakter budaya Cablaka/Blakasuta yang jujur, bersahaja, serta kaya akan tradisi kesenian Ebeg dan busana adat Banyumasan.',
        isCollected: false,
        visitedDate: '-',
        passportPage: 3,
      ),
      // 8. WONOSOBO
      const PassportStamp(
        id: 'wonosobo',
        regencyName: 'Kabupaten Wonosobo',
        javaneseScript: 'ꦮꦤꦱꦧ',
        regionCategory: 'Kedu',
        capital: 'Wonosobo',
        sealEmblem: Icons.landscape_rounded,
        sealColor: Color(0xFF284B35), // Dieng Mountain Green
        heritageHighlight: 'Kompleks Candi Arjuna Dieng & Telaga Warna',
        historicalNote:
            'Tanah kayangan para dewa di dataran tinggi vulkanik berkabut, menyimpan gugusan candi Hindu tertua di Jawa Tengah (abad ke-7).',
        isCollected: false,
        visitedDate: '-',
        passportPage: 3,
      ),
      // 9. DEMAK
      const PassportStamp(
        id: 'demak',
        regencyName: 'Kabupaten Demak',
        javaneseScript: 'ꦢꦼꦩꦏ꧀',
        regionCategory: 'Pantura',
        capital: 'Demak Bintoro',
        sealEmblem: Icons.temple_hindu_rounded,
        sealColor: Color(0xFF7A2020),
        heritageHighlight: 'Masjid Agung Demak & Saka Tatal Raden Patah',
        historicalNote:
            'Kerajaan Islam pertama di pulau Jawa, didirikan oleh Raden Patah dengan bimbingan sembilan wali suci (Wali Songo).',
        isCollected: false,
        visitedDate: '-',
        passportPage: 3,
      ),
      // 10. KARANGANYAR
      const PassportStamp(
        id: 'karanganyar',
        regencyName: 'Kabupaten Karanganyar',
        javaneseScript: 'ꦏꦫꦁꦲꦚꦂ',
        regionCategory: 'Solo Raya',
        capital: 'Karanganyar',
        sealEmblem: Icons.filter_hdr_rounded,
        sealColor: Color(0xFF5E3F26),
        heritageHighlight: 'Candi Sukuh & Candi Cetho Lereng Lawu',
        historicalNote:
            'Candi punden berundak unik abad ke-15 di lereng barat Gunung Lawu dengan pemandangan magis di atas samudera awan.',
        isCollected: false,
        visitedDate: '-',
        passportPage: 4,
      ),
      // 11. KLATEN
      const PassportStamp(
        id: 'klaten',
        regencyName: 'Kabupaten Klaten',
        javaneseScript: 'ꦏ꧀ꦭꦛꦺꦤ꧀',
        regionCategory: 'Solo Raya',
        capital: 'Klaten',
        sealEmblem: Icons.water_drop_rounded,
        sealColor: Color(0xFF1B4E57),
        heritageHighlight: 'Candi Plaosan Kembar & Umbul Ponggok',
        historicalNote:
            'Candi Plaosan lambang cinta sejati Rakai Pikatan dan Pramodawardhani yang menyatukan Hindu dan Buddha Mataram Kuno.',
        isCollected: false,
        visitedDate: '-',
        passportPage: 4,
      ),
      // 12. CILACAP
      const PassportStamp(
        id: 'cilacap',
        regencyName: 'Kabupaten Cilacap',
        javaneseScript: 'ꦕꦶꦭꦕꦥ꧀',
        regionCategory: 'Banyumasan',
        capital: 'Cilacap',
        sealEmblem: Icons.fort_rounded,
        sealColor: Color(0xFF333333),
        heritageHighlight: 'Benteng Pendem & Sedekah Laut Nelayan',
        historicalNote:
            'Benteng pertahanan pesisir abad ke-19 dan pusat upacara adat Larung Sesaji Nelayan Teluk Penyu di pesisir Samudera Hindia.',
        isCollected: false,
        visitedDate: '-',
        passportPage: 4,
      ),
    ];
  }

  // Filter daftar cap berdasarkan wilayah yang dipilih
  List<PassportStamp> get _filteredStamps {
    if (_selectedRegion == 'Semua') return _stamps;
    return _stamps.where((s) => s.regionCategory == _selectedRegion).toList();
  }

  int get _collectedCount => _stamps.where((s) => s.isCollected).length;
  int get _totalCount => 35; // Total 35 Kabupaten & Kota di Jawa Tengah

  // Simulasi cap wilayah secara interaktif
  void _stampRegency(PassportStamp stamp) {
    if (stamp.isCollected) {
      _showSealDetailModal(stamp);
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      final idx = _stamps.indexWhere((s) => s.id == stamp.id);
      if (idx != -1) {
        _stamps[idx] = PassportStamp(
          id: stamp.id,
          regencyName: stamp.regencyName,
          javaneseScript: stamp.javaneseScript,
          regionCategory: stamp.regionCategory,
          capital: stamp.capital,
          sealEmblem: stamp.sealEmblem,
          sealColor: stamp.sealColor,
          heritageHighlight: stamp.heritageHighlight,
          historicalNote: stamp.historicalNote,
          isCollected: true,
          visitedDate: '10 NOV 2026',
          passportPage: stamp.passportPage,
        );
      }
    });

    // Buka detail cap yang baru dibubuhkan
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        final updated = _stamps.firstWhere((s) => s.id == stamp.id);
        _showSealDetailModal(updated, isNewlyUnlocked: true);
      }
    });
  }

  // Dialog / Modal Inspeksi Segel Lilin Kerajaan
  void _showSealDetailModal(PassportStamp stamp, {bool isNewlyUnlocked = false}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RoyalSealDetailSheet(
        stamp: stamp,
        isNewlyUnlocked: isNewlyUnlocked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: leatherDark,
      ),
      child: Scaffold(
        backgroundColor: leatherDark,
        body: Stack(
          children: [
            // =================================================================
            // 1. LATAR BELAKANG KULIT GELAP BUKU PASPOR DENGAN JAHITAN EMAS
            // =================================================================
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.4,
                    colors: [
                      Color(0xFF332017),
                      Color(0xFF22140D),
                      Color(0xFF140B07),
                    ],
                  ),
                ),
              ),
            ),

            // Jahitan tepi buku paspor (decorative spine stitching)
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              width: 14,
              child: CustomPaint(
                painter: _LeatherSpineStitchPainter(
                  stitchColor: antiqueGold.withValues(alpha: 0.6),
                ),
              ),
            ),

            // =================================================================
            // 2. KONTEN UTAMA: LEMBAR PERKAMEN KUNO PASPOR BUDAYA
            // =================================================================
            SafeArea(
              child: Column(
                children: [
                  // Sleek Modern App Bar (Navigasi Elegan)
                  _buildSleekNavBar(),

                  // Badan Buku Perkamen (Scrollable Passport Pages)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 36),
                      child: _buildParchmentPassportBook(),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================================
            // 3. PITA PEMBATAS MERAH MARUN (BOOKMARK RIBBON)
            // =================================================================
            Positioned(
              top: 0,
              right: 32,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(22, 68),
                  painter: _BookmarkRibbonPainter(ribbonColor: redRibbon),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SLEEK NAVIGATION BAR ELEGAN ---
  Widget _buildSleekNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Kembali Beraksen Kuningan
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0x6620130C),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: antiqueGold.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: goldLight,
              ),
            ),
          ),

          // Judul Header Navigasi Sleek
          Column(
            children: [
              Text(
                'SERAT PASPOR BUDAYA',
                style: JText.serif(
                  15,
                  weight: FontWeight.w800,
                  color: goldLight,
                ).copyWith(letterSpacing: 2.0),
              ),
              const SizedBox(height: 2),
              const Text(
                'ꦥꦱ꧀ꦥꦺꦴꦂꦧꦸꦢꦪꦗꦮ • NO. JV-2026-7789',
                style: TextStyle(
                  fontSize: 10,
                  color: antiqueGold,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          // Tombol Bagikan / Bantuan Cap
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paspor Budaya tersinkronisasi dengan akun JAVARA Anda.'),
                  duration: Duration(milliseconds: 1400),
                  backgroundColor: Color(0xFF2E2019),
                ),
              );
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0x6620130C),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: antiqueGold.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                size: 18,
                color: goldLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BUKU PASPOR PERKAMEN KUNO DENGAN DECKLE-EDGE ---
  Widget _buildParchmentPassportBook() {
    final progress = _collectedCount / _totalCount;

    return Container(
      decoration: BoxDecoration(
        color: parchmentBase,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD8C2A0),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Texture & Watermark Motif Batik Kawung Kuno di Latar Perkamen
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: _ParchmentWatermarkPainter(
                  watermarkColor: const Color(0x0C2B1A12),
                ),
              ),
            ),
          ),

          // Garis Tepi Hias Filigri Sudut Kuno (Deckle-Edge Ornamental Filigree)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: _ParchmentBorderFiligreePainter(
                  lineColor: const Color(0x338A643A),
                  cornerColor: antiqueGold,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // =============================================================
                // A. KARTU IDENTITAS RESMI PASPOR PRAJA JAWA TENGAH
                // =============================================================
                _buildPassportIdentityHeader(progress),

                const SizedBox(height: 22),

                // =============================================================
                // B. TAB SWITCHER BUKU: LEMBAR CAP SEGEL VS CATATAN LOG
                // =============================================================
                _buildBookTabSwitcher(),

                const SizedBox(height: 16),

                // =============================================================
                // C. FILTER KELOMPOK WILAYAH (SOLO RAYA, KEDU, DLL)
                // =============================================================
                _buildRegionFilterChips(),

                const SizedBox(height: 20),

                // =============================================================
                // D. GRID SEGEL LILIN KERAJAAN & CAP TERKUNCI EMBOSS
                // =============================================================
                _buildWaxSealsStampGrid(),

                const SizedBox(height: 24),

                // =============================================================
                // E. FOOTER RESMI LEMBAR PENGESAHAN KERATON
                // =============================================================
                _buildOfficialParchmentFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- KARTU IDENTITAS RESMI PASPOR BUDAYA ---
  Widget _buildPassportIdentityHeader(double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: parchmentLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC79B3A).withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Lambang Segel Emas Keraton Jawa Tengah
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFE6C47A), Color(0xFF9E7122)],
                  ),
                  border: Border.all(color: goldLight, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 28,
                  color: leatherDark,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PRAJA JAWA TENGAH',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: antiqueGold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x1F8B1E1E),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0x4D8B1E1E),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'RESMI',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF8B1E1E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Raden Mas Penjelajah',
                      style: JText.serif(
                        15.5,
                        weight: FontWeight.w800,
                        color: inkDark,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Tingkat: Warga Kehormatan Mataram (Tingkat III)',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0x33C79B3A), height: 1),
          const SizedBox(height: 12),

          // Progress Bar Koleksi Cap Wilayah
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Koleksi Cap Kerajaan',
                style: JText.serif(
                  12,
                  weight: FontWeight.w700,
                  color: inkDark,
                ),
              ),
              Text(
                '$_collectedCount / $_totalCount Wilayah (${(progress * 100).toInt()}%)',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8B1E1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),

          // Bilah Progres Emas Antik
          Container(
            height: 9,
            decoration: BoxDecoration(
              color: const Color(0x33C79B3A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0x55C79B3A),
                width: 0.8,
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.05, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE2C177), Color(0xFF9E6E1A)],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB SWITCHER BUKU: LEMBAR CAP VS CATATAN ---
  Widget _buildBookTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x228A643A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x338A643A), width: 0.9),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBookTabPill('Lembar Cap Segel (Grid)', 0),
          ),
          Expanded(
            child: _buildBookTabPill('Catatan Penjelajah', 1),
          ),
        ],
      ),
    );
  }

  Widget _buildBookTabPill(String title, int index) {
    final isSelected = _activeBookTab == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeBookTab = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? parchmentLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: const Color(0x66C79B3A), width: 1.0)
              : null,
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? inkDark : inkMuted,
          ),
        ),
      ),
    );
  }

  // --- FILTER KELOMPOK WILAYAH ---
  Widget _buildRegionFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _regionFilters.map((region) {
          final isSelected = _selectedRegion == region;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedRegion = region);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF281A12)
                      : parchmentLight.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? antiqueGold
                        : const Color(0x448A643A),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  region,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? goldLight : inkDark,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- GRID SEGEL LILIN KERAJAAN & CAP TERKUNCI ---
  Widget _buildWaxSealsStampGrid() {
    final list = _filteredStamps;

    if (_activeBookTab == 1) {
      return _buildTravelNotesView();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
        childAspectRatio: 0.76,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final stamp = list[index];
        return _buildStampGridItem(stamp);
      },
    );
  }

  // Widget Item Cap Tunggal (Segel Lilin / Emboss Terkunci)
  Widget _buildStampGridItem(PassportStamp stamp) {
    if (stamp.isCollected) {
      // 1. CAP TERBUKA: SEGEL LILIN TIMBUL DENGAN FILIGRI EMAS PRADA
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showSealDetailModal(stamp);
        },
        child: Container(
          decoration: BoxDecoration(
            color: parchmentLight.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SEGEL LILIN TIMBUL 3D ASLI DENGAN FILIGRI EMAS
              SizedBox(
                width: 82,
                height: 82,
                child: CustomPaint(
                  painter: _RoyalWaxSealPainter(
                    waxColor: stamp.sealColor,
                    goldBorder: antiqueGold,
                    icon: stamp.sealEmblem,
                    javaneseScript: stamp.javaneseScript,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Nama Kota & Aksara Jawa
              Text(
                stamp.regencyName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: JText.serif(
                  12,
                  weight: FontWeight.w800,
                  color: inkDark,
                ),
              ),

              const SizedBox(height: 2),

              // Tanggal Cap Bertinta Antik
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x1F8B1E1E),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  stamp.visitedDate,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8B1E1E),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // 2. CAP TERKUNCI: EMBOSSED LETTERPRESS DEBOSSED OUTLINE
      return GestureDetector(
        onTap: () => _stampRegency(stamp),
        child: Container(
          decoration: BoxDecoration(
            color: parchmentDarker.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0x408A643A),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LINGKARAN EMBOSS LETTERPRESS DEBOSSED
              SizedBox(
                width: 78,
                height: 78,
                child: CustomPaint(
                  painter: _LockedDebossedSealPainter(
                    outlineColor: const Color(0x668A643A),
                    emblem: stamp.sealEmblem,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                stamp.regencyName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: JText.serif(
                  11.5,
                  weight: FontWeight.w600,
                  color: inkMuted,
                ),
              ),

              const SizedBox(height: 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.touch_app_rounded,
                    size: 11,
                    color: Color(0xFF8A643A),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Ketuk untuk Cap',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8A643A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  // Tampilan Tab Catatan Penjelajah (Travel Log)
  Widget _buildTravelNotesView() {
    final collected = _stamps.where((s) => s.isCollected).toList();

    return Column(
      children: collected.map((s) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: parchmentLight.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x44C79B3A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: s.sealColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: antiqueGold, width: 1.2),
                ),
                child: Icon(s.sealEmblem, color: goldLight, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.regencyName,
                          style: JText.serif(
                            13.5,
                            weight: FontWeight.w800,
                            color: inkDark,
                          ),
                        ),
                        Text(
                          s.visitedDate,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8B1E1E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      s.heritageHighlight,
                      style: const TextStyle(
                        fontSize: 11,
                        color: inkMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- FOOTER RESMI LEMBAR PENGESAHAN KERATON ---
  Widget _buildOfficialParchmentFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x142B1A12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x338A643A), width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 20,
            color: antiqueGold,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TERCATAT DALAM BUKU BESAR KHASANAH JAWA',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: inkDark,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Setiap cap segel disahkan melalui verifikasi lokasi dan modul jelajah budaya.',
                  style: TextStyle(
                    fontSize: 10,
                    color: inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MODAL SHEET: DETAIL INSPEKSI SEGEL LILIN KERAJAAN (ROYAL WAX SEAL SHEET)
// =============================================================================
class _RoyalSealDetailSheet extends StatelessWidget {
  const _RoyalSealDetailSheet({
    required this.stamp,
    this.isNewlyUnlocked = false,
  });

  final PassportStamp stamp;
  final bool isNewlyUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFFFBF6ED), // Perkamen Terang
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag Handle Perkamen
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF8A643A).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 18),

          // Banner Ucapan jika Baru Terbuka
          if (isNewlyUnlocked)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x228B1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF8B1E1E)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: Color(0xFF8B1E1E)),
                  SizedBox(width: 6),
                  Text(
                    'CAP RESMI BERHASIL DIBUBUHKAN!',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF8B1E1E),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

          // SEGEL LILIN BESAR 3D BERFILIGRI EMAS
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _RoyalWaxSealPainter(
                waxColor: stamp.sealColor,
                goldBorder: const Color(0xFFC79B3A),
                icon: stamp.sealEmblem,
                javaneseScript: stamp.javaneseScript,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Aksara Jawa & Nama Wilayah
          Text(
            stamp.javaneseScript,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8B1E1E),
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stamp.regencyName,
            style: JText.serif(
              18,
              weight: FontWeight.w800,
              color: const Color(0xFF281A12),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Wilayah Adat: ${stamp.regionCategory} • Ibukota: ${stamp.capital}',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6E5949),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0x33C79B3A)),
          const SizedBox(height: 12),

          // Warisan & Sejarah
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warisan Budaya Unggulan:',
                  style: JText.serif(
                    12,
                    weight: FontWeight.w700,
                    color: const Color(0xFF281A12),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stamp.heritageHighlight,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B1E1E),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Catatan Piagam Sejarah:',
                  style: JText.serif(
                    12,
                    weight: FontWeight.w700,
                    color: const Color(0xFF281A12),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stamp.historicalNote,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF554336),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Tombol Aksi
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text('Bagikan Cap'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF281A12),
                    side: const BorderSide(color: Color(0xFFC79B3A)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Tutup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF281A12),
                    foregroundColor: const Color(0xFFFFE8B3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CUSTOM PAINTER: SEGEL LILIN KERAJAAN BERFILIGRI EMAS (ROYAL WAX SEAL)
// =============================================================================
class _RoyalWaxSealPainter extends CustomPainter {
  const _RoyalWaxSealPainter({
    required this.waxColor,
    required this.goldBorder,
    required this.icon,
    required this.javaneseScript,
  });

  final Color waxColor;
  final Color goldBorder;
  final IconData icon;
  final String javaneseScript;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Bayangan Jatuh Lilin 3D Timbul
    final shadowPaint = Paint()
      ..color = const Color(0x3D000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center.translate(1, 3), radius - 3, shadowPaint);

    // 2. Lingkaran Dasar Lilin Organik (Wax Seal Irregular Rim)
    final waxBasePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 0.85,
        colors: [
          Color.lerp(waxColor, Colors.white, 0.28)!,
          waxColor,
          Color.lerp(waxColor, Colors.black, 0.4)!,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - 2, waxBasePaint);

    // 3. Ring Filigri Emas Ganda Luar (Outer Gold Filigree Rings)
    final goldRingPaint = Paint()
      ..color = goldBorder
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - 5, goldRingPaint);

    final innerGoldPaint = Paint()
      ..color = goldBorder.withValues(alpha: 0.75)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - 9, innerGoldPaint);

    // 4. Ornamen Gerigi Manik Filigri Radial (Filigree Beads)
    final beadPaint = Paint()
      ..color = goldBorder
      ..style = PaintingStyle.fill;
    const numBeads = 16;
    for (int i = 0; i < numBeads; i++) {
      final angle = (i * 2 * math.pi) / numBeads;
      final bx = center.dx + (radius - 7) * math.cos(angle);
      final by = center.dy + (radius - 7) * math.sin(angle);
      canvas.drawCircle(Offset(bx, by), 1.2, beadPaint);
    }

    // 5. Cekungan Tengah Segel Kerajaan (Depressed Center Chamber)
    final innerWellPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.2),
        radius: 0.8,
        colors: [
          Color.lerp(waxColor, Colors.black, 0.25)!,
          Color.lerp(waxColor, Colors.black, 0.45)!,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 11));
    canvas.drawCircle(center, radius - 11, innerWellPaint);

    // 6. Gambar Ikon Simbol Kerajaan Emas di Tengah
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size.width * 0.36,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: const Color(0xFFFFDF9E),
          shadows: const [
            Shadow(
              color: Color(0x66000000),
              blurRadius: 3,
              offset: Offset(0, 1.5),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _RoyalWaxSealPainter oldDelegate) => false;
}

// =============================================================================
// CUSTOM PAINTER: CAP TERKUNCI EMBOSS DEBOSSED LETTERPRESS
// =============================================================================
class _LockedDebossedSealPainter extends CustomPainter {
  const _LockedDebossedSealPainter({
    required this.outlineColor,
    required this.emblem,
  });

  final Color outlineColor;
  final IconData emblem;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Lingkaran debossed shadow (kesan cap ditekan ke dalam kertas perkamen)
    final debossPaint = Paint()
      ..color = const Color(0x18000000)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 3, debossPaint);

    // Garis putus-putus cap tertekan
    final dashedRingPaint = Paint()
      ..color = outlineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - 5, dashedRingPaint);

    final innerRing = Paint()
      ..color = outlineColor.withValues(alpha: 0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius - 10, innerRing);

    // Ikon gembok & siluet emblem samar
    final lockPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.lock_outline_rounded.codePoint),
        style: TextStyle(
          fontSize: 22,
          fontFamily: Icons.lock_outline_rounded.fontFamily,
          package: Icons.lock_outline_rounded.fontPackage,
          color: outlineColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    lockPainter.paint(
      canvas,
      Offset(
        center.dx - lockPainter.width / 2,
        center.dy - lockPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _LockedDebossedSealPainter oldDelegate) => false;
}

// =============================================================================
// PAINTERS HIASAN PERKAMEN: JAHITAN KULIT, WATERMARK KAWUNG, SUDUT FILIGRI & PITA
// =============================================================================
class _LeatherSpineStitchPainter extends CustomPainter {
  const _LeatherSpineStitchPainter({required this.stitchColor});
  final Color stitchColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stitchPaint = Paint()
      ..color = stitchColor
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final step = 14.0;
    for (double y = 10; y < size.height; y += step) {
      canvas.drawLine(Offset(2, y), Offset(8, y + 4), stitchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LeatherSpineStitchPainter oldDelegate) => false;
}

class _ParchmentWatermarkPainter extends CustomPainter {
  const _ParchmentWatermarkPainter({required this.watermarkColor});
  final Color watermarkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = watermarkColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const step = 48.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        canvas.drawCircle(Offset(x, y), 16, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParchmentWatermarkPainter oldDelegate) => false;
}

class _ParchmentBorderFiligreePainter extends CustomPainter {
  const _ParchmentBorderFiligreePainter({
    required this.lineColor,
    required this.cornerColor,
  });

  final Color lineColor;
  final Color cornerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(14)), borderPaint);

    // Filigri 4 Sudut Kuno
    final cornerPaint = Paint()
      ..color = cornerColor.withValues(alpha: 0.65)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const cLen = 14.0;
    // Top-Left
    canvas.drawLine(const Offset(12, 12), const Offset(12 + cLen, 12), cornerPaint);
    canvas.drawLine(const Offset(12, 12), const Offset(12, 12 + cLen), cornerPaint);
    // Top-Right
    canvas.drawLine(Offset(size.width - 12, 12), Offset(size.width - 12 - cLen, 12), cornerPaint);
    canvas.drawLine(Offset(size.width - 12, 12), Offset(size.width - 12, 12 + cLen), cornerPaint);
    // Bottom-Left
    canvas.drawLine(Offset(12, size.height - 12), Offset(12 + cLen, size.height - 12), cornerPaint);
    canvas.drawLine(Offset(12, size.height - 12), Offset(12, size.height - 12 - cLen), cornerPaint);
    // Bottom-Right
    canvas.drawLine(Offset(size.width - 12, size.height - 12), Offset(size.width - 12 - cLen, size.height - 12), cornerPaint);
    canvas.drawLine(Offset(size.width - 12, size.height - 12), Offset(size.width - 12, size.height - 12 - cLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ParchmentBorderFiligreePainter oldDelegate) => false;
}

class _BookmarkRibbonPainter extends CustomPainter {
  const _BookmarkRibbonPainter({required this.ribbonColor});
  final Color ribbonColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 12)
      ..lineTo(0, size.height)
      ..close();

    final paint = Paint()
      ..color = ribbonColor
      ..style = PaintingStyle.fill;

    // Bayangan pita
    canvas.drawPath(path, Paint()..color = const Color(0x33000000)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(path, paint);

    // Jahitan emas halus di tengah pita
    final stitch = Paint()
      ..color = const Color(0x77C79B3A)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height - 14), stitch);
  }

  @override
  bool shouldRepaint(covariant _BookmarkRibbonPainter oldDelegate) => false;
}
