import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/purchase_search_helper.dart';
import '../../../core/theme.dart';
import '../../../core/transitions.dart';
import '../../../services/saved_garments_service.dart';
import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';

/// Screen 03 — Detail Pakaian (Halaman Ensiklopedia Busana Adat Jawa Tengah)
class ClothingDetailScreen extends StatefulWidget {
  const ClothingDetailScreen({
    super.key,
    required this.item,
  });

  final ClothingItem item;

  @override
  State<ClothingDetailScreen> createState() => _ClothingDetailScreenState();
}

class _ClothingDetailScreenState extends State<ClothingDetailScreen> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _isBookmarked = SavedGarmentsService.instance.isSaved(widget.item.id);
    SavedGarmentsService.instance.savedItemIdsNotifier.addListener(_onSavedChanged);
  }

  void _onSavedChanged() {
    if (!mounted) return;
    setState(() {
      _isBookmarked = SavedGarmentsService.instance.isSaved(widget.item.id);
    });
  }

  @override
  void dispose() {
    SavedGarmentsService.instance.savedItemIdsNotifier.removeListener(_onSavedChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: JBackground(
        variant: HeritageBackgroundVariant.wardrobe,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
          // 1. EDITORIAL SLIVER APP BAR
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: const Color(0xFF181310),
            elevation: 0,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xB3181310),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x33E4C590),
                      width: 0.8,
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFFE4C590),
                      size: 18,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xB3181310),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0x33E4C590),
                        width: 0.8,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: _isBookmarked ? 'Hapus dari Wardrobe' : 'Simpan ke Wardrobe',
                      icon: Icon(
                        _isBookmarked
                            ? Icons.bookmark_added_rounded
                            : Icons.bookmark_border_rounded,
                        color: const Color(0xFFE4C590),
                        size: 20,
                      ),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final isSaved = await SavedGarmentsService.instance.toggleSave(item.id);
                        if (!mounted) return;
                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          SnackBar(
                            duration: const Duration(milliseconds: 1400),
                            backgroundColor: const Color(0xFF241A14),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFFE4C590),
                                width: 1,
                              ),
                            ),
                            content: Text(
                              isSaved
                                  ? '${item.name} disimpan ke Wardrobe'
                                  : '${item.name} dihapus dari Wardrobe',
                              style: const TextStyle(
                                color: Color(0xFFFAF6F0),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.category == ClothingCategory.lowerBody &&
                      item.assetImagePath != null &&
                      item.assetImagePath!.isNotEmpty) ...[
                    // Foto Kain Batik Penuh di Header untuk Busana Bawahan / Jarik
                    Positioned.fill(
                      child: Hero(
                        tag: 'garment_${item.id}',
                        child: Image.asset(
                          item.assetImagePath!,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, _, _) => Container(
                            color: item.primaryColor,
                            child: Center(
                              child: Icon(
                                item.category.icon,
                                size: 80,
                                color: item.accentColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Scrim Atas Tipis agar Tombol Kembali & Bookmark Tetap Kontras
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 110,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xAA14100D),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Latar Belakang Gradasi Hangat Studio
                    Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.2),
                          radius: 0.9,
                          colors: [
                            item.primaryColor.withValues(alpha: 0.65),
                            const Color(0xFF14100D),
                          ],
                        ),
                      ),
                    ),

                    // Pola Geometris Tenun Halus Melayang
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.08,
                        child: CustomPaint(
                          painter: _BatikPatternBackdropPainter(
                            color: item.accentColor,
                          ),
                        ),
                      ),
                    ),

                    // Showcase Siluet Busana Tengah (Foto Autentik / Ikon)
                    Center(
                      child: Hero(
                        tag: 'garment_${item.id}',
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1C1612),
                            border: Border.all(
                              color: item.accentColor.withValues(alpha: 0.6),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: item.assetImagePath != null &&
                                    item.assetImagePath!.isNotEmpty
                                ? Image.asset(
                                    item.assetImagePath!,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                    errorBuilder: (_, _, _) => Center(
                                      child: Icon(
                                        item.category.icon,
                                        size: 80,
                                        color: item.accentColor,
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      item.category.icon,
                                      size: 80,
                                      color: item.accentColor,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Bayangan Bawah
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 90,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xFF14100D),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. KONTEN DETAIL UTAMA
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label Kategori & Asal Wilayah
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF261D17),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE4C590).withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          item.category.label,
                          style: const TextStyle(
                            color: Color(0xFFE4C590),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1712),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: Color(0xFFC7B7A6),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.region.title,
                                style: const TextStyle(
                                  color: Color(0xFFC7B7A6),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Aksara Jawa
                  Text(
                    item.javaneseScript,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16,
                      color: Color(0xFFDFC08E),
                      letterSpacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Nama Busana
                  Text(
                    item.name,
                    style: JText.serif(
                      24,
                      weight: FontWeight.w800,
                      color: const Color(0xFFFAF6F0),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Periode Era Sejarah
                  Text(
                    'Periode: ${item.period}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFB09F8F),
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // KOTAK KONTEKS SOSIAL & TATA BUSANA
                  _buildSectionCard(
                    title: 'Konteks Sosial & Upacara Adat',
                    subtitle: item.socialContext.label,
                    icon: Icons.account_balance_rounded,
                    content: item.socialContext.description,
                  ),

                  const SizedBox(height: 16),

                  // KOTAK FILOSOFI & MAKNA ADILUHUNG
                  _buildSectionCard(
                    title: 'Filosofi & Makna Simbolis',
                    subtitle: 'Makna Luhur di Balik Rancangan',
                    icon: Icons.auto_awesome_rounded,
                    content: item.philosophicalMeaning,
                    accent: true,
                  ),

                  const SizedBox(height: 16),

                  // KOTAK BAHAN & KONSTRUKSI TEKSTIL
                  _buildSectionCard(
                    title: 'Bahan & Teknik Konstruksi',
                    subtitle: item.textureMotif,
                    icon: Icons.architecture_rounded,
                    content:
                        'Bahan: ${item.material}\n\nKonstruksi & Pola: ${item.cuttingAndConstruction}',
                  ),

                  const SizedBox(height: 16),

                  // PALET WARNA TRADISI & SIMBOLIK ALAM
                  _buildColorPaletteSection(item),

                  const SizedBox(height: 16),

                  // KOTAK CATATAN SEJARAH & ARSIP
                  _buildSectionCard(
                    title: 'Catatan Sejarah & Asal-Usul',
                    subtitle: 'Dokumentasi Kasunanan & Kadipaten',
                    icon: Icons.history_edu_rounded,
                    content: item.historicalNotes,
                  ),

                  const SizedBox(height: 16),

                  // KOTAK RUJUKAN & SUMBER RESMI
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1512),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0x33E4C590),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 16,
                              color: Color(0xFFDFC08E),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Sumber & Rujukan Sejarah',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFAF6F0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.references,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB3A394),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // BUSANA TERKAIT & KESELARASAN SEJARAH
                  _buildCompatibleGarmentsSection(context, item),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF14100D),
        border: Border(
          top: BorderSide(color: Color(0x33E4C590), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            launchPurchaseSearch(item.name);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3A261D),
            foregroundColor: const Color(0xFFFFDF9E),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Cari Tempat Membeli',
                  style: JText.serif(
                    14.5,
                    weight: FontWeight.w700,
                    color: const Color(0xFFFFDF9E),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.north_east,
                  color: Color(0xFFFFDF9E),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String content,
    bool accent = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent ? const Color(0xFF221A14) : const Color(0xFF1A1410),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent
              ? const Color(0x66E4C590)
              : const Color(0x2EE4C590),
          width: accent ? 1.2 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2219),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: const Color(0xFFE4C590),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFAF6F0),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB09F8F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFDCD2C5),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibleGarmentsSection(
    BuildContext context,
    ClothingItem currentItem,
  ) {
    final compatibleItems = [
      ...JavaneseClothingData.headwearItems,
      ...JavaneseClothingData.upperBodyItems,
      ...JavaneseClothingData.lowerBodyItems,
      ...JavaneseClothingData.accessoryItems,
    ]
        .where((i) => i.id != currentItem.id && i.isCompatibleWith(currentItem))
        .take(4)
        .toList();

    if (compatibleItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keselarasan Busana Pendamping',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFFFAF6F0),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Padanan busana yang selaras menurut tatakrama tradisi',
          style: TextStyle(
            fontSize: 11.5,
            color: Color(0xFFA69383),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 164,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: compatibleItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final other = compatibleItems[index];
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    fadeSlideRoute(ClothingDetailScreen(item: other)),
                  );
                },
                child: Container(
                  width: 170,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1813),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0x33E4C590),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(other.category.icon, size: 16, color: const Color(0xFFE4C590)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              other.category.label.split('(').first.trim(),
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFFB09F8F),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        other.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFAF6F0),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        other.region.title,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8E7D6F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorPaletteSection(ClothingItem item) {
    if (item.colorPalette.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1512),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x33E4C590),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.palette_rounded,
                size: 16,
                color: Color(0xFFDFC08E),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Palet Warna Tradisi & Makna Alam',
                  style: JText.serif(
                    13,
                    weight: FontWeight.w700,
                    color: const Color(0xFFFAF6F0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: item.colorPalette.map((color) {
              final hex = color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF261D17),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x33DFB76C), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '#$hex',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE4C590),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BatikPatternBackdropPainter extends CustomPainter {
  const _BatikPatternBackdropPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 8, paint);
        canvas.drawCircle(Offset(x, y), 14, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
