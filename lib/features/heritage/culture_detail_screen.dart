import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../data/culture_items.dart';
import '../../widgets/photo_box.dart';
import 'cultural_order_sheet.dart';

/// Halaman Detail Warisan Budaya Editorial Mendalam JAVARA.
/// Menampilkan sejarah otentik, filosofi adiluhung, sorotan keistimewaan,
/// panduan lokasi, pemutar narasi audio, dan tombol aksi terintegrasi.
class CultureDetailScreen extends StatefulWidget {
  const CultureDetailScreen({super.key, required this.item, this.onOpenMap});

  final CultureItem item;
  final VoidCallback? onOpenMap;

  @override
  State<CultureDetailScreen> createState() => _CultureDetailScreenState();
}

class _CultureDetailScreenState extends State<CultureDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isBookmarked = false;
  bool _isPlayingNarration = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    HapticFeedback.lightImpact();
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked
              ? '${widget.item.title} disimpan ke Favorit Warisan.'
              : '${widget.item.title} dihapus dari Favorit.',
          style: JText.serif(13, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E2019),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleAudioNarration() {
    HapticFeedback.lightImpact();
    setState(() => _isPlayingNarration = !_isPlayingNarration);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isPlayingNarration
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: JColors.gold,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isPlayingNarration
                    ? 'Memutar audio narasi & gamelan pengiring ${widget.item.title}...'
                    : 'Audio narasi dihentikan.',
                style: JText.serif(13, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1528),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final h = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const Positioned.fill(
              child: JavaraHeritageBackground(
                variant: HeritageBackgroundVariant.explore,
                child: SizedBox.shrink(),
              ),
            ),
            // ===============================================================
            // KONTEN SCROLLABLE DENGAN PARALLAX HERO
            // ===============================================================
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. SLIVER APP BAR DENGAN FOTO MEWAH
                SliverAppBar(
                  expandedHeight: (h * 0.44).clamp(320.0, 420.0),
                  pinned: true,
                  backgroundColor: const Color(0xFF191014),
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Color(0x99191014),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Color(0x99191014),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 20,
                          color: _isBookmarked
                              ? const Color(0xFFFFD700)
                              : Colors.white,
                        ),
                      ),
                      onPressed: _toggleBookmark,
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        AssetPhoto(file: item.image, radius: 0),
                        // Gradasi pencahayaan dusk sinematik
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x66000000),
                                Colors.transparent,
                                Color(0x88191014),
                                Color(0xFF191014),
                              ],
                              stops: [0.0, 0.35, 0.75, 1.0],
                            ),
                          ),
                        ),
                        // Badge Tag di atas gambar
                        Positioned(
                          bottom: 24,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.tag.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xD0C79835),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.tag,
                                    style: JText.serif(
                                      10,
                                      weight: FontWeight.w800,
                                      color: const Color(0xFF191014),
                                    ).copyWith(letterSpacing: 1.1),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                item.title,
                                style: JText.serif(
                                  28,
                                  weight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: Color(0xFFFFDF9E),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.regency.isNotEmpty
                                        ? item.regency
                                        : item.meta,
                                    style: JText.serif(
                                      12.5,
                                      color: const Color(0xFFFFDF9E),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. KONTEN EDITORIAL & TAB PENELUSURAN
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAF5ED),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- PEMUTAR AUDIO NARASI GESTUR SUARA JAWA ---
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF241829),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0x66DFB76C),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _toggleAudioNarration,
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDFB76C),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isPlayingNarration
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: const Color(0xFF241829),
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Narasi Suara Jawa & Gamelan',
                                      style: JText.serif(
                                        13,
                                        weight: FontWeight.w700,
                                        color: const Color(0xFFFFDF9E),
                                      ),
                                    ),
                                    Text(
                                      _isPlayingNarration
                                          ? 'Sedang memutar lantunan kisah...'
                                          : 'Dengarkan pembacaan naskah budaya',
                                      style: JText.serif(
                                        11.5,
                                        color: const Color(0xFFC7B7A6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isPlayingNarration)
                                Row(
                                  children: List.generate(4, (i) {
                                    return Container(
                                      margin: const EdgeInsets.only(left: 3),
                                      width: 3,
                                      height: 12.0 + (i % 2 == 0 ? 8 : -4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD700),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    );
                                  }),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- TAB BAR EDITORIAL ---
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFE6D6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: const Color(0xFF3A261D),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelColor: const Color(0xFFFFDF9E),
                            unselectedLabelColor: const Color(0xFF6E5B49),
                            labelStyle: JText.serif(
                              12,
                              weight: FontWeight.w700,
                            ),
                            unselectedLabelStyle: JText.serif(
                              12,
                              weight: FontWeight.w500,
                            ),
                            tabs: const [
                              Tab(text: 'Sejarah & Filosofi'),
                              Tab(text: 'Sorotan Luhur'),
                              Tab(text: 'Lokasi & Panduan'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- ISI TAB ---
                        AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, _) {
                            final idx = _tabController.index;
                            if (idx == 0) return _buildSejarahTab(item);
                            if (idx == 1) return _buildSorotanTab(item);
                            return _buildLokasiTab(item);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ===============================================================
            // BOTTOM STICKY BAR: ORDER / VISIT BUTTON
            // ===============================================================
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  MediaQuery.of(context).padding.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5ED),
                  border: const Border(
                    top: BorderSide(color: Color(0xFFE2D4BE), width: 1.0),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (item.price != null && item.price!.startsWith('Rp'))
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Harga Karya',
                              style: JText.serif(10.5, color: JColors.muted),
                            ),
                            Text(
                              item.price!,
                              style: JText.serif(
                                18,
                                weight: FontWeight.w800,
                                color: JColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE4BC6C),
                              Color(0xFFC79835),
                              Color(0xFF8C5D17),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x44DFB76C),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => CulturalOrderSheet(item: item),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: Color(0xFF241829),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.price != null &&
                                        item.price!.startsWith('Rp')
                                    ? 'Pesan Karya Mpu'
                                    : 'Akses Panduan Lengkap',
                                style: JText.serif(
                                  14.5,
                                  weight: FontWeight.w700,
                                  color: const Color(0xFF241829),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildSejarahTab(CultureItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sekilas Warisan',
          style: JText.serif(17, weight: FontWeight.w700, color: JColors.ink),
        ),
        const SizedBox(height: 8),
        Text(
          item.description,
          style: JText.serif(14, height: 1.6, color: const Color(0xFF4A382A)),
        ),
        const SizedBox(height: 20),
        if (item.history.isNotEmpty) ...[
          Text(
            'Latar Belakang Sejarah',
            style: JText.serif(17, weight: FontWeight.w700, color: JColors.ink),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EBDE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2D4BE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_stories_rounded,
                  color: Color(0xFFC79835),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.history,
                    style: JText.serif(
                      13.5,
                      height: 1.5,
                      color: const Color(0xFF5A4432),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSorotanTab(CultureItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keistimewaan & Karakteristik Kunci',
          style: JText.serif(17, weight: FontWeight.w700, color: JColors.ink),
        ),
        const SizedBox(height: 12),
        if (item.highlights.isEmpty)
          Text(
            'Belum ada sorotan khusus.',
            style: JText.serif(13, color: JColors.muted),
          )
        else
          for (int i = 0; i < item.highlights.length; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEADBCA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEADBCA),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: JText.serif(
                        12,
                        weight: FontWeight.w800,
                        color: JColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.highlights[i],
                      style: JText.serif(13.5, height: 1.4, color: JColors.ink),
                    ),
                  ),
                ],
              ),
            ),
          ],
      ],
    );
  }

  Widget _buildLokasiTab(CultureItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Lokasi & Sentra',
          style: JText.serif(17, weight: FontWeight.w700, color: JColors.ink),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEADBCA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.place_rounded,
                    color: Color(0xFFB5603A),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.location,
                      style: JText.serif(
                        13.5,
                        weight: FontWeight.w600,
                        color: JColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFEADBCA), height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: JColors.muted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Waktu Berkunjung Terbaik: 07.00 - 17.00 WIB',
                    style: JText.serif(12.5, color: const Color(0xFF6E5B49)),
                  ),
                ],
              ),
              if (widget.onOpenMap != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onOpenMap!();
                    },
                    icon: const Icon(
                      Icons.map_rounded,
                      size: 18,
                      color: JColors.button,
                    ),
                    label: Text(
                      'Buka di Peta Budaya Jawa Tengah',
                      style: JText.serif(
                        13,
                        weight: FontWeight.w700,
                        color: JColors.button,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: JColors.button, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
