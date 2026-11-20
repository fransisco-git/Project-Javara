import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme.dart';
import '../../../core/transitions.dart';
import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';
import 'clothing_detail_screen.dart';
import 'javanese_wardrobe_screen.dart';
import '../../../widgets/interactive_feedback.dart';

/// Layar Eksplorasi Setelan Busana Lengkap Tradisional Jawa ("Jelajahi Busana")
class JelajahiBusanaScreen extends StatefulWidget {
  const JelajahiBusanaScreen({
    super.key,
    this.onSelectOutfit,
  });

  final ValueChanged<TraditionalOutfit>? onSelectOutfit;

  @override
  State<JelajahiBusanaScreen> createState() => _JelajahiBusanaScreenState();
}

class _JelajahiBusanaScreenState extends State<JelajahiBusanaScreen> {
  String _selectedCategory = 'Semua Koleksi';

  static const List<String> _categories = [
    'Semua Koleksi',
    'Koleksi Keraton Kasunanan',
    'Koleksi Pengantin Adiluhung',
    'Koleksi Priyayi & Intelektual',
    'Koleksi Priyayi & Formal',
    'Koleksi Keseharian Rakyat',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOutfits = _selectedCategory == 'Semua Koleksi'
        ? JavaneseClothingData.curatedOutfits
        : JavaneseClothingData.curatedOutfits
            .where((o) => o.collectionCategory == _selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFE4C590), size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            const Text(
              'Jelajahi Busana Tradisi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFAF6F0),
              ),
            ),
            Text(
              'ꦲꦤ꧀ꦝꦂꦥꦱꦺꦴꦮꦤ꧀ꦧꦸꦱꦤꦗꦮ',
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
            // Kategori Koleksi Horisontal Pills
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: const Color(0x3318130F),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(cat),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF14100D) : const Color(0xFFA89989),
                      ),
                      selectedColor: const Color(0xFFE4C590),
                      backgroundColor: const Color(0xFF221A14),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFE4C590) : const Color(0x33E4C590),
                        width: 0.8,
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Daftar Setelan Busana Kurasi
          Expanded(
            child: JavaraPullRefresh(
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                await Future.delayed(const Duration(milliseconds: 700));
                if (mounted) setState(() {});
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: filteredOutfits.length,
                separatorBuilder: (context, index) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final outfit = filteredOutfits[index];
                  return _OutfitCard(
                    outfit: outfit,
                    onApply: () {
                      if (widget.onSelectOutfit != null) {
                        widget.onSelectOutfit!(outfit);
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => JavaneseWardrobeScreen(initialOutfit: outfit),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({
    required this.outfit,
    required this.onApply,
  });

  final TraditionalOutfit outfit;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final head = JavaneseClothingData.getItemById(outfit.headwearId);
    final upper = JavaneseClothingData.getItemById(outfit.upperBodyId);
    final lower = JavaneseClothingData.getItemById(outfit.lowerBodyId);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1712),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x44E4C590), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Atas Kartu: Kategori & Era
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF261C15),
              borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0x33E4C590),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0x55E4C590), width: 0.8),
                      ),
                      child: Text(
                        outfit.collectionCategory.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE4C590),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      outfit.gender.label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFA89989),
                      ),
                    ),
                  ],
                ),
                Text(
                  outfit.era,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC79B3A),
                  ),
                ),
              ],
            ),
          ),

          // Badan Utama: Judul & Aksara Jawa
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        outfit.title,
                        style: JText.serif(
                          17,
                          weight: FontWeight.w700,
                          color: const Color(0xFFFAF6F0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      outfit.javaneseScript,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE4C590),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  outfit.summary,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFC4B6A6),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),

                // Komponen Pakaian (Component Breakdown)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16120E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x22E4C590), width: 0.8),
                  ),
                  child: Column(
                    children: [
                      _buildComponentRow(context, Icons.face_rounded, 'Penutup Kepala', head),
                      const Divider(color: Color(0x1AE4C590), height: 10),
                      _buildComponentRow(context, Icons.checkroom_rounded, 'Atasan', upper),
                      const Divider(color: Color(0x1AE4C590), height: 10),
                      _buildComponentRow(context, Icons.layers_rounded, 'Bawahan', lower),
                      if (outfit.accessoryIds.isNotEmpty) ...[
                        const Divider(color: Color(0x1AE4C590), height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              const Icon(Icons.military_tech_rounded, size: 14, color: Color(0xFFE4C590)),
                              const SizedBox(width: 8),
                              const Text(
                                'Ricikan/Aksesoris: ',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFA89989),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${outfit.accessoryIds.length} Pusaka & Ornamen Lengkap',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFAF6F0),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Filosofi Singkat & Rujukan
                Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: Color(0xFFC79B3A), size: 13),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        outfit.historicalSources,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF8E8174),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Tombol Kenakan pada Manekin 3D
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4C590),
                      foregroundColor: const Color(0xFF14100D),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: onApply,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.view_in_ar_rounded, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Kenakan pada Manekin 3D',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
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

  Widget _buildComponentRow(
    BuildContext context,
    IconData icon,
    String label,
    ClothingItem? item,
  ) {
    return InkWell(
      onTap: item != null
          ? () {
              Navigator.of(context).push(
                fadeSlideRoute(ClothingDetailScreen(item: item)),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFFE4C590)),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFA89989),
              ),
            ),
            Expanded(
              child: Text(
                item?.name ?? '-',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFAF6F0),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (item != null)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: Color(0xFF8E8174),
              ),
          ],
        ),
      ),
    );
  }
}
