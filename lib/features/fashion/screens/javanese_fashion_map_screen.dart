import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/transitions.dart';
import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';
import 'clothing_detail_screen.dart';

/// Screen 06 — Peta Persebaran Busana Tradisional Jawa Tengah
class JavaneseFashionMapScreen extends StatefulWidget {
  const JavaneseFashionMapScreen({super.key});

  @override
  State<JavaneseFashionMapScreen> createState() => _JavaneseFashionMapScreenState();
}

class _JavaneseFashionMapScreenState extends State<JavaneseFashionMapScreen> {
  int _selectedRegionIndex = 0;

  final List<_RegionalFashionDossier> _regions = [
    _RegionalFashionDossier(
      region: TraditionRegion.surakarta,
      title: 'Surakarta Hadiningrat (Solo)',
      javaneseScript: 'ꦱꦸꦫꦏꦂꦠꦲꦢꦶꦤꦶꦁꦫꦠ꧀',
      badge: 'PUSAT KERATON & ADILUHUNG',
      mapOffset: const Offset(0.68, 0.72),
      primaryGarmentName: 'Busana Jawi Jangkep & Langenharjan',
      traditionalTextile: 'Batik Sogan Klasik (Parang Barong, Sidomukti, Truntum)',
      uniqueTraits:
          'Blangkon trepes (belakang datar tanpa mondholan), beskap kancing leher tegak asimetris dengan krowok belakang wadah keris, wiru jarik menghadap ke kiri dengan ujung rapi, dan sabuk cinde epek timang bertatah intan.',
      historicalBackground:
          'Sejak Perjanjian Giyanti 1755 dan masa Susuhunan Paku Buwono III, busana adat Surakarta mencerminkan ketertiban tatakrama keraton yang disempurnakan pada era keemasan Paku Buwono X.',
      keyClothingIds: [
        'beskap_landhung_solo',
        'blangkon_surakarta_parang',
        'jarik_batik_parang_barong_solo',
        'keris_ladrang_solo_kayu_timoho',
      ],
    ),
    _RegionalFashionDossier(
      region: TraditionRegion.yogyakarta,
      title: 'Yogyakarta (Gagrag Ngayogyakarta)',
      javaneseScript: 'ꦔꦪꦺꦴꦒꦾꦏꦂꦠꦲꦢꦶꦤꦶꦁꦫꦠ꧀',
      badge: 'KOMPARASI TRADISI MATARAM',
      mapOffset: const Offset(0.55, 0.82),
      primaryGarmentName: 'Surjan Pranakan & Busana Mataram',
      traditionalTextile: 'Batik Sogan Latar Putih / Ceplok Nitik',
      uniqueTraits:
          'Blangkon mondholan (wadah rambut panjang ksatria), surjan lurik semanggi dengan kancing leher 2 (Syahadat) dan dada 6 (Rukun Iman), wiru jarik menampakkan tepi putih (tumpal ke kanan).',
      historicalBackground:
          'Diberikan perlakuan komparatif khusus di JAVARA: busana Gagrag Ngayogyakarta memiliki akar sejarah Mataram Islam yang sama, namun berbeda pakem potongan dengan Jawa Tengah Kasunanan Solo.',
      keyClothingIds: [
        'blangkon_yogyakarta_sidomukti',
        'surjan_ontrokusumo_sutra',
        'jarik_batik_kawung_picis',
      ],
    ),
    _RegionalFashionDossier(
      region: TraditionRegion.semarang,
      title: 'Semarang Pesisiran',
      javaneseScript: 'ꦱꦼꦩꦫꦁꦥꦼꦱꦶꦱꦶꦂ',
      badge: 'AKULTURASI PESISIR & PECINAN',
      mapOffset: const Offset(0.58, 0.36),
      primaryGarmentName: 'Busana Semarangan & Kebaya Encim',
      traditionalTextile: 'Batik Semarangan (Motif Asem Arang & Lawang Sewu)',
      uniqueTraits:
          'Kebaya encim dengan bordir kerancang halus di ujung tepi, selendang sutra tipis jingga, dan paduan jarik sogan pesisir yang lebih dinamis dibanding pakem keraton.',
      historicalBackground:
          'Sebagai pelabuhan niaga utama Jawa Tengah, Semarang melahirkan akulturasi harmonis antara keanggunan budaya keraton pedalaman dengan dinamika masyarakat Tionghoa dan pesisir.',
      keyClothingIds: [
        'kebaya_kutubaru_beludru_solo',
        'jarik_batik_buketan_pekalongan',
      ],
    ),
    _RegionalFashionDossier(
      region: TraditionRegion.pekalongan,
      title: 'Pekalongan (Kota Batik Dunia)',
      javaneseScript: 'ꦥꦼꦏꦭꦺꦴꦔꦤ꧀',
      badge: 'WARISAN BATIK PESISIR DUNIA',
      mapOffset: const Offset(0.38, 0.28),
      primaryGarmentName: 'Sarung Buketan & Kebaya Pesisir',
      traditionalTextile: 'Batik Pesisir (Buketan, Jlamprang, Oey Soe Tjoen)',
      uniqueTraits:
          'Warna-warna ekspresif cerah kontras (merah delima, hijau zamrud, kuning kencana), ragam hias buket bunga Eropa, merak, dan motif geometris Jlamprang akulturasi Gujarat.',
      historicalBackground:
          'Pusat diplomasi wastra tekstil dunia di pesisir utara Jawa Tengah yang diakui UNESCO sebagai City of Crafts and Folk Art untuk keunggulan seni batik.',
      keyClothingIds: [
        'jarik_batik_buketan_pekalongan',
        'kebaya_kartini_beludru_jepara',
      ],
    ),
    _RegionalFashionDossier(
      region: TraditionRegion.kudus,
      title: 'Kudus Kulon & Muria',
      javaneseScript: 'ꦏꦸꦢꦸꦱ꧀',
      badge: 'BUSANA ADAT SANTRI KUDUSAN',
      mapOffset: const Offset(0.72, 0.26),
      primaryGarmentName: 'Busana Adat Pengantin Kudusan',
      traditionalTextile: 'Kain Bordir Kudus & Batik Menara Muria',
      uniqueTraits:
          'Kebaya bordir icik khas Kudus, penutup kepala Caping Kalo (anyaman bambu halus legendaris), dan selendang sutra tosan aji Sunan Kudus.',
      historicalBackground:
          'Perpaduan nilai-nilai santri Sunan Kudus dengan kemakmuran saudagar kriya masa lalu, menghasilkan busana yang sangat santun dan bercita rasa tinggi.',
      keyClothingIds: [
        'kebaya_kutubaru_beludru_solo',
        'jarik_batik_kawung_picis',
      ],
    ),
    _RegionalFashionDossier(
      region: TraditionRegion.jepara,
      title: 'Jepara Bumi Kartini',
      javaneseScript: 'ꦗꦼꦥꦫ',
      badge: 'INTELEKTUAL & TENUN TROSO',
      mapOffset: const Offset(0.76, 0.18),
      primaryGarmentName: 'Kebaya Kartinian & Busana Kalinyamat',
      traditionalTextile: 'Tenun Ikat Troso & Batik Ukir Jepara',
      uniqueTraits:
          'Kebaya panjang leher V berbordir sulur ukiran Jepara tanpa bef kutubaru, dipadukan kain Tenun Troso ATBM yang kuat dan bersahaja.',
      historicalBackground:
          'Dua tokoh wanita agung Jepara, Ratu Kalinyamat (abad 16) dan R.A. Kartini (abad 19), meletakkan pondasi busana yang menjadi simbol emansipasi dan marwah kepemimpinan wanita Jawa.',
      keyClothingIds: [
        'kebaya_kartini_beludru_jepara',
        'sanggul_tekuk_ronce_melati',
        'jarik_batik_kawung_picis',
      ],
    ),
    _RegionalFashionDossier(
      region: TraditionRegion.banyumas,
      title: 'Banyumasan & Lembah Serayu',
      javaneseScript: 'ꦧꦚꦸꦩꦱ꧀',
      badge: 'TRADISI CABLAKA & WIRASABA',
      mapOffset: const Offset(0.24, 0.62),
      primaryGarmentName: 'Busana Ksatria Banyumasan & Mbawor',
      traditionalTextile: 'Batik Jonasan & Tenun Lurik Kasar',
      uniqueTraits:
          'Iket Wirasaba segitiga bersimpul samping, surjan atau beskap tanpa dasi keraton dengan karakter cablaka/blakasuta (kejujuran apa adanya tanpa basa-basi).',
      historicalBackground:
          'Kawasan Kadipaten Wirasaba dan Banyumas menjunjung tinggi sifat kerakyatan, kesederhanaan bersahaja, dan persaudaraan tanpa sekat kelas feodal.',
      keyClothingIds: [
        'blangkon_banyumasan_wirasaba',
        'surjan_lurik_klaten',
        'jarik_batik_kawung_picis',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeDossier = _regions[_selectedRegionIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFE4C590),
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            const Text(
              'Peta Persebaran Busana Daerah',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFAF6F0),
              ),
            ),
            Text(
              'ꦥꦼꦠꦧꦸꦱꦤꦗꦮꦠꦼꦔꦃ',
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFFE4C590).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: JBackground(
        variant: HeritageBackgroundVariant.wardrobe,
        child: Column(
          children: [
          // 1. PETA INTERAKTIF VISUAL GEOGRAFIS JAWA TENGAH
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1612),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0x55E4C590),
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Lukisan Peta Siluet Jawa Tengah
                    CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: _CentralJavaMapPainter(
                        selectedOffset: activeDossier.mapOffset,
                      ),
                    ),

                    // Pin Lokasi Interaktif Setiap Wilayah
                    ...List.generate(_regions.length, (index) {
                      final item = _regions[index];
                      final isSelected = index == _selectedRegionIndex;

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final px = item.mapOffset.dx * constraints.maxWidth;
                          final py = item.mapOffset.dy * constraints.maxHeight;

                          return Positioned(
                            left: px - 18,
                            top: py - 36,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedRegionIndex = index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: EdgeInsets.all(isSelected ? 6 : 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFE4C590)
                                      : const Color(0xFF2E2219),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(0x99E4C590)
                                          : Colors.black45,
                                      blurRadius: isSelected ? 12 : 4,
                                      spreadRadius: isSelected ? 3 : 0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  size: isSelected ? 20 : 15,
                                  color: isSelected
                                      ? const Color(0xFF14100D)
                                      : const Color(0xFFE4C590),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    // Label Instruksi Interaktif di Pojok
                    Positioned(
                      bottom: 12,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xCC1A1410),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              size: 13,
                              color: Color(0xFFE4C590),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Pilih Pin Wilayah untuk Membaca Khasanah Busana',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFFAF6F0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. DOSIR KHASANAH BUSANA WILAYAH TERPILIH
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF181310),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Color(0x44E4C590), width: 1.0),
                ),
              ),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Badge Kategori Wilayah & Aksara
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF261D17),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFE4C590),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          activeDossier.badge,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE4C590),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Text(
                        activeDossier.javaneseScript,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFDFC08E),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Judul Wilayah
                  Text(
                    activeDossier.title,
                    style: JText.serif(
                      22,
                      weight: FontWeight.w800,
                      color: const Color(0xFFFAF6F0),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Busana Utama & Wastra Khas
                  _buildRegionProperty(
                    'Busana Tradisional Khas',
                    activeDossier.primaryGarmentName,
                    Icons.checkroom_rounded,
                  ),

                  const SizedBox(height: 10),

                  _buildRegionProperty(
                    'Tekstil & Motif Khas',
                    activeDossier.traditionalTextile,
                    Icons.layers_rounded,
                  ),

                  const SizedBox(height: 10),

                  _buildRegionProperty(
                    'Ciri Khas & Pakem Adat',
                    activeDossier.uniqueTraits,
                    Icons.auto_awesome_rounded,
                  ),

                  const SizedBox(height: 10),

                  _buildRegionProperty(
                    'Latar Belakang Sejarah',
                    activeDossier.historicalBackground,
                    Icons.history_edu_rounded,
                  ),

                  const SizedBox(height: 18),

                  // DAFTAR ITEM BUSANA TERKAIT DI WILAYAH INI
                  const Text(
                    'Item Busana dari Wilayah Ini:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFAF6F0),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: activeDossier.keyClothingIds.map((id) {
                      final item = JavaneseClothingData.getItemById(id);
                      if (item == null) return const SizedBox.shrink();

                      return ActionChip(
                        backgroundColor: const Color(0xFF261D17),
                        side: const BorderSide(
                          color: Color(0x44E4C590),
                          width: 0.8,
                        ),
                        avatar: Icon(
                          item.category.icon,
                          size: 14,
                          color: const Color(0xFFE4C590),
                        ),
                        label: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFAF6F0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            fadeSlideRoute(ClothingDetailScreen(item: item)),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildRegionProperty(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1713),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x2EE4C590),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFFE4C590)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE4C590),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFDCD2C5),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionalFashionDossier {
  const _RegionalFashionDossier({
    required this.region,
    required this.title,
    required this.javaneseScript,
    required this.badge,
    required this.mapOffset,
    required this.primaryGarmentName,
    required this.traditionalTextile,
    required this.uniqueTraits,
    required this.historicalBackground,
    required this.keyClothingIds,
  });

  final TraditionRegion region;
  final String title;
  final String javaneseScript;
  final String badge;
  final Offset mapOffset;
  final String primaryGarmentName;
  final String traditionalTextile;
  final String uniqueTraits;
  final String historicalBackground;
  final List<String> keyClothingIds;
}

