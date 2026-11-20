import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../data/culture_items.dart';
import '../../widgets/photo_box.dart';
import '../heritage/cultural_order_sheet.dart';
import 'explore_data.dart';
import 'explore_models.dart';
import 'quiz_screen.dart';
import 'story_detail_screen.dart';

/// Halaman Jelajah Budaya - Implementasi editorial dari Figma Page 2 ('jelajah_budaya.png').
/// Menampilkan cerita-cerita budaya Jawa dalam format majalah: foto besar, filter chip,
/// artikel editorial mendalam, call-to-action tiket pertunjukan, dan tautan produk terkait.
class JelajahBudayaScreen extends StatefulWidget {
  const JelajahBudayaScreen({super.key});

  @override
  State<JelajahBudayaScreen> createState() => _JelajahBudayaScreenState();
}

class _JelajahBudayaScreenState extends State<JelajahBudayaScreen> {
  String _activeChip = 'Semua';

  static const _chips = ['Semua', 'Tradisi', 'Rasa', 'Busana'];

  /// Data artikel budaya editorial (gabungan konten Explore dengan isStory=true dan artikel baru).
  List<_EditorialArticle> get _articles {
    final stories = exploreItemsList
        .where((e) => e.isStory && e.storyHeadline != null)
        .toList();

    final all = <_EditorialArticle>[
      // Artikel utama dari data Explore
      ...stories.map(
        (e) => _EditorialArticle(
          item: e,
          chipTag: switch (e.category) {
            ExploreCategory.budaya => 'Tradisi',
            ExploreCategory.busana => 'Busana',
            ExploreCategory.produk => 'Koleksi',
            _ => 'Tradisi',
          },
        ),
      ),
      // Artikel editorial tambahan busana adat Jawa Tengah
      _EditorialArticle(
        item: const ExploreItem(
          id: 'beskap_editorial',
          regionId: 'jateng',
          category: ExploreCategory.busana,
          title: 'Beskap, wibawa ksatria Jawa',
          subtitle: 'Baca selengkapnya',
          image: 'kebaya.png',
          isStory: true,
          readingTime: '3 menit',
          storyHeadline: 'Beskap, wibawa ksatria Jawa',
          storyIntro: 'Potongan tegas berkerah tegak tanpa lipatan, kancing asimetris dan lengkungan belakang tempat keris bersemayam.',
          storyParagraphs: [
            'Beskap bukan sekadar jas pria; ia adalah cermin kesantunan dan ketenangan batin ksatria Jawa. Garis leher tegak mengajarkan keteguhan prinsip moral dan pengendalian tutur kata.',
            'Bentuk belakang yang melengkung dirancang khusus agar warangka keris terselip nyaman tanpa mengganggu posisi duduk sila dalam pasowanan agung keraton.',
            'Kini, beskap terus bertransformasi menjadi busana formal pernikahan dan upacara resmi adat, simbol kebanggaan putra Jawa yang menjunjung luhur budi pekerti.',
          ],
          relatedProducts: [
            RelatedProduct(
              title: 'Beskap Langenharjan',
              subtitle: 'Rp475.000',
              icon: '👔',
            ),
          ],
        ),
        chipTag: 'Busana',
        linkedProductTitle: 'Beskap Langenharjan',
        linkedProductPrice: 'Rp475.000',
        linkedProductImage: 'kebaya.png',
      ),
      _EditorialArticle(
        item: const ExploreItem(
          id: 'kebaya_editorial',
          regionId: 'diy',
          category: ExploreCategory.produk,
          title: 'Kebaya, anggun lintas generasi',
          subtitle: 'Baca selengkapnya',
          image: 'kebaya.png',
          isStory: true,
          readingTime: '3 menit',
          storyHeadline: 'Kebaya, anggun lintas generasi',
          storyIntro: 'Dikenakan bersama jarik, kebaya merawat jejak keterampilan dan identitas. Temukan cara membawa keanggunan tradisi ke momenmu hari ini.',
          storyParagraphs: [
            'Kebaya bukan busana kuno; ia adalah kain hidup yang merekam perjalanan perempuan Nusantara. Dari istana keraton hingga pasar tradisional, kebaya menemani perempuan Jawa dalam tiap peran sosialnya.',
            'Kehalusan brokat, sulam benang emas, dan potongan kutubaru yang presisi mencerminkan kedisiplinan tangan perajin yang menghormati setiap detail. Satu helai kebaya bisa memakan waktu berminggu-minggu untuk diselesaikan.',
            'Hari ini, desainer muda Jawa memadukan potongan kebaya klasik dengan gaya kontemporer — menjaga esensinya tetap hidup di panggung dunia modern tanpa mengorbankan identitas tradisi.',
          ],
          relatedProducts: [
            RelatedProduct(
              title: 'Kebaya Tradisional Jawa',
              subtitle: 'Rp350.000',
              icon: '👘',
            ),
          ],
        ),
        chipTag: 'Busana',
        linkedProductTitle: 'Kebaya Tradisional Jawa',
        linkedProductPrice: 'Rp350.000',
        linkedProductImage: 'kebaya.png',
      ),
    ];

    if (_activeChip == 'Semua') return all;
    return all.where((a) => a.chipTag == _activeChip).toList();
  }

