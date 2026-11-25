import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/transitions.dart';
import '../data/javanese_clothing_data.dart';
import 'clothing_detail_screen.dart';

/// Screen 05 — Batik & Motif (Galeri Wastra & Tekstil Tradisional Jawa Tengah)
class BatikMotifGalleryScreen extends StatefulWidget {
  const BatikMotifGalleryScreen({super.key});

  @override
  State<BatikMotifGalleryScreen> createState() => _BatikMotifGalleryScreenState();
}

class _BatikMotifGalleryScreenState extends State<BatikMotifGalleryScreen> {
  final TransformationController _transformationController =
      TransformationController();
  int _selectedMotifIndex = 0;
  double _zoomScale = 1.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  // Extended Database Motif Batik & Wastra Adat Jawa Tengah
  final List<_ExtendedBatikData> _motifs = [
    _ExtendedBatikData(
      id: 'motif_parang_barong',
      name: 'Parang Barong Solo',
      javaneseScript: 'ꦥꦫꦁꦧꦫꦺꦴꦁ',
      category: 'Parang / Lereng',
      region: 'Kasunanan Surakarta Hadiningrat',
      isLarangan: true,
      philosophy:
          'Berasal dari kata "pereng" (tebing karang) dan "barong" (besar/singa). Pola lereng diagonal menyerupai ombak karang laut selatan yang tak pernah putus menabrak tebing, melambangkan watak ksatria yang pantang menyerah dalam menegakkan kebajikan.',
      usageContext:
          'Motif Larangan Keraton (Batik Awisan Dalem) tingkat tertinggi. Dahulu mutlak hanya boleh dikenakan oleh Sunan/Raja dan Putra Mahkota pada upacara Hajad Dalem.',
      technicalDetails:
          'Ukuran ragam hias parang di atas 8 cm. Digambar dengan canting klowong mori primissima dan dibabar dengan soga jembangan alami Laweyan.',
      historicalOrigin:
          'Diciptakan pada masa Sultan Agung Hanyakrakusuma di Mataram Islam abad ke-17 saat bermeditasi di pesisir Pantai Parangkusumo.',
      primaryColor: const Color(0xFF382315),
      accentColor: const Color(0xFFE4C590),
      imagePath: 'assets/images/batik/batik_parang_barong.jpg',
      relatedGarmentId: 'jarik_batik_parang_barong_solo',
    ),
    _ExtendedBatikData(
      id: 'motif_kawung_picis',
      name: 'Kawung Picis',
      javaneseScript: 'ꦏꦮꦸꦁꦥꦶꦕꦶꦱ꧀',
      category: 'Geometris Kolang-Kaling',
      region: 'Surakarta & Mataram',
      isLarangan: false,
      philosophy:
          'Empat bidang elips melingkari satu titik pusat melambangkan buah aren (kolang-kaling) yang putih bersih di dalam. Menggambarkan filosofi "Sedulur Papat Limo Pancer", serta ajaran agar manusia bermanfaat bagi sesama mulai dari pucuk daun hingga akar.',
      usageContext:
          'Dikenakan oleh kalangan cendekiawan, abdi dalem, dan priyayi yang mengedepankan ketulusan budi dan pengendalian hawa nafsu.',
      technicalDetails:
          'Ragam hias tersusun atas 4 lingkaran lonjong berpotongan simetris. Berukuran kecil sebesar uang koin picis kuno.',
      historicalOrigin:
          'Salah satu motif tertua di Nusantara yang telah terpahat pada relief candi zaman Singhasari dan Majapahit abad ke-13.',
      primaryColor: const Color(0xFF2C1E14),
      accentColor: const Color(0xFFD6B57E),
      imagePath: 'assets/images/batik/batik_kawung_picis.jpg',
      relatedGarmentId: 'jarik_batik_kawung_picis',
    ),
    _ExtendedBatikData(
      id: 'motif_sidomukti',
      name: 'Sidomukti Mangkunegaran',
      javaneseScript: 'ꦱꦶꦢꦺꦴꦩꦸꦏ꧀ꦠꦶ',
      category: 'Semen / Gurda',
      region: 'Surakarta Hadiningrat',
      isLarangan: false,
      philosophy:
          '"Sido" berarti menjadi/terwujud, dan "Mukti" berarti mulia, bahagia, dan sejahtera. Mengandung doa tulus agar pemakainya memperoleh keluhuran derajat lahir batin.',
      usageContext:
          'Kain jarik wajib bagi mempelai pengantin adat Jawa gaya Solo saat prosesi panggih pernikahan.',
      technicalDetails:
          'Ornamen sayap garuda (lar), pohon hayat, tahta singgasana, dan kupu-kupu yang dianyam halus dengan latar ukel uwer sogan cokelat kemerahan.',
      historicalOrigin:
          'Dikembangkan pada masa Susuhunan Paku Buwono IV di Kasunanan Surakarta pada akhir abad ke-18.',
      primaryColor: const Color(0xFF422C1A),
      accentColor: const Color(0xFFDFC08E),
      imagePath: 'assets/images/batik/batik_sidomukti.jpg',
      relatedGarmentId: 'jarik_batik_sidomukti_solo',
    ),
    _ExtendedBatikData(
      id: 'motif_truntum',
      name: 'Truntum Sri Katon',
      javaneseScript: 'ꦠꦿꦸꦤ꧀ꦠꦸꦩ꧀',
      category: 'Ceplok Bintang',
      region: 'Kasunanan Surakarta',
      isLarangan: false,
      philosophy:
          'Berasal dari kata "tumaruntum" yang berarti bersemi kembali. Bintang-bintang kecil bertabur di latar gelap malam melambangkan cinta sejati tanpa pamrih yang selalu menuntun generasi penerus.',
      usageContext:
          'Dikenakan khusus oleh orang tua pengantin pada upacara panggih pernikahan adat Jawa sebagai simbol doa restu yang tulus.',
      technicalDetails:
          'Bunga melati kuncup bersusun empat kelopak yang diulang secara rapat membentuk gugusan rasi bintang kencana.',
      historicalOrigin:
          'Diciptakan oleh Kanjeng Ratu Beruk (permaisuri Paku Buwono III) saat menatap bintang gemerlap di langit malam Keraton Solo.',
      primaryColor: const Color(0xFF281A10),
      accentColor: const Color(0xFFE8D3B0),
      imagePath: 'assets/images/batik/batik_truntum.jpg',
      relatedGarmentId: 'jarik_batik_truntum_solo',
    ),
    _ExtendedBatikData(
      id: 'motif_buketan_pekalongan',
      name: 'Batik Buketan Pekalongan',
      javaneseScript: 'ꦧꦸꦏꦺꦠꦤ꧀ꦥꦼꦏꦭꦺꦴꦔꦤ꧀',
      category: 'Pesisir Flora Fauna',
      region: 'Pesisir Pekalongan (Pantura)',
      isLarangan: false,
      philosophy:
          'Rangkaian karangan bunga mawar, krisan, dan burung merak mencerminkan kegembiraan hidup masyarakat pesisir maritim yang terbuka terhadap pengaruh budaya dunia.',
      usageContext:
          'Busana keseharian masyarakat pesisir, pesta perkawinan peranakan, dan diplomasi maritim Jawa.',
      technicalDetails:
          'Pewarnaan cerah kontras (merah jambu, toska, kuning emas) dengan gradasi tumpal segitiga pada kepala sarung.',
      historicalOrigin:
          'Akulturasi budaya pesisir Pekalongan dengan perajin Indo-Eropa dan Tionghoa pada awal abad ke-20.',
      primaryColor: const Color(0xFF5A1C1C),
      accentColor: const Color(0xFFE8B244),
      imagePath: 'assets/images/batik/batik_buketan_pekalongan.jpg',
      relatedGarmentId: 'jarik_batik_buketan_pekalongan',
    ),
    _ExtendedBatikData(
      id: 'motif_mega_mendung',
      name: 'Mega Mendung (Komparasi Budaya Cirebon)',
      javaneseScript: 'ꦩꦺꦒꦩꦼꦤ꧀ꦢꦸꦁ',
      category: 'Komparasi Wilayah Pesisir Pasundan-Jawa',
      region: 'Cirebon (Bukan Jawa Tengah, Pengaruh Pesisiran)',
      isLarangan: false,
      philosophy:
          'Awan mendung yang meredam terik matahari menyimbolkan kesabaran, kepala dingin, dan hati yang teduh dalam menghadapi amarah duniawi.',
      usageContext:
          'Busana adat Cirebon. Dicantumkan di JAVARA sebagai edukasi komparatif pembeda agar pengguna tidak salah mengira Mega Mendung berasal dari Jawa Tengah.',
      technicalDetails:
          'Garis awan berlapis 7 gradasi warna biru gelap hingga putih, melambangkan tujuh lapis langit.',
      historicalOrigin:
          'Lahir dari akulturasi Kesultanan Cirebon dengan permaisuri Putri Ong Tien asal Tiongkok pada masa Sunan Gunung Jati.',
      primaryColor: const Color(0xFF162D4A),
      accentColor: const Color(0xFF78B4E8),
      imagePath: 'assets/images/batik/batik_mega_mendung.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeMotif = _motifs[_selectedMotifIndex];

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
              'Galeri Batik & Motif Adiluhung',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFAF6F0),
              ),
            ),
            Text(
              'ꦮꦱ꧀ꦠꦿꦧꦠꦶꦏ꧀ꦗꦮꦠꦼꦔꦃ',
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
            // 1. KANVAS INTERAKTIF MOTIF (ZOOMABLE)
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1A1511),
                border: Border.all(
                  color: activeMotif.accentColor.withValues(alpha: 0.5),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Foto Kain Batik Asli (Zoomable 0.8x–4.0x)
                    Positioned.fill(
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        minScale: 0.8,
                        maxScale: 4.0,
                        onInteractionUpdate: (_) {
                          final scale = _transformationController.value
                              .getMaxScaleOnAxis();
                          if ((scale - _zoomScale).abs() > 0.01) {
                            setState(() => _zoomScale = scale);
                          }
                        },
                        child: Image.asset(
                          activeMotif.imagePath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),

                    // Badge Kategori & Larangan Adat
                    Positioned(
                      top: 14,
                      left: 14,
                      right: 14,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (activeMotif.isLarangan)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xE68B2518),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0x66FAF6F0),
                                  width: 0.6,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shield_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'AWISAN DALEM (LARANGAN)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xD914100D),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0x88E4C590),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              activeMotif.category,
                              style: const TextStyle(
                                color: Color(0xFFE4C590),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Kontrol Petunjuk Zoom
                    Positioned(
                      bottom: 12,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xCC14100D),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0x44E4C590),
                            width: 0.6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.pinch_rounded,
                              size: 13,
                              color: Color(0xFFDFC08E),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Cubit & Geser untuk Memperbesar (${_zoomScale.toStringAsFixed(1)}x)',
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFFDFC08E),
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

          // 2. PILIHAN MOTIF HORISONTAL CAROUSEL
          Container(
            height: 86,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: _motifs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final motif = _motifs[index];
                final isSelected = index == _selectedMotifIndex;

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    _transformationController.value = Matrix4.identity();
                    setState(() {
                      _selectedMotifIndex = index;
                      _zoomScale = 1.0;
                    });
                  },
                  child: Container(
                    width: 164,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF281E17)
                          : const Color(0xFF1A1410),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE4C590)
                            : const Color(0x33E4C590),
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE4C590)
                                  : const Color(0x33E4C590),
                              width: isSelected ? 1.2 : 0.7,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.asset(
                              motif.imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                motif.name,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? const Color(0xFFFAF6F0)
                                      : const Color(0xFFAFA295),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                motif.javaneseScript,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: isSelected
                                      ? const Color(0xFFDFC08E)
                                      : const Color(0xFF7A6D60),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. LEMBAR INFORMASI & FILOSOFI MOTIF
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeMotif.name,
                              style: JText.serif(
                                20,
                                weight: FontWeight.w800,
                                color: const Color(0xFFFAF6F0),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Asal: ${activeMotif.region}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFFB09F8F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (activeMotif.relatedGarmentId != null)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38271B),
                            foregroundColor: const Color(0xFFE4C590),
                            elevation: 0,
                            side: const BorderSide(
                              color: Color(0xFFE4C590),
                              width: 0.8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.checkroom_rounded, size: 14),
                          label: const Text(
                            'Lihat Busana',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () {
                            final item = JavaneseClothingData.getItemById(
                              activeMotif.relatedGarmentId!,
                            );
                            if (item != null) {
                              Navigator.of(context).push(
                                fadeSlideRoute(
                                  ClothingDetailScreen(item: item),
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildDetailTile(
                    'Filosofi & Makna Simbolis',
                    activeMotif.philosophy,
                    Icons.auto_awesome_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailTile(
                    'Tata Cara Penggunaan Adat',
                    activeMotif.usageContext,
                    Icons.event_seat_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailTile(
                    'Teknik & Pewarnaan Alami',
                    activeMotif.technicalDetails,
                    Icons.color_lens_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailTile(
                    'Latar Sejarah & Tokoh Pencipta',
                    activeMotif.historicalOrigin,
                    Icons.history_edu_rounded,
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

  Widget _buildDetailTile(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1713),
        borderRadius: BorderRadius.circular(14),
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
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFAF6F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFFC7B7A6),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtendedBatikData {
  const _ExtendedBatikData({
    required this.id,
    required this.name,
    required this.javaneseScript,
    required this.category,
    required this.region,
    required this.isLarangan,
    required this.philosophy,
    required this.usageContext,
    required this.technicalDetails,
    required this.historicalOrigin,
    required this.primaryColor,
    required this.accentColor,
    required this.imagePath,
    this.relatedGarmentId,
  });

  final String id;
  final String name;
  final String javaneseScript;
  final String category;
  final String region;
  final bool isLarangan;
  final String philosophy;
  final String usageContext;
  final String technicalDetails;
  final String historicalOrigin;
  final Color primaryColor;
  final Color accentColor;
  final String imagePath;
  final String? relatedGarmentId;
}