class _CentralJavaMapPainter extends CustomPainter {
  const _CentralJavaMapPainter({required this.selectedOffset});
  final Offset selectedOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()
      ..color = const Color(0xFF261D17)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF5A4432)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final waterPaint = Paint()
      ..color = const Color(0xFF101C24).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Garis pantai Utara & Selatan Jawa Tengah
    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.35); // Barat Utara (Brebes/Tegal)
    path.quadraticBezierTo(
      size.width * 0.38,
      size.height * 0.22,
      size.width * 0.58,
      size.height * 0.30,
    ); // Pekalongan & Semarang
    path.quadraticBezierTo(
      size.width * 0.76,
      size.height * 0.12,
      size.width * 0.82,
      size.height * 0.22,
    ); // Jepara Semenanjung Muria & Rembang
    path.lineTo(size.width * 0.88, size.height * 0.55); // Timur (Blora/Sragen)
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.82,
      size.width * 0.60,
      size.height * 0.88,
    ); // Solo & Wonogiri
    path.lineTo(size.width * 0.35, size.height * 0.86); // Yogyakarta & Kebumen
    path.quadraticBezierTo(
      size.width * 0.18,
      size.height * 0.82,
      size.width * 0.12,
      size.height * 0.65,
    ); // Cilacap Pantai Selatan
    path.close();

    canvas.drawRect(Offset.zero & size, waterPaint);
    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, borderPaint);

    // Gelombang laut halus di utara
    final wavePaint = Paint()
      ..color = const Color(0x334A6E82)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double y = size.height * 0.08; y < size.height * 0.25; y += 14) {
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.6, y),
        wavePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CentralJavaMapPainter oldDelegate) =>
      oldDelegate.selectedOffset != selectedOffset;
}

