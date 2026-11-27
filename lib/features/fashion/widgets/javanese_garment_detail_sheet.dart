import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../models/javanese_clothing_models.dart';

/// Lembar Penjelasan Detail Budaya & Konstruksi Busana Adat
class JavaneseGarmentDetailSheet extends StatelessWidget {
  const JavaneseGarmentDetailSheet({
    super.key,
    required this.item,
  });

  final ClothingItem item;

  static void show(BuildContext context, ClothingItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JavaneseGarmentDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF181310),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x66E4C590), width: 1.4),
          left: BorderSide(color: Color(0x33E4C590), width: 0.8),
          right: BorderSide(color: Color(0x33E4C590), width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x88000000),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle Bar Tarik Modal
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: const Color(0x55E4C590),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Detail Busana
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikon Kategori & Palet
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2018),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: item.accentColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: item.accentColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    item.category.icon,
                    color: item.accentColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0x22E4C590),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0x44E4C590), width: 0.8),
                            ),
                            child: Text(
                              item.region.title.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE4C590),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.javaneseScript,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE4C590),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.name,
                        style: JText.serif(
                          17,
                          weight: FontWeight.w700,
                          color: const Color(0xFFFAF6F0),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.gender.label} · ${item.socialContext.label}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFA89989),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFFA89989)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0x22E4C590), height: 1),

          // Konten Gulir Informasi Lengkap
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Makna & Filosofi Luhur
                  _buildSectionCard(
                    title: 'Makna & Filosofi Kebudayaan',
                    javaneseTitle: 'ꦥ꦳ꦶꦭꦺꦴꦱꦺꦴꦥ꦳ꦶꦭꦸꦲꦸꦂ',
                    icon: Icons.lightbulb_outline_rounded,
                    content: item.philosophicalMeaning,
                  ),
                  const SizedBox(height: 14),

                  // 2. Teknik Pemotongan, Jahitan & Konstruksi
                  _buildSectionCard(
                    title: 'Teknik Potongan & Konstruksi Busana',
                    javaneseTitle: 'ꦥꦺꦴꦠꦺꦴꦔꦤ꧀ꦧꦸꦱꦤ',
                    icon: Icons.content_cut_rounded,
                    content: item.cuttingAndConstruction,
                  ),
                  const SizedBox(height: 14),

                  // 3. Bahan & Material Tradisional
                  _buildSectionCard(
                    title: 'Material Kain & Ornamen',
                    javaneseTitle: 'ꦧꦲꦤ꧀ꦭꦤ꧀ꦩꦠꦺꦫꦶꦪꦭ꧀',
                    icon: Icons.texture_rounded,
                    content: '${item.material}\n\nMotif Tekstur: ${item.textureMotif}',
                  ),
                  const SizedBox(height: 14),

                  // 4. Catatan Sejarah & Era Periode
                  _buildSectionCard(
                    title: 'Latar Belakang Sejarah & Era (${item.period})',
                    javaneseTitle: 'ꦧꦧꦢ꧀ꦱꦼꦗꦫꦃ',
                    icon: Icons.history_edu_rounded,
                    content: item.historicalNotes,
                  ),
                  const SizedBox(height: 14),

                  // 5. Rujukan & Sumber Pustaka
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1712),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x22E4C590), width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.menu_book_rounded, color: Color(0xFFC79B3A), size: 14),
                            SizedBox(width: 6),
                            Text(
                              'RUJUKAN ILMIAH & PUSTAKA ADAT',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFC79B3A),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.references,
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFA89989),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String javaneseTitle,
    required IconData icon,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF201914),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33E4C590), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFFE4C590), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: JText.serif(
                      13,
                      weight: FontWeight.w700,
                      color: const Color(0xFFFAF6F0),
                    ),
                  ),
                ],
              ),
              Text(
                javaneseTitle,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC79B3A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFD4C8BC),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

