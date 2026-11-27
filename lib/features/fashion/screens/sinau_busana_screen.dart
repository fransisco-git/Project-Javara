import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import 'clothing_catalog_screen.dart';

/// Layar Panduan & Khasanah Busana Jawa Adat ("Lookbook & Panduan Busana JAVARA")
///
/// Menyajikan panduan anatomi potongan busana adat Jawa Tengah, komparasi historis
/// (Beskap vs Surjan, Paes Ageng vs Kanigaran), serta tata krama pemakaian busana
/// (Batik Larangan Awisan Dalem) selayaknya majalah mode/editorial brand busana.
class SinauBusanaScreen extends StatelessWidget {
  const SinauBusanaScreen({super.key, this.isTab = false});

  final bool isTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: !isTab,
        leading: isTab
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF382315),
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Column(
          children: [
            const Text(
              'Panduan Busana Jawa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF382315),
              ),
            ),
            const Text(
              'ꦱꦶꦤꦲꦸꦧꦸꦱꦤꦗꦮ',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFB08D57),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, isTab ? 100 : 24),
        physics: const BouncingScrollPhysics(),
        children: [
          // Banner Pengantar Editorial Mode Tradisional
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF261810), Color(0xFF3D271A)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x44DFB76C)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFDFB76C).withValues(alpha: 0.18),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Color(0xFFDFB76C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khasanah Busana & Filosofi Wastra',
                        style: JText.serif(
                          14.5,
                          weight: FontWeight.w700,
                          color: const Color(0xFFFFF7E6),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Panduan anatomi, makna kancing, dan pakem busana keraton Jawa Tengah.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFD4C4B4),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 1. Beskap vs Surjan
          _buildArticleCard(
            title: 'Beskap vs. Surjan: Anatomi, Kancing & Filosofi',
            javaneseScript: 'ꦧꦼꦱ꧀ꦏꦥ꧀ꦭꦤ꧀ꦱꦸꦂꦗꦤ꧀',
            tag: 'STUDI BANDING HISTORIS',
            summary:
                'Meskipun keduanya adalah busana pria Jawa, Beskap memiliki kerah tegak kancing asimetris menyamping dengan potongan krowok di belakang untuk keris, sedangkan Surjan memiliki potongan lurus di depan dengan 6 kancing dada melambangkan Rukun Iman dan 2 di leher melambangkan Kalimah Syahadat.',
            points: [
              'Beskap: Busana resmi pasowanan agung di Keraton Kasunanan Surakarta.',
              'Surjan: Warisan Mataram Islam yang dirancang oleh Sunan Kalijaga/Sultan Agung.',
              'Surjan Ontrokusumo bermotif bunga hanya untuk kaum bangsawan.',
              'Surjan Lurik garis vertikal dipakai oleh rakyat dan abdi dalem.',
            ],
          ),
          const SizedBox(height: 16),

          // 2. Struktur Busana Jawi Jangkep
          _buildArticleCard(
            title: 'Struktur Busana Jawi Jangkep Kasunanan Surakarta',
            javaneseScript: 'ꦗꦮꦶꦗꦁꦏꦼꦥ꧀ꦱꦸꦫꦏꦂꦠ',
            tag: 'TATA BUSANA ADILUHUNG',
            summary:
                'Busana Jawi Jangkep tersusun dari 7 elemen sakral: Blangkon trepes, Rasukan Beskap, Bebet jarik wiru, Sabuk cinde pengekang hawa nafsu, Epek timang sepuh emas, Keris ladrang pusaka, dan Selop beludru payet.',
            points: [
              'Makna "Jawi Jangkep": Kelengkapan lahir batin seorang pria berjiwa ksatria.',
              'Keris diselipkan di belakang sebagai lambang senjata bukan untuk dipamerkan.',
              'Wiru jarik menghadap ke kiri dengan ujung menyudut rapi khas gaya Solo.',
            ],
          ),
          const SizedBox(height: 16),

          // 3. Paes Ageng vs Kanigaran
          _buildArticleCard(
            title: 'Paes Ageng vs. Kanigaran: Mahakarya Tata Rias Pengantin',
            javaneseScript: 'ꦥꦲꦺꦱ꧀ꦲꦒꦼꦁꦏꦤꦶꦒꦫꦤ꧀',
            tag: 'BUSANA PERNIKAHAN AGUNG',
            summary:
                'Paes Ageng mengusung lekukan paes bertepi prada emas di dahi dengan dodot kampuh, sedangkan Kanigaran mengenakan beskap dan kebaya beludru sutra hitam berhias sulaman kawat emas prada nan megah bersanding dengan kuluk tinggi.',
            points: [
              'Paes cengkorongan melambangkan kesucian batin pengantin wanita.',
              'Pengantin diposisikan laksana raja dan ratu sadina (sehari di pelaminan).',
              'Motif jarik Sidomukti mengiringi doa kelanggengan jodoh dunia akhirat.',
            ],
          ),
          const SizedBox(height: 16),

          // 4. Batik Larangan vs Batik Umum
          _buildArticleCard(
            title: 'Batik Awisan Dalem: Mengenal Ragam Motif Larangan',
            javaneseScript: 'ꦧꦠꦶꦏ꧀ꦭꦫꦔꦤ꧀ꦏꦫꦠꦺꦴꦤ꧀',
            tag: 'KOSMOLOGI BATIK KERATON',
            summary:
                'Keraton Surakarta dan Yogyakarta menetapkan aturan motif larangan seperti Parang Barong, Udan Liris, Semen Rama, dan Cemukiran yang hanya boleh dikenakan raja dan pangeran pati untuk menjaga ketertiban kosmologis istana.',
            points: [
              'Parang Barong ukuran di atas 8 cm: Simbol kedaulatan Sunan/Sultan.',
              'Rakyat umum mengenakan motif Kawung, Truntum, Ceplok, dan Sidoasih.',
              'Batik Pesisir Pekalongan menghadirkan motif buketan bunga yang bebas merdeka.',
            ],
          ),
          const SizedBox(height: 20),

          // Tombol CTA Belanja Busana di Katalog
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFB08D57), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10382315),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Ingin Mencoba Busana Adat Asli?',
                  style: JText.serif(
                    15,
                    weight: FontWeight.w700,
                    color: const Color(0xFF382315),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Jelajahi katalog lengkap busana adat Jawa Tengah beserta filosofi dan rujukan tempat membeli.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF7D6C5D),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF382315),
                      foregroundColor: const Color(0xFFFFDF9E),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ClothingCatalogScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.storefront_rounded, size: 18),
                    label: const Text(
                      'Buka Katalog Busana JAVARA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard({
    required String title,
    required String javaneseScript,
    required String tag,
    required String summary,
    required List<String> points,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x33B08D57), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10382315),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0x20B08D57),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0x44B08D57), width: 0.8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF382315),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                javaneseScript,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB08D57),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: JText.serif(
              16,
              weight: FontWeight.w700,
              color: const Color(0xFF382315),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(fontSize: 12, color: Color(0xFF4A3828), height: 1.45),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EADA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x22B08D57), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: points.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✦ ', style: TextStyle(color: Color(0xFFB08D57), fontSize: 10)),
                      Expanded(
                        child: Text(
                          p,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF382315)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
