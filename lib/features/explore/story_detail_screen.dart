import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../data/culture_items.dart';
import '../../widgets/photo_box.dart';
import '../heritage/cultural_order_sheet.dart';
import 'explore_models.dart';
import 'quiz_screen.dart';

/// Halaman Detail Cerita Budaya (Ensiklopedia) - Desain asli dari Figma Page 2 ('joglo_detail.png').
class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({super.key, required this.item});

  final ExploreItem item;

  @override
  Widget build(BuildContext context) {
    final title = item.storyHeadline ?? item.title;
    final time = item.readingTime ?? '4 menit';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: JColors.cream,
        body: JBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                        ),
                        color: JColors.ink,
                        tooltip: 'Kembali',
                      ),
                      Expanded(
                        child: Text(
                          'Cerita Budaya',
                          textAlign: TextAlign.center,
                          style: JText.serif(
                            17,
                            weight: FontWeight.w600,
                            color: JColors.ink,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Cerita tersimpan di Favorit Anda.',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.bookmark_border_rounded,
                          size: 22,
                        ),
                        color: JColors.ink,
                        tooltip: 'Simpan ke Favorit',
                      ),
                    ],
                  ),
                ),

                // Konten Artikel Editorial
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto Utama Artikel
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x183A261D),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AssetPhoto(
                              file: item.image,
                              aspectRatio: 16 / 11,
                              width: double.infinity,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Kategori & Daerah
                        Text(
                          '${item.category.label} · JAWA TENGAH',
                          style: JText.serif(
                            12,
                            weight: FontWeight.w700,
                            color: JColors.terracotta,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Judul Artikel
                        Text(
                          title,
                          style: JText.serif(
                            24,
                            weight: FontWeight.w700,
                            color: JColors.ink,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Durasi Baca
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 15,
                              color: JColors.muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Bacaan $time',
                              style: JText.serif(12.5, color: JColors.muted),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Paragraf Pembuka
                        if (item.storyIntro != null) ...[
                          Text(
                            item.storyIntro!,
                            style: JText.serif(
                              14.5,
                              color: JColors.ink,
                              height: 1.6,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Paragraf-paragraf lanjutan
                        ...item.storyParagraphs.map(
                          (para) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Text(
                              para,
                              style: JText.serif(
                                14,
                                color: const Color(0xFF3F2B1F),
                                height: 1.65,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Call to Action: Kuis Budaya Terkait (Menghubungkan Ensiklopedia -> Kuis)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEFE2D0), Color(0xFFE5D2BA)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFDCC4A4)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: JColors.button,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.quiz_rounded,
                                  color: JColors.gold,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Uji Pemahamanmu',
                                      style: JText.serif(
                                        15,
                                        weight: FontWeight.w700,
                                        color: JColors.ink,
                                      ),
                                    ),
                                    Text(
                                      'Ikuti Kuis Budaya & kumpulkan lencana.',
                                      style: JText.serif(
                                        11.5,
                                        color: JColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const QuizScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: JColors.button,
                                  foregroundColor: JColors.cream,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Mulai Kuis',
                                  style: JText.serif(
                                    12,
                                    weight: FontWeight.w600,
                                    color: JColors.cream,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Bagian: "Temukan produk terkait" persis dari Figma Page 2 'joglo_detail.png'
                        if (item.relatedProducts.isNotEmpty) ...[
                          Text(
                            'Temukan produk terkait',
                            style: JText.serif(
                              18,
                              weight: FontWeight.w700,
                              color: JColors.ink,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...item.relatedProducts.map(
                            (prod) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFDF9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE9DEC8),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A3A261D),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4E9D8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    prod.icon,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                title: Text(
                                  prod.title,
                                  style: JText.serif(
                                    14.5,
                                    weight: FontWeight.w600,
                                    color: JColors.ink,
                                  ),
                                ),
                                subtitle: Text(
                                  prod.subtitle,
                                  style: JText.serif(12, color: JColors.muted),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: JColors.button,
                                  size: 20,
                                ),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  final cultureItem = CultureItem(
                                    id: 'prod_${prod.title.hashCode}',
                                    title: prod.title,
                                    tag: 'Kriya & Kuliner Pilihan',
                                    meta: prod.subtitle,
                                    image: item.image,
                                    price: prod.subtitle,
                                    description:
                                        'Karya autentik terkurasi yang melengkapi cerita ${item.title}. Dikerjakan oleh pengrajin lokal Jawa Tengah.',
                                    history: 'Dihasilkan secara turun-temurun dengan menjaga pakem dan nilai kearifan lokal.',
                                    location: 'Jawa Tengah',
                                    regency: 'Jawa Tengah',
                                    highlights: const [
                                      '100% Orisinal Lokal',
                                      'Kemasan Ramah Lingkungan',
                                      'Dukungan untuk Seniman Tradisi',
                                    ],
                                  );
                                  showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) =>
                                        CulturalOrderSheet(item: cultureItem),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
