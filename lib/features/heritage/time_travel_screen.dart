import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';

/// Model Era Sejarah Jawa Tengah.
class HistoricalEra {
  const HistoricalEra({
    required this.period,
    required this.title,
    required this.ruler,
    required this.description,
    required this.relics,
    required this.wisdom,
    required this.icon,
  });

  final String period;
  final String title;
  final String ruler;
  final String description;
  final List<String> relics;
  final String wisdom;
  final IconData icon;
}

/// Halaman Penjelajah Waktu Sejarah Jawa Tengah (Time Travel Through History).
class TimeTravelScreen extends StatefulWidget {
  const TimeTravelScreen({super.key});

  @override
  State<TimeTravelScreen> createState() => _TimeTravelScreenState();
}

class _TimeTravelScreenState extends State<TimeTravelScreen> {
  int _selectedEraIndex = 1; // Default ke era Dinasti Syailendra

  static const List<HistoricalEra> _eras = [
    HistoricalEra(
      period: 'Abad ke-6 – ke-7 M',
      title: 'Kerajaan Kalingga (Holing)',
      ruler: 'Ratu Shima yang Adil & Tegas',
      description: 'Episentrum kebudayaan tertua di pesisir utara Jawa Tengah (Keling/Jepara). Terkenal di seluruh dunia karena kejujuran rakyatnya dan ketegasan hukum Ratu Shima yang tak pandang bulu.',
      relics: [
        'Prasasti Tuk Mas (lereng Gunung Merbabu)',
        'Situs Candi Angin & Candi Bubrah di Keling, Jepara',
        'Catatan musafir I-Tsing tentang penerjemahan kitab Buddhis',
      ],
      wisdom: 'Hukum adalah payung kemuliaan; kejujuran adalah pusaka paling berharga suatu bangsa.',
      icon: Icons.balance_rounded,
    ),
    HistoricalEra(
      period: 'Abad ke-8 – ke-9 M',
      title: 'Wangsa Syailendra (Borobudur Era)',
      ruler: 'Raja Samaratungga & Pramodhawardhani',
      description: 'Zaman keemasan peradaban andesit Buddha Mahayana di dataran Kedu. Puncak pencapaian arsitektur kosmik yang melahirkan Candi Borobudur, Mendut, dan Pawon.',
      relics: [
        'Candi Borobudur (Monumen Buddha terbesar di dunia)',
        'Prasasti Kayumwungan (Karangtengah)',
        'Candi Mendut dengan arca Buddha Vairocana setinggi 3 meter',
      ],
      wisdom: 'Perjalanan jiwa manusia dari belenggu nafsu (Kamadhatu) menuju kemurnian mutlak (Arupadhatu).',
      icon: Icons.temple_buddhist_rounded,
    ),
    HistoricalEra(
      period: 'Abad ke-9 – ke-10 M',
      title: 'Mataram Kuno (Hindu Sanjaya)',
      ruler: 'Rakai Pikatan & Dyah Balitung',
      description: 'Puncak kebangkitan peradaban Hindu Siwa di lembah Prambanan. Rakai Pikatan menikahi Pramodhawardhani dari Syailendra, mencerminkan toleransi dan harmoni antar-keyakinan.',
      relics: [
        'Kompleks Percandian Prambanan (Candi Siwa, Brahma, Wisnu)',
        'Prasasti Siwagrha (856 M)',
        'Candi Plaosan (Simbol cinta dua wangsa berbeda keyakinan)',
      ],
      wisdom: 'Keberagaman keyakinan yang disatukan oleh cinta melahirkan keindahan abadi.',
      icon: Icons.temple_hindu_rounded,
    ),
    HistoricalEra(
      period: 'Abad ke-15 – ke-16 M',
      title: 'Kesultanan Demak Bintoro',
      ruler: 'Raden Patah & Walisongo',
      description: 'Kerajaan maritim Islam pertama di tanah Jawa. Walisongo mengakulturasikan ajaran Islam melalui wayang kulit, tembang macapat, gamelan Sekaten, dan arsitektur atap tumpang.',
      relics: [
        'Masjid Agung Demak dengan saka guru Sunan Kalijaga',
        'Tradisi Gamelan Sekaten di bulan Maulid',
        'Pintu Bledeg Ki Ageng Selo',
      ],
      wisdom: 'Merawat tradisi lama yang baik, sembari merengkuh nilai baru yang lebih luhur.',
      icon: Icons.mosque_rounded,
    ),
    HistoricalEra(
      period: 'Abad ke-16 M',
      title: 'Kesultanan Pajang',
      ruler: 'Sultan Hadiwijaya (Jaka Tingkir)',
      description: 'Peralihan poros peradaban dari pesisir maritim menuju pedalaman agraris yang subur di lembah Bengawan Solo. Menjadi jembatan sejarah menuju berdirinya dinasti Mataram Islam.',
      relics: [
        'Petilasan Keraton Pajang di Kartasura, Sukoharjo',
        'Kisah kepahlawanan Babad Tanah Jawi',
        'Sistem tata kelola sawah irigasi tradisional',
      ],
      wisdom: 'Kesabaran dan kerendahan hati seorang ksatria mampu mengubah takdir zaman.',
      icon: Icons.agriculture_rounded,
    ),
    HistoricalEra(
      period: 'Abad ke-18 M – Sekarang',
      title: 'Kasunanan Surakarta & Mangkunegaran',
      ruler: 'Pakubuwana & Mangkunegara',
      description: 'Lahirnya adiluhung budaya Keraton Jawa: tari Bedhaya Ketawang, Serat Wedhatama karya KGPAA Mangkunegara IV, bahasa krama inggil, dan pusat pelestarian batik tulis.',
      relics: [
        'Keraton Kasunanan Surakarta Hadiningrat',
        'Pura Mangkunegaran & Pendopo Ageng terluas di dunia',
        'Naskah sastra luhur Serat Centhini & Serat Kalatidha',
      ],
      wisdom: 'Ngurip-urip kabudayan: merawat akar tradisi agar ranting bangsa berdiri kokoh di panggung dunia.',
      icon: Icons.castle_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeEra = _eras[_selectedEraIndex];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: JColors.ink,
              size: 18,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Garis Waktu Sejarah',
            style: JText.serif(18, weight: FontWeight.w700, color: JColors.ink),
          ),
          centerTitle: true,
        ),
        body: JBackground(
          variant: HeritageBackgroundVariant.explore,
          child: SafeArea(
            child: Column(
            children: [
              // --- TIMELINE SELECTOR HORIZONTAL ---
              Container(
                height: 84,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3EBDE),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2D4BE))),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _eras.length,
                  itemBuilder: (context, index) {
                    final era = _eras[index];
                    final isSelected = index == _selectedEraIndex;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedEraIndex = index);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3A261D)
                              : const Color(0xFFFFFDF9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF3A261D)
                                : const Color(0xFFDEC5A4),
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x333A261D),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              era.icon,
                              size: 18,
                              color: isSelected
                                  ? const Color(0xFFFFDF9E)
                                  : const Color(0xFFC79835),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  era.period,
                                  style: JText.serif(
                                    9.5,
                                    color: isSelected
                                        ? const Color(0xFFFFDF9E)
                                        : JColors.muted,
                                  ),
                                ),
                                Text(
                                  era.title.split('(').first.trim(),
                                  style: JText.serif(
                                    12,
                                    weight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : JColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // --- KONTEN DETAIL ERA TERPILIH ---
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    // Card Era
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDF9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEADBCA)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0x33DFB76C),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  activeEra.icon,
                                  color: const Color(0xFF8C5D17),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeEra.period,
                                      style: JText.serif(
                                        11,
                                        weight: FontWeight.w600,
                                        color: const Color(0xFFB5603A),
                                      ),
                                    ),
                                    Text(
                                      activeEra.title,
                                      style: JText.serif(
                                        18,
                                        weight: FontWeight.w800,
                                        color: JColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3EBDE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Tokoh Utama: ${activeEra.ruler}',
                              style: JText.serif(
                                11.5,
                                weight: FontWeight.w600,
                                color: const Color(0xFF4A382A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            activeEra.description,
                            style: JText.serif(
                              13.5,
                              height: 1.6,
                              color: const Color(0xFF4A382A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Falsafah Luhur Zaman Ini
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF261B2F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0x66DFB76C),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.wb_incandescent_outlined,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Falsafah & Petuah Leluhur',
                                style: JText.serif(
                                  12,
                                  weight: FontWeight.w700,
                                  color: const Color(0xFFFFDF9E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"${activeEra.wisdom}"',
                            style: JText.serif(
                              13.5,
                              style: FontStyle.italic,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Peninggalan & Warisan Fisik
                    Text(
                      'Peninggalan yang Masih Lestari',
                      style: JText.serif(
                        16,
                        weight: FontWeight.w700,
                        color: JColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final relic in activeEra.relics) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEADBCA)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.museum_outlined,
                              size: 18,
                              color: Color(0xFF8C5D17),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                relic,
                                style: JText.serif(13, color: JColors.ink),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
