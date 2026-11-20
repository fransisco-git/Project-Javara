import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../data/culture_items.dart';
import '../../widgets/photo_box.dart';
import '../heritage/aksara_jawa_screen.dart';
import '../heritage/culture_detail_screen.dart';
import '../heritage/culture_passport_screen.dart';
import '../heritage/sound_of_java_screen.dart';
import '../../services/java_music_service.dart';
import 'explore_data.dart';
import 'explore_models.dart';
import 'interactive_map_widget.dart';
import 'jelajah_budaya_screen.dart';
import 'quiz_screen.dart';
import 'story_detail_screen.dart';
import '../fashion/screens/batik_motif_gallery_screen.dart';
import '../fashion/screens/javanese_fashion_map_screen.dart';
import '../fashion/screens/jelajahi_busana_screen.dart';
import '../fashion/screens/clothing_catalog_screen.dart';
import '../../widgets/interactive_feedback.dart';

/// Tab Jelajah Jawa - Implementasi asli dan presisi dari Figma Page 2 (Frame '175:613' & '175:995').
/// Mengintegrasikan Peta Budaya Jawa Tengah Interaktif, Rute Ekspedisi Budaya, dan Khasanah Karuhun.
class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key, required this.onOpenTab});

  /// Pindah ke tab lain (0 Home, 1 Jelajah, 2 Belanja, 3 Favorit, 4 Profil).
  final ValueChanged<int> onOpenTab;

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  String _selectedRegionId = 'jateng'; // Default Jawa Tengah sesuai Figma
  String? _selectedRegencyId; // Filter Kabupaten/Kota Jawa Tengah
  bool _showInteractiveMap = true; // Toggle peta interaktif

  @override
  Widget build(BuildContext context) {
    final selectedRegion = regionsList.firstWhere(
      (r) => r.id == _selectedRegionId,
      orElse: () => regionsList.first,
    );

    // Filter item berdasarkan daerah dan kabupaten (jika dipilih)
    final filteredItems = exploreItemsList.where((item) {
      if (item.regionId != _selectedRegionId) return false;
      if (_selectedRegionId == 'jateng' && _selectedRegencyId != null) {
        return item.regencyId == _selectedRegencyId;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: JavaraPullRefresh(
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                await Future.delayed(const Duration(milliseconds: 700));
                if (mounted) setState(() {});
              },
              child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
              children: [
                // 1. TOP APP BAR (Back, Title "Jelajah Jawa", Bag Icon)
                _buildTopBar(),

                const SizedBox(height: 14),

                // BAR SUARA JAWA (SWARA NUSANTARA AMBIENT)
                _buildSoundscapeFloatingBar(),

                const SizedBox(height: 12),

                // BAR KHASANAH BUSANA & WASTRA ADAT JAWA TENGAH
                _buildFashionDiscoveryBar(),

                // 2. HERO EDITORIAL HEADLINE (Figma Page 2)
                Text(
                  'Pilih daerah, temukan warisannya.',
                  style: JText.serif(
                    30,
                    weight: FontWeight.w700,
                    color: JColors.ink,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Setiap daerah memiliki busana adat, wastra batik, dan filosofi adiluhung sendiri',
                  style: JText.serif(
                    14.5,
                    color: const Color(0xFF6E5B49),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // 3. SEKSI "Pilih daerah" (Jawa Tengah & Yogyakarta)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih daerah',
                      style: JText.serif(
                        19,
                        weight: FontWeight.w700,
                        color: JColors.ink,
                      ),
                    ),
                    if (_selectedRegionId == 'jateng')
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showInteractiveMap = !_showInteractiveMap;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _showInteractiveMap
                                    ? Icons.map_rounded
                                    : Icons.map_outlined,
                                size: 16,
                                color: JColors.terracotta,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _showInteractiveMap
                                    ? 'Sembunyikan Peta'
                                    : 'Buka Peta Budaya',
                                style: JText.serif(
                                  12,
                                  weight: FontWeight.w600,
                                  color: JColors.terracotta,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Kartu Daerah Utama
                ...regionsList.map((region) {
                  final isSelected = region.id == _selectedRegionId;
                  return _buildRegionCard(region, isSelected);
                }),

                // 4. PETA BUDAYA JAWA TENGAH (Jika Jawa Tengah aktif & toggle ON)
                if (_selectedRegionId == 'jateng' && _showInteractiveMap) ...[
                  const SizedBox(height: 16),
                  InteractiveCentralJavaMap(
                    regencies: centralJavaRegencies,
                    selectedRegencyId: _selectedRegencyId,
                    onSelectRegency: (reg) {
                      setState(() {
                        _selectedRegencyId = reg?.id;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // 4.5. RUTE PERJALANAN BUDAYA TEMATIK KURASI JAVARA
                _buildCuratedRoutesSection(),

                const SizedBox(height: 20),

                // 4.6. RIBBON AKSES PASPOR & AKSARA JAWA
                _buildCulturalToolsRibbon(),

                const SizedBox(height: 22),

                // 5. BANNER KUIS BUDAYA (Hubungan erat: Belajar & Menguji Pemahaman)
                _buildQuizBanner(),

                const SizedBox(height: 12),

                // BANNER JELAJAH BUDAYA (Majalah Editorial)
                _buildEditorialBanner(),

                const SizedBox(height: 24),

                // 6. SEKSI "Dari Jawa Tengah" (atau nama daerah yang dipilih)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dari ${selectedRegion.name}',
                      style: JText.serif(
                        19,
                        weight: FontWeight.w700,
                        color: JColors.ink,
                      ),
                    ),
                    if (_selectedRegencyId != null)
                      Text(
                        '(${centralJavaRegencies.firstWhere((r) => r.id == _selectedRegencyId).name})',
                        style: JText.serif(
                          13,
                          color: JColors.terracotta,
                          weight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // 7. DAFTAR ITEM DARI DAERAH TERPILIH
                if (filteredItems.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEADBCA)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 36,
                          color: JColors.muted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada item untuk filter ini.',
                          style: JText.serif(13.5, color: JColors.muted),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => _selectedRegencyId = null),
                          child: Text(
                            'Tampilkan Semua Warisan Jawa Tengah',
                            style: JText.serif(12.5, color: JColors.terracotta),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredItems.map(_buildExploreItemCard),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  /// Top Bar: Back (ke tab Home), Title "Jelajah Jawa", Shopping Bag (ke tab Belanja)
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                widget.onOpenTab(0);
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: JColors.ink,
            tooltip: 'Kembali ke Beranda',
          ),
          Text(
            'Jelajah Jawa',
            style: JText.serif(
              17.5,
              weight: FontWeight.w700,
              color: JColors.ink,
            ),
          ),
          IconButton(
            onPressed: () => widget.onOpenTab(2), // Ke Tab Belanja
            icon: const Icon(Icons.shopping_bag_outlined, size: 22),
            color: JColors.ink,
            tooltip: 'Katalog Belanja',
          ),
        ],
      ),
    );
  }

  /// Kartu Pilihan Daerah (Jawa Tengah & Yogyakarta)
  Widget _buildRegionCard(RegionInfo region, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRegionId = region.id;
            _selectedRegencyId = null;
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEADBCA)
                : const Color(0xFFFFFDF9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFCDB292)
                  : const Color(0xFFEFE2CE),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0x1E3A261D)
                    : const Color(0x0A3A261D),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: AssetPhoto(file: region.image, width: 58, height: 58),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      region.name,
                      style: JText.serif(
                        16.5,
                        weight: FontWeight.w700,
                        color: JColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      region.tagline,
                      style: JText.serif(11.5, color: const Color(0xFF756250)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isSelected ? JColors.button : const Color(0xFFA59280),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Floating Bar Pemutar Musik Jawa & Soundscape (DJ Jawa, Pop Jawa, & Gamelan)
  Widget _buildSoundscapeFloatingBar() {
    final music = JavaMusicService.instance;

    return ListenableBuilder(
      listenable: music,
      builder: (context, _) {
        final current = music.currentTrack;
        final isPlaying = music.isPlaying;

        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF261427), Color(0xFF381F3A)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFDFB76C).withValues(alpha: 0.5),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  music.togglePlay();
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFDFB76C),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x28000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: const Color(0xFF130B17),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(musicPlayerRoute(const SoundOfJavaScreen()));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: const Color(0x33DFB76C),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              current.category,
                              style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFFDF9E),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              current.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${current.artist} · ${music.positionFormatted} / ${music.durationFormatted}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFC7B7A6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context)
                      .push(musicPlayerRoute(const SoundOfJavaScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDFB76C),
                  foregroundColor: const Color(0xFF130B17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  elevation: 0,
                ),
                icon: const Icon(Icons.headphones_rounded, size: 14),
                label: const Text(
                  'Putar Lagu',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Bar Akses Cepat Khasanah Busana & Wastra Adat Jawa Tengah
  Widget _buildFashionDiscoveryBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF261A12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDFB76C).withValues(alpha: 0.6),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.checkroom_rounded,
                size: 15,
                color: Color(0xFFE4C590),
              ),
              const SizedBox(width: 8),
              Text(
                'MUSEUM & KHASANAH BUSANA JAWA TENGAH',
                style: JText.serif(
                  10,
                  weight: FontWeight.w700,
                  color: const Color(0xFFFFDF9E),
                ).copyWith(letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FashionPillButton(
                  title: 'Katalog Busana',
                  icon: Icons.menu_book_rounded,
                  onTap: () => Navigator.of(context).push(
                    fadeSlideRoute(const ClothingCatalogScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FashionPillButton(
                  title: 'Setelan Adat',
                  icon: Icons.auto_awesome_rounded,
                  onTap: () => Navigator.of(context).push(
                    fadeSlideRoute(const JelajahiBusanaScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FashionPillButton(
                  title: 'Peta Busana',
                  icon: Icons.map_rounded,
                  onTap: () => Navigator.of(context).push(
                    fadeSlideRoute(const JavaneseFashionMapScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FashionPillButton(
                  title: 'Galeri Batik',
                  icon: Icons.layers_rounded,
                  onTap: () => Navigator.of(context).push(
                    fadeSlideRoute(const BatikMotifGalleryScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Seksi Rute Perjalanan Budaya Tematik Kurasi JAVARA
  Widget _buildCuratedRoutesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.route_rounded,
                  size: 18,
                  color: JColors.button,
                ),
                const SizedBox(width: 6),
                Text(
                  'Rute Ekspedisi Budaya',
                  style: JText.serif(
                    18,
                    weight: FontWeight.w700,
                    color: JColors.ink,
                  ),
                ),
              ],
            ),
            Text(
              '5 Jalur Tematik',
              style: JText.serif(
                12,
                color: JColors.terracotta,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Jelajahi kearifan lokal Jawa Tengah melalui jalur tematik yang saling terhubung.',
          style: JText.serif(12, color: const Color(0xFF6E5B49)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 165,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: curatedCulturalRoutes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, idx) {
              final route = curatedCulturalRoutes[idx];
              return InkWell(
                onTap: () => _showRouteDetailModal(route),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDEC5A4)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x103A261D),
                        blurRadius: 10,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: route.badgeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              route.theme.toUpperCase(),
                              style: JText.serif(
                                8.5,
                                weight: FontWeight.w700,
                                color: route.badgeColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: JColors.button,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        route.title,
                        style: JText.serif(
                          14,
                          weight: FontWeight.w700,
                          color: JColors.ink,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        route.duration,
                        style: JText.serif(11, color: JColors.muted),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_rounded,
                            size: 12,
                            color: JColors.terracotta,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              route.regencyNames.join(' ➔ '),
                              style: JText.serif(
                                10.5,
                                weight: FontWeight.w600,
                                color: JColors.button,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
      ],
    );
  }

  /// Modal Detail Rute Budaya
  void _showRouteDetailModal(CuratedCulturalRoute route) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (_, scrollCtl) => Container(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          decoration: const BoxDecoration(
            color: Color(0xFFFBF7F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollCtl,
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
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: route.badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  route.theme.toUpperCase(),
                  style: JText.serif(
                    10.5,
                    weight: FontWeight.w700,
                    color: route.badgeColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                route.title,
                style: JText.serif(
                  22,
                  weight: FontWeight.w700,
                  color: JColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: JColors.terracotta,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    route.duration,
                    style: JText.serif(
                      12.5,
                      color: JColors.muted,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                route.summary,
                style: JText.serif(
                  14,
                  color: const Color(0xFF4A3828),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tahapan Perjalanan & Pengalaman Kunci:',
                style: JText.serif(
                  15,
                  weight: FontWeight.w700,
                  color: JColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < route.keyStops.length; i++) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEADBCA)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: JColors.gold,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: JColors.night,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          route.keyStops[i],
                          style: JText.serif(
                            12.5,
                            color: JColors.ink,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    final firstRegName = route.regencyNames.first
                        .split(' ')
                        .first
                        .toLowerCase();
                    final match = centralJavaRegencies.where(
                      (r) =>
                          r.name.toLowerCase().contains(firstRegName) ||
                          r.id.contains(firstRegName),
                    );
                    if (match.isNotEmpty) {
                      setState(() {
                        _selectedRegencyId = match.first.id;
                        _showInteractiveMap = true;
                      });
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✓ Rute diaktifkan: ${route.title}. Titik peta disesuaikan!',
                        ),
                        backgroundColor: JColors.button,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JColors.button,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(
                    Icons.map_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Telusuri Rute Ini di Peta',
                    style: JText.serif(
                      13.5,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ribbon Akses Fitur Khasanah Budaya (Paspor & Aksara)
  Widget _buildCulturalToolsRibbon() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context)
                  .push(fadeSlideRoute(const CulturePassportScreen()));
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2D4BE)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: JColors.gold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.badge_outlined,
                      color: JColors.button,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paspor Budaya',
                          style: JText.serif(
                            13,
                            weight: FontWeight.w700,
                            color: JColors.ink,
                          ),
                        ),
                        Text(
                          '35 Cap Wilayah',
                          style: JText.serif(10.5, color: JColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context)
                  .push(fadeSlideRoute(const AksaraJawaScreen()));
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2D4BE)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: JColors.terracotta.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: JColors.terracotta,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aksara Jawa',
                          style: JText.serif(
                            13,
                            weight: FontWeight.w700,
                            color: JColors.ink,
                          ),
                        ),
                        Text(
                          'Sanggar Hanacaraka',
                          style: JText.serif(10.5, color: JColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Banner Kuis Budaya Jawa (10 Soal Interaktif)
  Widget _buildQuizBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A261D), Color(0xFF5A3A25)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: JColors.gold.withValues(alpha: 0.22),
              border: Border.all(color: JColors.gold, width: 1.2),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: JColors.gold,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kuis Budaya Jawa',
                  style: JText.serif(
                    16,
                    weight: FontWeight.w700,
                    color: JColors.cream,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '10 soal asyik • Kumpulkan lencana & XP',
                  style: JText.serif(11.5, color: const Color(0xFFDEC5A4)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const QuizScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: JColors.gold,
              foregroundColor: JColors.night,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
    );
  }

  /// Banner Jelajah Budaya (Majalah Cerita yang Hidup dari Figma Page 2)
  Widget _buildEditorialBanner() {
    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const JelajahBudayaScreen()));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E7D5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDFCCB2), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C3A261D),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: JColors.terracotta.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: JColors.terracotta,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Majalah Jelajah Budaya',
                    style: JText.serif(
                      15.5,
                      weight: FontWeight.w700,
                      color: JColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cerita yang hidup, warisan yang dekat',
                    style: JText.serif(11.5, color: const Color(0xFF6B5845)),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: JColors.button,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Kartu Item Budaya/Produk/Makanan/Event (Sesuai 'Dari Jawa Tengah' di Figma Page 2)
  Widget _buildExploreItemCard(ExploreItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (item.isStory) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => StoryDetailScreen(item: item)),
            );
          } else if (item.price != null) {
            final allItems = [...popularItems, ...pickedItems];
            final matching = allItems.where(
              (c) =>
                  c.id == item.id ||
                  c.title.toLowerCase() == item.title.toLowerCase(),
            );
            final cultureItem = matching.isNotEmpty
                ? matching.first
                : CultureItem(
                    id: item.id,
                    title: item.title,
                    meta: item.subtitle,
                    image: item.image,
                    tag: item.category.label,
                    price: item.price,
                    actionLabel: 'Pesan Sekarang',
                    description:
                        item.storyIntro != null && item.storyIntro!.isNotEmpty
                        ? item.storyIntro!
                        : item.subtitle,
                    history: item.storyParagraphs.join('\n\n'),
                    location: 'Jawa Tengah',
                    category: item.category.label,
                  );
            Navigator.of(context).push(
              fadeSlideRoute(
                CultureDetailScreen(
                  item: cultureItem,
                  onOpenMap: () => widget.onOpenTab(1),
                ),
              ),
            );
          } else {
            _showEventDetailModal(context, item);
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEFE2CE)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C3A261D),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: AssetPhoto(file: item.image, width: 58, height: 58),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.label,
                      style: JText.serif(
                        9.5,
                        weight: FontWeight.w700,
                        color: item.category.badgeColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      style: JText.serif(
                        15,
                        weight: FontWeight.w700,
                        color: JColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: JText.serif(
                        12,
                        color: item.isStory
                            ? JColors.button
                            : const Color(0xFF756250),
                        weight: item.isStory
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFA59280),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetailModal(BuildContext context, ExploreItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFF9F5EE),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
            const SizedBox(height: 18),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: AssetPhoto(file: item.image, width: 56, height: 56),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.category.badgeColor.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category.label,
                          style: JText.serif(
                            9,
                            weight: FontWeight.w700,
                            color: item.category.badgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.title,
                        style: JText.serif(
                          16,
                          weight: FontWeight.w700,
                          color: JColors.ink,
                        ),
                      ),
                      Text(
                        item.eventDate ?? item.subtitle,
                        style: JText.serif(12, color: JColors.muted),
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
                border: Border.all(color: const Color(0xFFE9DEC8)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Waktu & Lokasi',
                        style: JText.serif(12, color: JColors.muted),
                      ),
                      Text(
                        item.eventDate ?? 'Jawa Tengah',
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Akses Masuk',
                        style: JText.serif(12, color: JColors.muted),
                      ),
                      Text(
                        'Terbuka untuk Umum / Donasi Sukarela',
                        style: JText.serif(
                          12.5,
                          weight: FontWeight.w600,
                          color: JColors.success,
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
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✓ Agenda ${item.title} tersimpan ke pengingat budaya Anda.',
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
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.bookmark_added_outlined, size: 18),
                label: Text(
                  'Simpan ke Agenda Saya',
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
  }
}

class _FashionPillButton extends StatelessWidget {
  const _FashionPillButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B120C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x33DFB76C), width: 0.8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: const Color(0xFFE4C590)),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFAF6F0),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