  @override
  Widget build(BuildContext context) {
    final articles = _articles;

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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                        ),
                        color: JColors.ink,
                      ),
                      Expanded(
                        child: Text(
                          'Jelajah Budaya',
                          textAlign: TextAlign.center,
                          style: JText.serif(
                            17,
                            weight: FontWeight.w600,
                            color: JColors.ink,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.bookmark_border_rounded,
                          size: 22,
                        ),
                        color: JColors.ink,
                      ),
                    ],
                  ),
                ),

                // Konten Scrollable
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    children: [
                      // Tagline & Headline
                      Text(
                        'KENALI AKARNYA. RASAKAN WARISANNYA.',
                        style: JText.serif(
                          11,
                          weight: FontWeight.w700,
                          color: JColors.terracotta,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cerita yang hidup, warisan yang dekat.',
                        style: JText.serif(
                          28,
                          weight: FontWeight.w700,
                          color: JColors.ink,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dari cerita ke pengalaman. Jelajahi budaya Jawa, lalu temukan karya yang terhubung dengannya.',
                        style: JText.serif(
                          14,
                          color: const Color(0xFF6E5B49),
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Filter Chips (Semua, Tradisi, Rasa, Busana)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _chips.map((chip) {
                            final isActive = _activeChip == chip;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  chip,
                                  style: JText.serif(
                                    12.5,
                                    weight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isActive
                                        ? JColors.cream
                                        : JColors.ink,
                                  ),
                                ),
                                selected: isActive,
                                onSelected: (_) =>
                                    setState(() => _activeChip = chip),
                                selectedColor: JColors.button,
                                backgroundColor: const Color(0xFFFFFDF9),
                                side: BorderSide(
                                  color: isActive
                                      ? JColors.button
                                      : const Color(0xFFDEC5A4),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                showCheckmark: false,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Artikel-artikel Editorial
                      ...articles.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final article = entry.value;
                        return _buildArticleSection(article, isFirst: idx == 0);
                      }),

                      const SizedBox(height: 20),

                      // Footer CTA: Kuis Budaya
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3A261D), Color(0xFF5A3A25)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: JColors.gold.withValues(alpha: 0.22),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
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
                                      color: JColors.cream,
                                    ),
                                  ),
                                  Text(
                                    'Kuis 10 soal budaya Jawa.',
                                    style: JText.serif(
                                      11.5,
                                      color: const Color(0xFFDEC5A4),
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
                                backgroundColor: JColors.gold,
                                foregroundColor: JColors.night,
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
                                'Mulai',
                                style: JText.serif(
                                  12.5,
                                  weight: FontWeight.w700,
                                  color: JColors.night,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildArticleSection(
    _EditorialArticle article, {
    required bool isFirst,
  }) {
    final item = article.item;
    final category =
        '${item.category.label} · ${item.readingTime ?? "3 MENIT BACA"}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto besar editorial (pada artikel pertama sesuai Figma)
          if (isFirst) ...[
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StoryDetailScreen(item: item),
                  ),
                );
              },
              child: Container(
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
            ),
            const SizedBox(height: 16),
          ],

          // Kategori & Durasi Baca
          Text(
            category.toUpperCase(),
            style: JText.serif(
              11,
              weight: FontWeight.w700,
              color: JColors.terracotta,
            ),
          ),

          const SizedBox(height: 8),

          // Headline Artikel
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StoryDetailScreen(item: item),
                ),
              );
            },
            child: Text(
              item.storyHeadline ?? item.title,
              style: JText.serif(
                22,
                weight: FontWeight.w700,
                color: JColors.ink,
                height: 1.25,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Intro
          if (item.storyIntro != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StoryDetailScreen(item: item),
                  ),
                );
              },
              child: Text(
                item.storyIntro!,
                style: JText.serif(
                  14,
                  color: const Color(0xFF4A3929),
                  height: 1.5,
                ),
              ),
            ),

          const SizedBox(height: 10),

          // CTA Baca selengkapnya
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StoryDetailScreen(item: item),
                ),
              );
            },
            child: Text(
              'Kenali ${item.title.toLowerCase()} →',
              style: JText.serif(
                13.5,
                weight: FontWeight.w600,
                color: JColors.button,
              ),
            ),
          ),

          // Call-to-action "ALAMI CERITANYA" (Pertunjukan Wayang) - sesuai Figma
          if (item.id == 'wayang_gamelan') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFE3D2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDFCDAF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.theater_comedy_rounded,
                        size: 16,
                        color: JColors.terracotta,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ALAMI CERITANYA',
                        style: JText.serif(
                          11,
                          weight: FontWeight.w700,
                          color: JColors.terracotta,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pertunjukan Wayang',
                    style: JText.serif(
                      16,
                      weight: FontWeight.w700,
                      color: JColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Yogyakarta · Jadwal mengikuti penyelenggara',
                    style: JText.serif(12, color: JColors.muted),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF9F5EE),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 44,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDFCCB2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: JColors.terracotta.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.confirmation_number_outlined,
                                        color: JColors.terracotta,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Jadwal Pentas Wayang Kulit',
                                            style: JText.serif(
                                              17,
                                              weight: FontWeight.w700,
                                              color: JColors.ink,
                                            ),
                                          ),
                                          Text(
                                            'Panggung Sasana Hinggil Dwi Abad',
                                            style: JText.serif(
                                              12,
                                              color: JColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFE9DEC8),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Waktu Pelaksanaan',
                                            style: JText.serif(
                                              12,
                                              color: JColors.muted,
                                            ),
                                          ),
                                          Text(
                                            'Setiap Sabtu Pahing (20.00 WIB)',
                                            style: JText.serif(
                                              12.5,
                                              weight: FontWeight.w600,
                                              color: JColors.ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Tiket Masuk',
                                            style: JText.serif(
                                              12,
                                              color: JColors.muted,
                                            ),
                                          ),
                                          Text(
                                            'Rp35.000 / orang',
                                            style: JText.serif(
                                              13,
                                              weight: FontWeight.w700,
                                              color: JColors.button,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '✓ Tiket berhasil dipesan. E-tiket disimpan di profil Anda.',
                                              ),
                                              backgroundColor: JColors.success,
                                            ),
                                          );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: JColors.button,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: Text(
                                      'Pesan Tiket Sekarang',
                                      style: JText.serif(
                                        14,
                                        weight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JColors.button,
                        foregroundColor: JColors.cream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(
                        'Lihat Jadwal & Pesan',
                        style: JText.serif(14, weight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Section "Kenali, lalu miliki" - Produk Terkait
          if (article.linkedProductTitle != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE9DEC8)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: AssetPhoto(
                        file: article.linkedProductImage ?? item.image,
                        width: 52,
                        height: 52,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.linkedProductTitle!,
                          style: JText.serif(
                            14.5,
                            weight: FontWeight.w700,
                            color: JColors.ink,
                          ),
                        ),
                        Text(
                          article.linkedProductPrice ?? '',
                          style: JText.serif(
                            13,
                            weight: FontWeight.w600,
                            color: JColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final item = CultureItem(
                        id: 'linked_${article.item.id}',
                        title:
                            article.linkedProductTitle ?? 'Karya Seni Budaya',
                        tag: 'Kriya & Kuliner',
                        meta: 'Koleksi Autentik',
                        image: article.linkedProductImage ?? 'batik.png',
                        price: article.linkedProductPrice ?? 'Rp150.000',
                        description:
                            'Karya autentik terkurasi yang selaras dengan cerita luhur ${article.item.storyHeadline ?? article.item.title}.',
                        history: 'Dihasilkan oleh komunitas pengrajin lokal untuk melestarikan warisan adiluhung Jawa.',
                        location: 'Jawa Tengah',
                        regency: 'Surakarta & Sekitarnya',
                        highlights: const [
                          'Karya Asli Pengrajin Lokal',
                          'Kemasan Ramah Lingkungan',
                          'Sertifikat Autentisitas Budaya',
                        ],
                      );
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CulturalOrderSheet(item: item),
                      );
                    },
                    child: Text(
                      'Pesan →',
                      style: JText.serif(
                        12.5,
                        weight: FontWeight.w600,
                        color: JColors.terracotta,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Divider tipis
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 1,
            color: const Color(0xFFE8D9C6),
          ),
        ],
      ),
    );
  }
}

class _EditorialArticle {
  const _EditorialArticle({
    required this.item,
    required this.chipTag,
    this.linkedProductTitle,
    this.linkedProductPrice,
    this.linkedProductImage,
  });

  final ExploreItem item;
  final String chipTag;
  final String? linkedProductTitle;
  final String? linkedProductPrice;
  final String? linkedProductImage;
}
