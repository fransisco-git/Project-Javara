import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../core/theme.dart';

/// Screen 05 — Batik & Motif (Galeri Wastra & Tekstil Tradisional Jawa Tengah)
class BatikMotifGalleryScreen extends StatefulWidget {
  const BatikMotifGalleryScreen({super.key});

  @override
  State<BatikMotifGalleryScreen> createState() => _BatikMotifGalleryScreenState();
}

class _BatikMotifGalleryScreenState extends State<BatikMotifGalleryScreen> {
  int _selectedMotifIndex = 0;

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
          'Ukuran ragam hias parang di atas 8 cm. Digambar dengan canting klowong di atas kain mori primisima dan dibabar menggunakan pewarna soga jambangan alami khas Laweyan.',
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
          'Ragam hias tersusun atas empat bulatan lonjong berpotongan simetris berukuran kecil sebesar uang koin picis kuno. Ditulis menggunakan canting klowong untuk kerangka utama dan canting cecek untuk isen-isen titik, lalu dibabar dengan pewarna alami keraton berupa wedel biru nila dan soga cokelat.',
      historicalOrigin:
          'Salah satu motif tertua di Nusantara yang telah terpahat pada relief candi zaman Singhasari dan Majapahit abad ke-13.',
      primaryColor: const Color(0xFF2C1E14),
      accentColor: const Color(0xFFD6B57E),
      imagePath: 'assets/images/batik/batik_kawung_picis.jpg',
      relatedGarmentId: 'jarik_batik_kawung_picis',
    ),
    _ExtendedBatikData(
      id: 'motif_sidomukti',
      name: 'Sidomukti Solo',
      javaneseScript: 'ꦱꦶꦢꦺꦴꦩꦸꦏ꧀ꦠꦶ',
      category: 'Semen / Gurda',
      region: 'Surakarta Hadiningrat',
      isLarangan: false,
      philosophy:
          '"Sido" berarti menjadi/terwujud, dan "Mukti" berarti mulia, bahagia, dan sejahtera. Mengandung doa tulus agar pemakainya memperoleh keluhuran derajat lahir batin.',
      usageContext:
          'Kain jarik wajib bagi mempelai pengantin adat Jawa gaya Solo saat prosesi panggih pernikahan.',
      technicalDetails:
          'Ornamen sayap garuda (lar), pohon hayat, takhta singgasana, dan kupu-kupu yang ditulis dengan canting secara halus di atas latar ukel uwer berpewarna soga cokelat kemerahan.',
      historicalOrigin:
          'Dikembangkan pada masa Susuhunan Paku Buwono IV di Kasunanan Surakarta pada akhir abad ke-18.',
      primaryColor: const Color(0xFF422C1A),
      accentColor: const Color(0xFFDFC08E),
      imagePath: 'assets/images/batik/batik_sidomukti.jpg',
      relatedGarmentId: 'jarik_batik_sidomukti_solo',
    ),
    _ExtendedBatikData(
      id: 'motif_truntum',
      name: 'Truntum',
      javaneseScript: 'ꦠꦿꦸꦤ꧀ꦠꦸꦩ꧀',
      category: 'Ceplok Bintang',
      region: 'Kasunanan Surakarta',
      isLarangan: false,
      philosophy:
          'Berasal dari kata "tumaruntum" yang berarti bersemi kembali. Bintang-bintang kecil bertabur di latar gelap malam melambangkan cinta sejati tanpa pamrih yang selalu menuntun generasi penerus.',
      usageContext:
          'Dikenakan khusus oleh orang tua pengantin pada upacara panggih pernikahan adat Jawa sebagai simbol doa restu yang tulus.',
      technicalDetails:
          'Bunga melati kuncup bersusun empat kelopak yang ditulis rapat menggunakan canting cecek halus membentuk gugusan bintang kencana, dibabar dengan pewarna alami soga dan wedel gelap. Kerap dipadukan dengan ornamen gurda pada variasi Truntum Seling atau Truntum Gurda.',
      historicalOrigin:
          'Diciptakan oleh Kanjeng Ratu Beruk (permaisuri Paku Buwono III) saat menatap bintang gemerlap di langit malam Keraton Solo.',
      primaryColor: const Color(0xFF281A10),
      accentColor: const Color(0xFFE8D3B0),
      imagePath: 'assets/images/batik/batik_truntum.jpg',
      relatedGarmentId: 'jarik_batik_truntum_solo',
    ),
    _ExtendedBatikData(
      id: 'motif_buketan_pekalongan',
      name: 'Buketan Pekalongan',
      javaneseScript: 'ꦧꦸꦏꦺꦠꦤ꧀ꦥꦼꦏꦭꦺꦴꦔꦤ꧀',
      category: 'Pesisir Flora Fauna',
      region: 'Pesisir Pekalongan (Pantura)',
      isLarangan: false,
      philosophy:
          'Rangkaian karangan bunga mawar, krisan, dan burung merak mencerminkan kegembiraan hidup masyarakat pesisir maritim yang terbuka terhadap pengaruh budaya dunia.',
      usageContext:
          'Busana keseharian masyarakat pesisir, pesta perkawinan peranakan, serta busana pergaulan masyarakat Indo-Eropa, Peranakan Tionghoa, dan perempuan pesisir.',
      technicalDetails:
          'Rangkaian karangan bunga bergaya Eropa (bouquet) lengkap dengan dedaunan dan burung kecil yang ditulis halus dengan canting di atas kain putih gading, dibabar dalam palet kelengan monokrom biru nila alami maupun pewarna sintetis pesisir abad ke-20.',
      historicalOrigin:
          'Akulturasi budaya pesisir Pekalongan dengan perajin Indo-Eropa dan Tionghoa pada awal abad ke-20.',
      primaryColor: const Color(0xFF5A1C1C),
      accentColor: const Color(0xFFE8B244),
      imagePath: 'assets/images/batik/batik_buketan_pekalongan.jpg',
      relatedGarmentId: 'jarik_batik_buketan_pekalongan',
    ),
    _ExtendedBatikData(
      id: 'motif_lasem_tiga_negeri',
      name: 'Tiga Negeri Lasem',
      javaneseScript: 'ꦧꦠꦶꦏ꧀ꦭꦱꦼꦩ꧀',
      category: 'PESISIRAN · AKULTURASI',
      region: 'Lasem, Rembang · Jawa Tengah',
      isLarangan: false,
      philosophy:
          'Melambangkan keharmonisan lintas budaya Jawa dan Tionghoa di pesisir utara Jawa Tengah. Perpaduan tiga warna utamanya menyimbolkan keberanian dan kebahagiaan, keteduhan jiwa, serta kebijaksanaan dalam menjalani kehidupan.',
      usageContext:
          'Umumnya dikenakan pada acara perayaan, jamuan resmi, dan busana kebaya encim atau busana adat pesisir Jawa Tengah.',
      technicalDetails:
          'Dikerjakan melalui proses pencelupan lintas tiga kota klasik di atas kain mori primisima: Lasem untuk warna merah akar mengkudu (abang getih pithik), Pekalongan atau Kudus untuk biru nila, serta Solo (Surakarta) untuk cokelat soga.',
      historicalOrigin:
          'Berkembang sejak abad ke-19 di pesisir Lasem, Rembang, Jawa Tengah melalui akulturasi pembatik Jawa dan peranakan Tionghoa yang melahirkan warna merah darah ayam legendaris.',
      primaryColor: const Color(0xFF4A1818),
      accentColor: const Color(0xFFE4C590),
      imagePath: 'assets/images/batik/batik_lasem_tiga_negeri.jpg',
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
          // 1. PRATINJAU FOTO KAIN BATIK ASLI (UTUH TANPA CROP & ZOOM)
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF14100D),
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
                borderRadius: BorderRadius.circular(15),
                child: SizedBox.expand(
                  child: Image.asset(
                    activeMotif.imagePath,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    cacheWidth: (MediaQuery.sizeOf(context).width *
                            MediaQuery.devicePixelRatioOf(context))
                        .round()
                        .clamp(360, 1200),
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                  ),
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
              scrollCacheExtent: const ScrollCacheExtent.pixels(400),
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
                    setState(() {
                      _selectedMotifIndex = index;
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
                            color: const Color(0xFF14100D),
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
                              fit: BoxFit.contain,
                              cacheWidth: (48 *
                                      MediaQuery.devicePixelRatioOf(context))
                                  .round()
                                  .clamp(96, 200),
                              gaplessPlayback: true,
                              filterQuality: FilterQuality.medium,
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
                  Column(
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
                    'Ciri Motif, Teknik & Pewarnaan',
                    activeMotif.technicalDetails,
                    Icons.color_lens_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailTile(
                    'Latar Sejarah & Asal-Usul',
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
