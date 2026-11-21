import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../data/culture_items.dart';
import '../../widgets/motion.dart';
import '../../widgets/photo_box.dart';
import '../heritage/aksara_jawa_screen.dart';
import '../heritage/cultural_order_sheet.dart';
import '../heritage/culture_detail_screen.dart';
import '../heritage/culture_passport_screen.dart';
import '../heritage/hidden_heritage_screen.dart';
import '../heritage/time_travel_screen.dart';
import '../fashion/screens/javanese_wardrobe_screen.dart';
import '../fashion/screens/jelajahi_busana_screen.dart';
import '../fashion/screens/clothing_catalog_screen.dart';
import '../fashion/screens/clothing_detail_screen.dart';
import '../fashion/screens/batik_motif_gallery_screen.dart';
import '../fashion/screens/javanese_fashion_map_screen.dart';
import '../fashion/screens/sinau_busana_screen.dart';
import '../fashion/screens/ai_fashion_studio_screen.dart';
import '../fashion/screens/ai_cultural_assistant_screen.dart';
import '../fashion/data/javanese_clothing_data.dart';
import '../fashion/models/javanese_clothing_models.dart';
import '../../widgets/skeleton_shimmer.dart';
import '../../widgets/interactive_feedback.dart';

/// Halaman Beranda JAVARA - Menampilkan khasanah budaya Jawa Tengah.
/// Menghadirkan model Candi Borobudur 3D fotorealistik (cutout transparan)
/// dengan atmosfer rembulan emas kosmik dan efek dolly zoom "keluar & kedalam" sinematik.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.onOpenTab});

  /// Pindah ke tab lain (0 Home, 1 Jelajah, 2 Belanja, 3 Favorit, 4 Profil).
  final ValueChanged<int> onOpenTab;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _search = TextEditingController();
  final _scrollController = ScrollController();
  final _pointerNotifier = ValueNotifier<Offset>(Offset.zero);
  String _q = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Mensimulasikan pemuatan data khasanah awal yang mulus dan realistis
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _scrollController.dispose();
    _pointerNotifier.dispose();
    super.dispose();
  }

  List<CultureItem> _filter(List<CultureItem> src) {
    if (_q.isEmpty) return src;
    return src
        .where(
          (e) =>
              e.title.toLowerCase().contains(_q) ||
              e.meta.toLowerCase().contains(_q) ||
              e.tag.toLowerCase().contains(_q),
        )
        .toList();
  }

  void _onCategoryTapped(String label) {
    HapticFeedback.lightImpact();
    if (label.contains('Keraton')) {
      Navigator.of(context).push(
        fadeSlideRoute(
          const ClothingCatalogScreen(initialRegion: TraditionRegion.surakarta),
        ),
      );
    } else if (label.contains('Pria')) {
      Navigator.of(context).push(
        fadeSlideRoute(
          const ClothingCatalogScreen(initialGender: GenderTarget.pria),
        ),
      );
    } else if (label.contains('Wanita')) {
      Navigator.of(context).push(
        fadeSlideRoute(
          const ClothingCatalogScreen(initialGender: GenderTarget.wanita),
        ),
      );
    } else if (label.contains('Batik') || label.contains('Jarik')) {
      Navigator.of(context).push(
        fadeSlideRoute(const BatikMotifGalleryScreen()),
      );
    } else {
      Navigator.of(context).push(
        fadeSlideRoute(const ClothingCatalogScreen()),
      );
    }
  }

  void _updatePointer(Offset localPos, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final nx = ((localPos.dx / size.width) - 0.5) * 2.0;
    final ny = ((localPos.dy / size.height) - 0.5) * 2.0;
    _pointerNotifier.value = Offset(nx, ny);
  }

  @override
  Widget build(BuildContext context) {
    final popular = _filter(popularItems);
    final picked = _filter(pickedItems);
    final empty = popular.isEmpty && picked.isEmpty;
    final topPadding = MediaQuery.of(context).padding.top;

    return MouseRegion(
      onHover: (e) =>
          _updatePointer(e.localPosition, MediaQuery.of(context).size),
      child: Listener(
        onPointerMove: (e) =>
            _updatePointer(e.localPosition, MediaQuery.of(context).size),
        child: Stack(
          children: [
            // =====================================================================
            // 1. LATAR BELAKANG 3D JAVARA (REMBULAN EMAS + MODEL 3D CANDI DOLLY ZOOM)
            // =====================================================================
            Positioned.fill(
              child: _Javara3DTempleBackground(
                scrollController: _scrollController,
                pointerNotifier: _pointerNotifier,
              ),
            ),

            // =====================================================================
            // 2. KONTEN EDITORIAL JAVARA DENGAN PANEL OBSIDIAN GLASS & GOLD
            // =====================================================================
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: _isLoading
                        ? Padding(
                            key: const ValueKey('home_skeleton'),
                            padding: EdgeInsets.fromLTRB(0, topPadding + 10, 0, 110),
                            child: const HomeTabSkeletonView(),
                          )
                        : JavaraPullRefresh(
                            key: const ValueKey('home_content'),
                            onRefresh: () async {
                              HapticFeedback.mediumImpact();
                              await Future.delayed(const Duration(milliseconds: 800));
                              if (!context.mounted) return;
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Color(0xFFDFB76C),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Khasanah Jawa Tengah berhasil diselaraskan',
                                          style: JText.serif(
                                            12.5,
                                            color: const Color(0xFFFAF6F0),
                                            weight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF2E2019),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color: Color(0x55DFB76C),
                                        width: 0.8,
                                      ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                            },
                            child: ListView(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 110),
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              children: [
                      // --- HEADER SINEMATIK JAVARA ---
                      AnimatedBuilder(
                        animation: _scrollController,
                        builder: (context, _) {
                          final offset = _scrollController.hasClients
                              ? _scrollController.offset
                              : 0.0;
                          final heroFade = (1.0 - (offset / 340.0)).clamp(
                            0.0,
                            1.0,
                          );
                          final heroScale = (1.0 - (offset / 900.0)).clamp(
                            0.85,
                            1.0,
                          );

                          return Opacity(
                            opacity: heroFade,
                            child: Transform.scale(
                              scale: heroScale,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pill Badge Warisan Busana Adat
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x33DFB76C),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0x66DFB76C),
                                          width: 0.9,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.checkroom_rounded,
                                            size: 13,
                                            color: Color(0xFFDFB76C),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'BUSANA ADAT JAWA TENGAH',
                                            style: JText.serif(
                                              10,
                                              weight: FontWeight.w700,
                                              color: const Color(0xFFFFDF9E),
                                            ).copyWith(letterSpacing: 1.2),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Judul Utama Khasanah Busana Adat
                                    Text(
                                      'Khasanah Busana\nAdat Jawa Tengah',
                                      style: JText.serif(
                                        32,
                                        height: 1.15,
                                        weight: FontWeight.w800,
                                        color: const Color(0xFF382315),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Deskripsi Ringkas & Bernas (Anti-Slop)
                                    Text(
                                      'Eksplorasi keanggunan, filosofi, dan ragam pakaian adat warisan leluhur Jawa Tengah.',
                                      style: JText.serif(
                                        13.5,
                                        color: const Color(0xFF5C4738),
                                        height: 1.4,
                                      ),
                                    ),

                                    const SizedBox(height: 18),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // --- SEARCH BAR OBSIDIAN GLASS ---
                      StaggerIn(
                        index: 1,
                        child: _SearchBar(
                          controller: _search,
                          onChanged: (v) =>
                              setState(() => _q = v.trim().toLowerCase()),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // --- HERO CARD FITUR UTAMA ---
                      if (_q.isEmpty) ...[
                        StaggerIn(
                          index: 2,
                          child: _HeroCard(
                            onStart: () {
                              Navigator.of(context).push(
                                fadeSlideRoute(const JelajahiBusanaScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        StaggerIn(
                          index: 3,
                          child: _Categories(onTap: _onCategoryTapped),
                        ),
                        const SizedBox(height: 20),
                        // --- BANNER UTAMA: MUSEUM BUSANA TRADISIONAL JAWA 3D ---
                        StaggerIn(
                          index: 4,
                          child: _HomeFashion3DBanner(
                            onOpenWardrobe: () => Navigator.of(context)
                                .push(fadeSlideRoute(const JavaneseWardrobeScreen())),
                            onOpenOutfits: () => Navigator.of(context)
                                .push(fadeSlideRoute(const JelajahiBusanaScreen())),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // --- BANNER DUAL AI FASHION STUDIO & ASISTEN BUDAYA ---
                        StaggerIn(
                          index: 5,
                          child: _HomeAiFashionFeaturesBanner(
                            onOpenAiStudio: () => Navigator.of(context).push(
                              fadeSlideRoute(const AiFashionStudioScreen()),
                            ),
                            onOpenAiAssistant: () => Navigator.of(context).push(
                              fadeSlideRoute(const AiCulturalAssistantScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        // --- RIBBON EKSPLORASI KHASANAH JAWA UTAMA ---
                        StaggerIn(
                          index: 6,
                          child: _FeatureDiscoveryRibbon(
                            onTimeTravel: () => Navigator.of(context)
                                .push(fadeSlideRoute(const TimeTravelScreen())),
                            onPassport: () => Navigator.of(context).push(
                              fadeSlideRoute(const CulturePassportScreen()),
                            ),
                            onHiddenHeritage: () => Navigator.of(context).push(
                              fadeSlideRoute(const HiddenHeritageScreen()),
                            ),
                            onAksaraJawa: () => Navigator.of(context)
                                .push(fadeSlideRoute(const AksaraJawaScreen())),
                            onBusana3D: () => Navigator.of(context)
                                .push(fadeSlideRoute(const JavaneseWardrobeScreen())),
                            onJelajahiBusana: () => Navigator.of(context)
                                .push(fadeSlideRoute(const JelajahiBusanaScreen())),
                            onPetaBusana: () => Navigator.of(context)
                                .push(fadeSlideRoute(const JavaneseFashionMapScreen())),
                            onGaleriBatik: () => Navigator.of(context)
                                .push(fadeSlideRoute(const BatikMotifGalleryScreen())),
                            onSinauBusana: () => Navigator.of(context)
                                .push(fadeSlideRoute(const SinauBusanaScreen())),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // --- BUSANA PILIHAN HARI INI (FEATURED OUTFIT OF THE DAY) ---
                        StaggerIn(
                          index: 7,
                          child: _FeaturedOutfitOfTheDayCard(
                            onOpenWardrobe: () => Navigator.of(context)
                                .push(fadeSlideRoute(const JavaneseWardrobeScreen())),
                            onOpenExplore: () => Navigator.of(context)
                                .push(fadeSlideRoute(const JelajahiBusanaScreen())),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // --- RAGAM BUSANA ADAT UNGGULAN JAWA TENGAH CAROUSEL ---
                        StaggerIn(
                          index: 8,
                          child: _FeaturedGarmentsCarousel(
                            onSelectItem: (item) => Navigator.of(context).push(
                              fadeSlideRoute(ClothingDetailScreen(item: item)),
                            ),
                            onSeeAll: () => Navigator.of(context)
                                .push(fadeSlideRoute(const JelajahiBusanaScreen())),
                          ),
                        ),
                        const SizedBox(height: 26),
                      ],

                      if (empty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'Tidak ada hasil untuk "${_search.text.trim()}"',
                              style: JText.serif(
                                14,
                                color: const Color(0xFFB3A394),
                              ),
                            ),
                          ),
                        ),

                      // --- DAFTAR PILIHAN POPULER ---
                      if (popular.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'Warisan Populer',
                          onSeeAll: () => widget.onOpenTab(1),
                        ),
                        const SizedBox(height: 14),
                        _PopularGrid(
                          items: popular,
                          onTap: (item) => Navigator.of(context).push(
                            fadeSlideRoute(
                              CultureDetailScreen(
                                item: item,
                                onOpenMap: () => widget.onOpenTab(1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                      ],

                      // --- DAFTAR WASTRA & BUSANA PILIHAN ---
                      if (picked.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'Wastra & Busana Pilihan',
                          onSeeAll: () => widget.onOpenTab(2),
                        ),
                        const SizedBox(height: 14),
                        for (final item in picked) ...[
                          _PickedCard(
                            item: item,
                            onTap: () => Navigator.of(context).push(
                              fadeSlideRoute(
                                CultureDetailScreen(
                                  item: item,
                                  onOpenMap: () => widget.onOpenTab(1),
                                ),
                              ),
                            ),
                            onOrder: () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => CulturalOrderSheet(item: item),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ],
                    ],
                  ),
                ),
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



/// PANEL GLASSMORPHISM OBSIDIAN JAVARA
/// Panel kaca gelap tembus pandang dengan kilauan border emas halus.
class _JavaraGlassPanel extends StatelessWidget {
  const _JavaraGlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xF2FFFDF9),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ?? const Color(0x28B08D57),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10382315),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}



class _Javara3DTempleBackground extends StatefulWidget {
  const _Javara3DTempleBackground({
    required this.scrollController,
    required this.pointerNotifier,
  });

  final ScrollController scrollController;
  final ValueNotifier<Offset> pointerNotifier;

  @override
  State<_Javara3DTempleBackground> createState() => _Javara3DTempleBackgroundState();
}

class _Javara3DTempleBackgroundState extends State<_Javara3DTempleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;

  double _smoothScroll = 0.0;
  double _smoothPointerX = 0.0;
  double _smoothPointerY = 0.0;
  double _elapsedTime = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..addListener(_onTick)
          ..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick() {
    final targetScroll = widget.scrollController.hasClients
        ? widget.scrollController.offset
        : 0.0;
    final ptr = widget.pointerNotifier.value;

    _smoothScroll =
        ui.lerpDouble(_smoothScroll, targetScroll, 0.075) ?? targetScroll;
    _smoothPointerX = ui.lerpDouble(_smoothPointerX, ptr.dx, 0.055) ?? ptr.dx;
    _smoothPointerY = ui.lerpDouble(_smoothPointerY, ptr.dy, 0.055) ?? ptr.dy;

    _elapsedTime += 0.016;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // --- 1. LATAR HANGAT MORI SOGA ADILUHUNG (WARM IVORY HERITAGE) ---
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFAF5EC),
                Color(0xFFF4ECE0),
                Color(0xFFEBDBC7),
                Color(0xFFFAF5EC),
              ],
              stops: [0.0, 0.35, 0.70, 1.0],
            ),
          ),
        ),

        // --- 2. WATERMARK TIPOGRAFI ARSITEKTURAL RAKSASA ("J A V A R A") ---
        Positioned.fill(
          child: _JavaraArchitecturalWatermark(
            scrollOffset: _smoothScroll,
            pointerX: _smoothPointerX,
          ),
        ),

        // --- 3. SURYA MANDALA AKASA (GOLD RAYS & WARM AMBIENT CORONA) ---
        Positioned.fill(
          child: CustomPaint(
            painter: _JavaraSuryaMandalaPainter(
              scrollOffset: _smoothScroll,
              elapsedTime: _elapsedTime,
              pointerX: _smoothPointerX,
            ),
          ),
        ),

        // --- 4. KABUT VOLUMETRIK & PARTIKEL KUNANG-KUNANG EMAS WASTRA ---
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _JavaraAtmospherePainter(
                scrollOffset: _smoothScroll,
                elapsedTime: _elapsedTime,
                pointerX: _smoothPointerX,
              ),
            ),
          ),
        ),

        // --- 5. VIGNETTE PEREDUP BAWAH LEMBUT ---
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0x064A2D19),
                    const Color(0x184A2D19),
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}



/// Watermark Tipografi Arsitektural Raksasa (ThreeUI Kage Style)
class _JavaraArchitecturalWatermark extends StatelessWidget {
  const _JavaraArchitecturalWatermark({
    required this.scrollOffset,
    required this.pointerX,
  });

  final double scrollOffset;
  final double pointerX;

  @override
  Widget build(BuildContext context) {
    final parallaxY = -scrollOffset * 0.15;
    final parallaxX = pointerX * 12.0;

    return Stack(
      children: [
        Positioned(
          top: 65 + parallaxY,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.translate(
              offset: Offset(parallaxX, 0),
              child: Text(
                'JAVARA',
                style: JText.serif(
                  82,
                  weight: FontWeight.w900,
                  color: const Color(0x18FFDF9E),
                ).copyWith(letterSpacing: 14),
              ),
            ),
          ),
        ),
        Positioned(
          top: 170 + parallaxY * 0.8,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.translate(
              offset: Offset(-parallaxX * 0.5, 0),
              child: const Text(
                'ꦗ ꦮ ꦫ',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0x26DFB76C),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}



/// Melukis Surya Mandala Emas & Volumetric God Rays
class _JavaraSuryaMandalaPainter extends CustomPainter {
  _JavaraSuryaMandalaPainter({
    required this.scrollOffset,
    required this.elapsedTime,
    required this.pointerX,
  });

  final double scrollOffset;
  final double elapsedTime;
  final double pointerX;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    final pulse = math.sin(elapsedTime * 1.5) * 12.0;
    final sunX =
        w * 0.70 + (pointerX * 16.0) - (math.sin(scrollOffset * 0.002) * 14);
    final sunY =
        160.0 + (scrollOffset * 0.08) + (math.cos(elapsedTime * 1.1) * 5);
    final center = Offset(sunX, sunY);

    // 1. Pendaran Luar Surya Akasa
    final outerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFDF9E48).withValues(alpha: 0.35),
          const Color(0xFFC76828).withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 260 + pulse));
    canvas.drawCircle(center, 260 + pulse, outerGlow);

    // 2. Inti Surya Keemasan
    final innerSun = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF6E0).withValues(alpha: 0.85),
          const Color(0xFFFFB84D).withValues(alpha: 0.65),
          const Color(0xFFD46A28).withValues(alpha: 0.30),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 130));
    canvas.drawCircle(center, 130, innerSun);

    // 3. Lingkaran Suci Mandala (Concentric Sacred Geometry Rings)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFFFDF9E).withValues(alpha: 0.20)
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, 80 + pulse * 0.3, ringPaint);
    canvas.drawCircle(center, 120 + pulse * 0.5, ringPaint);

    // 4. Volumetric God Rays (Sinar Surya Radial Berputar Halus)
    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const numRays = 16;
    final angleOffset = elapsedTime * 0.08;

    for (int i = 0; i < numRays; i++) {
      final angle = (i * (2 * math.pi / numRays)) + angleOffset;
      final rayAlpha = (0.10 + math.sin(elapsedTime * 2.0 + i) * 0.05).clamp(
        0.04,
        0.18,
      );
      rayPaint.color = const Color(0xFFFFD700).withValues(alpha: rayAlpha);

      final start = Offset(
        center.dx + math.cos(angle) * 70,
        center.dy + math.sin(angle) * 70,
      );
      final end = Offset(
        center.dx + math.cos(angle) * (200 + (i % 2 == 0 ? 50 : 20)),
        center.dy + math.sin(angle) * (200 + (i % 2 == 0 ? 50 : 20)),
      );

      canvas.drawLine(start, end, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _JavaraSuryaMandalaPainter oldDelegate) => true;
}

/// Melukis Aliran Kabut Fajar & 28 Partikel Kunang-Kunang Emas Javara
class _JavaraAtmospherePainter extends CustomPainter {
  _JavaraAtmospherePainter({
    required this.scrollOffset,
    required this.elapsedTime,
    required this.pointerX,
  });

  final double scrollOffset;
  final double elapsedTime;
  final double pointerX;

  // 28 Partikel Emas dengan koordinat spasial 3D (x, y, z-depth, speed, size)
  static final List<(double, double, double, double, double)> _embers = [
    (0.12, 0.15, 0.9, 1.2, 3.8),
    (0.28, 0.32, 0.4, 0.8, 2.2),
    (0.45, 0.18, 1.4, 1.5, 4.6),
    (0.68, 0.42, 0.6, 0.9, 2.8),
    (0.82, 0.22, 1.1, 1.3, 4.0),
    (0.18, 0.65, 0.5, 0.7, 2.4),
    (0.38, 0.54, 1.3, 1.4, 4.2),
    (0.55, 0.72, 0.7, 1.0, 3.2),
    (0.76, 0.60, 1.2, 1.3, 4.4),
    (0.88, 0.82, 0.4, 0.6, 2.0),
    (0.24, 0.86, 0.8, 1.1, 3.4),
    (0.64, 0.92, 1.0, 1.2, 3.6),
    (0.08, 0.48, 0.6, 0.8, 2.6),
    (0.50, 0.38, 1.5, 1.6, 5.0),
    (0.35, 0.78, 0.5, 0.7, 2.5),
    (0.92, 0.46, 0.8, 1.0, 3.0),
    (0.15, 0.94, 1.2, 1.3, 4.1),
    (0.72, 0.28, 0.7, 0.9, 2.9),
    (0.40, 0.08, 1.0, 1.1, 3.5),
    (0.60, 0.12, 0.5, 0.7, 2.3),
    (0.80, 0.05, 1.3, 1.4, 4.3),
    (0.22, 0.38, 0.9, 1.2, 3.7),
    (0.52, 0.88, 0.4, 0.6, 2.1),
    (0.78, 0.48, 1.1, 1.3, 3.9),
    (0.32, 0.24, 0.6, 0.8, 2.7),
    (0.66, 0.68, 1.4, 1.5, 4.7),
    (0.86, 0.34, 0.5, 0.7, 2.2),
    (0.06, 0.74, 1.0, 1.1, 3.3),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // --- ALIRAN KABUT LEMBUT MELINTASI STUPA ---
    final mistPaint = Paint()..style = PaintingStyle.fill;
    final mist1X =
        (w * 0.35 + math.sin(elapsedTime * 0.4) * 80 + (pointerX * 25)) %
            (w * 1.4) -
        (w * 0.2);
    final mist1Y = h * 0.38 + math.cos(elapsedTime * 0.3) * 20;

    mistPaint.shader =
        RadialGradient(
          colors: [
            const Color(0xFFD4AF37).withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(mist1X, mist1Y),
            width: w * 0.9,
            height: 160,
          ),
        );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(mist1X, mist1Y),
        width: w * 0.9,
        height: 160,
      ),
      mistPaint,
    );

    // --- 28 PARTIKEL EMAS DENGAN KEDALAMAN 3D ---
    final emberPaint = Paint()..style = PaintingStyle.fill;

    for (final (bx, by, depth, speed, radius) in _embers) {
      final cycle =
          ((by * h * 1.5) -
              (elapsedTime * speed * 28.0) -
              (scrollOffset * 0.60 * depth)) %
          (h * 1.3);
      final py = cycle - (h * 0.15);

      final sway =
          math.sin((elapsedTime * 1.2 * speed) + (bx * 15.0)) * (15.0 * depth);
      final px = (bx * w) + sway + (pointerX * 18.0 * depth);

      final flicker = (math.sin(elapsedTime * 3.0 + (bx * 20.0)) * 0.25) + 0.75;
      final alpha = (0.60 * depth * flicker).clamp(0.18, 0.95);

      // Partikel Inti Emas
      emberPaint.color = const Color(0xFFFFD700).withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(px, py),
        radius * (0.8 + depth * 0.3),
        emberPaint,
      );

      // Pendaran Lembut di Sekeliling Partikel
      emberPaint.color = const Color(0xFFDF9E48)
          .withValues(alpha: alpha * 0.35);
      canvas.drawCircle(Offset(px, py), radius * 2.8 * depth, emberPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _JavaraAtmospherePainter oldDelegate) => true;
}

/// SEARCH BAR JAVARA OBSIDIAN GLASS
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _JavaraGlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      radius: 16,
      borderColor: const Color(0x55DFB76C),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: JText.serif(14, color: const Color(0xFF382315)),
        cursorColor: const Color(0xFFB08D57),
        decoration: InputDecoration(
          hintText: 'Cari busana, kebaya, beskap, batik, jarik...',
          hintStyle: JText.serif(14, color: const Color(0xFF7D6C5D)),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFFB08D57),
            size: 22,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, _) => v.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Hapus pencarian',
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Color(0xFFA69584),
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}



/// HERO CARD BUSANA ADAT JAWA TENGAH
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onStart,
      borderRadius: 22,
      padding: EdgeInsets.zero,
      semanticLabel: 'Koleksi Busana Adat Jawa Tengah',
      border: Border.all(color: const Color(0x77DFB76C), width: 1.2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 205,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const AssetPhoto(file: 'busana_showcase_preview.jpg', radius: 0.0),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color(0xF00A0710),
                      Color(0xB30A0710),
                      Color(0x300A0710),
                    ],
                    stops: [0.0, 0.60, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x44DFB76C),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color(0xFFDFB76C),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'WARISAN ADAT · JAWA TENGAH',
                        style: JText.serif(
                          9,
                          weight: FontWeight.w700,
                          color: const Color(0xFFFFDF9E),
                        ).copyWith(letterSpacing: 0.9),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Busana Luhur Keraton\n& Busana Adat Rakyat',
                      style: JText.serif(
                        22,
                        color: Colors.white,
                        height: 1.15,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InteractiveScale(
                      onTap: onStart,
                      pressedScale: 0.93,
                      child: Material(
                        color: const Color(0xFFDFB76C),
                        borderRadius: BorderRadius.circular(8),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Jelajahi Busana',
                                style: JText.serif(
                                  13,
                                  weight: FontWeight.w700,
                                  color: const Color(0xFF150F1E),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: Color(0xFF150F1E),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/// KATEGORI BUDAYA DENGAN TOMBOL FLOATING OBSIDIAN GLASS
class _Categories extends StatelessWidget {
  const _Categories({required this.onTap});
  final ValueChanged<String> onTap;

  static const _items = [
    (Icons.stars_rounded, 'Busana Keraton'),
    (Icons.checkroom_rounded, 'Busana Pria'),
    (Icons.face_3_rounded, 'Busana Wanita'),
    (Icons.layers_rounded, 'Batik & Jarik'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final (icon, label) in _items)
          InteractiveScale(
            pressedScale: 0.90,
            semanticLabel: 'Kategori $label',
            onTap: () => onTap(label),
            child: SizedBox(
              width: 76,
              child: Column(
                children: [
                  _JavaraGlassPanel(
                    padding: EdgeInsets.zero,
                    radius: 18,
                    child: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 24,
                        color: const Color(0xFFDFB76C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: JText.serif(
                      11.5,
                      weight: FontWeight.w600,
                      color: const Color(0xFFFFF0D0),
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}



/// RIBBON EKSPLORASI KHASANAH JAWA (ORIGINAL MASTER FEATURES)
class _FeatureDiscoveryRibbon extends StatelessWidget {
  const _FeatureDiscoveryRibbon({
    required this.onTimeTravel,
    required this.onPassport,
    required this.onHiddenHeritage,
    required this.onAksaraJawa,
    required this.onBusana3D,
    required this.onJelajahiBusana,
    required this.onPetaBusana,
    required this.onGaleriBatik,
    required this.onSinauBusana,
  });

  final VoidCallback onTimeTravel;
  final VoidCallback onPassport;
  final VoidCallback onHiddenHeritage;
  final VoidCallback onAksaraJawa;
  final VoidCallback onBusana3D;
  final VoidCallback onJelajahiBusana;
  final VoidCallback onPetaBusana;
  final VoidCallback onGaleriBatik;
  final VoidCallback onSinauBusana;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: Color(0xFFFFCC66),
                ),
                const SizedBox(width: 6),
                Text(
                  'PILAR KHASANAH NUSANTARA',
                  style: JText.serif(
                    11,
                    weight: FontWeight.w700,
                    color: const Color(0xFFFFDF9E),
                  ).copyWith(letterSpacing: 1.2),
                ),
              ],
            ),
            Text(
              '9 Eksplorasi Unik',
              style: JText.serif(11, color: const Color(0xFFC7B7A6)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _RibbonCard(
                title: 'Katalog Busana',
                subtitle: 'Anatomi & Ricikan',
                icon: Icons.menu_book_rounded,
                badge: 'KATALOG',
                onTap: () => Navigator.of(context).push(
                  fadeSlideRoute(const ClothingCatalogScreen()),
                ),
              ),
              const SizedBox(width: 10),
              _RibbonCard(
                title: 'Busana 3D',
                subtitle: 'Studio Wardrobe',
                icon: Icons.checkroom_rounded,
                badge: '3D FASHION',
                onTap: onBusana3D,
              ),
              const SizedBox(width: 10),
              _RibbonCard(
                title: 'Jelajahi Busana',
                subtitle: 'Setelan Adat',
                icon: Icons.auto_awesome_rounded,
                badge: 'KURASI',
                onTap: onJelajahiBusana,
              ),
              const SizedBox(width: 10),
              _RibbonCard(
                title: 'Peta Busana',
                subtitle: 'Persebaran Daerah',
                icon: Icons.map_rounded,
                badge: 'GEOGRAFIS',
                onTap: onPetaBusana,
              ),
              const SizedBox(width: 10),
              _RibbonCard(
                title: 'Galeri Wastra',
                subtitle: 'Batik & Motif',
                icon: Icons.layers_rounded,
                badge: 'TEKSTIL',
                onTap: onGaleriBatik,
              ),
              const SizedBox(width: 10),
              _RibbonCard(
                title: 'Sinau Busana',
                subtitle: 'Tantangan Kuis',
                icon: Icons.school_rounded,
                badge: 'EDUKASI',
                onTap: onSinauBusana,
              ),
              const SizedBox(width: 10),
              _RibbonCard(
                title: 'Garis Waktu',
                subtitle: 'Abad 6 s.d. Kini',
                icon: Icons.history_edu_rounded,
                badge: 'SEJARAH',
                onTap: onTimeTravel,
              ),
              const SizedBox(width: 10),
              _RibbonCard(
                title: 'Paspor Budaya',
                subtitle: '35 Cap Wilayah',
                icon: Icons.badge_outlined,
                badge: 'PASPOR',
                onTap: onPassport,
              ),
              const SizedBox(width: 10),
              _RibbonCard(
                title: 'Aksara Jawa',
                subtitle: 'Sanggar Hanacaraka',
                icon: Icons.edit_note_rounded,
                badge: 'AKSARA',
                onTap: onAksaraJawa,
              ),
            ],
          ),
        ),
      ],
    );
  }
}



class _RibbonCard extends StatelessWidget {
  const _RibbonCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      borderRadius: 16,
      backgroundColor: const Color(0xCC1A1022),
      border: Border.all(color: const Color(0x66DFB76C), width: 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      semanticLabel: title,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0x33DFB76C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFFDF9E), size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: JText.serif(
                      12.5,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x44DFB76C),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: JText.serif(
                        7.5,
                        weight: FontWeight.w800,
                        color: const Color(0xFFFFDF9E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: JText.serif(10.5, color: const Color(0xFFC7B7A6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



/// Banner Museum Busana Tradisional Jawa 3D Interaktif (Utama)
class _HomeFashion3DBanner extends StatelessWidget {
  const _HomeFashion3DBanner({
    required this.onOpenWardrobe,
    required this.onOpenOutfits,
  });

  final VoidCallback onOpenWardrobe;
  final VoidCallback onOpenOutfits;

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onOpenWardrobe,
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      semanticLabel: 'Buka Studio Busana Tradisional Jawa 3D',
      backgroundColor: const Color(0xFF1E1712),
      border: Border.all(
        color: const Color(0x77E4C590),
        width: 1.3,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Ikon Busana 3D
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF3B271A),
                  border: Border.all(
                    color: const Color(0xFFE4C590),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.checkroom_rounded,
                  color: Color(0xFFE4C590),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x33E4C590),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: const Color(0x66E4C590),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'STUDIO WARDROBE 3D',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE4C590),
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ꦩꦸꦱꦶꦪꦸꦩ꧀ꦧꦸꦱꦤꦗꦮ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE4C590),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Museum Busana Tradisional Jawa',
                      style: JText.serif(
                        14.5,
                        weight: FontWeight.w700,
                        color: const Color(0xFFFAF6F0),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Model Peraga Realistis & Rel Gantungan Settigation 360°',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFFA8998A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4C590),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.view_in_ar_rounded, size: 14, color: Color(0xFF14100D)),
                      SizedBox(width: 6),
                      Text(
                        'Buka Studio 3D',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF14100D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InteractiveScale(
                onTap: onOpenOutfits,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF261C14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x55E4C590), width: 0.9),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 13, color: Color(0xFFE4C590)),
                      SizedBox(width: 4),
                      Text(
                        'Jelajahi Set',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFAF6F0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}







/// SECTION HEADER JAVARA
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: JText.serif(20, weight: FontWeight.w700, color: Colors.white)
                .copyWith(
                  shadows: const [
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
          ),
        ),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Lihat semua →',
              style: JText.serif(
                12.5,
                weight: FontWeight.w700,
                color: const Color(0xFFDFB76C),
              ),
            ),
          ),
        ),
      ],
    );
  }
}



/// GRID WARISAN POPULER
class _PopularGrid extends StatelessWidget {
  const _PopularGrid({required this.items, required this.onTap});
  final List<CultureItem> items;
  final ValueChanged<CultureItem> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 14.0;
        final w = (c.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: 16,
          children: [
            for (final item in items)
              SizedBox(
                width: w,
                child: InteractiveCard(
                  semanticLabel: item.title,
                  borderRadius: 18,
                  padding: const EdgeInsets.all(8),
                  backgroundColor: const Color(0xCC1A1022),
                  border: Border.all(color: const Color(0x44DFB76C), width: 0.8),
                  onTap: () => onTap(item),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AssetPhoto(
                        file: item.image,
                        aspectRatio: 1.08,
                        radius: 12.0,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        style: JText.serif(
                          13.5,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.meta,
                        style: JText.serif(
                          11,
                          color: const Color(0xFFB3A394),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.price ?? '${item.actionLabel} →',
                        style: JText.serif(
                          12.5,
                          weight: FontWeight.w700,
                          color: item.price == null
                              ? const Color(0xFFFFD700)
                              : const Color(0xFFDFB76C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}



/// KARTU KARYA & KULINER
class _PickedCard extends StatelessWidget {
  const _PickedCard({
    required this.item,
    required this.onTap,
    required this.onOrder,
  });
  final CultureItem item;
  final VoidCallback onTap;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      semanticLabel: item.title,
      borderRadius: 18,
      padding: const EdgeInsets.all(12),
      backgroundColor: const Color(0xCC1A1022),
      border: Border.all(color: const Color(0x44DFB76C), width: 0.8),
      onTap: onTap,
      child: Row(
        children: [
          AssetPhoto(file: item.image, width: 72, height: 72, radius: 12.0),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.tag,
                  style: tagStyle().copyWith(color: const Color(0xFFDFB76C)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.title,
                  style: JText.serif(
                    15,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.price ?? '',
                  style: JText.serif(
                    13,
                    weight: FontWeight.w600,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          ),
          InteractiveScale(
            onTap: onOrder,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0x33DFB76C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x66DFB76C), width: 0.8),
              ),
              child: Text(
                '${item.actionLabel} →',
                style: JText.serif(
                  12,
                  weight: FontWeight.w700,
                  color: const Color(0xFFDFB76C),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/// Card Busana Pilihan Hari Ini (Featured Outfit of the Day)
class _FeaturedOutfitOfTheDayCard extends StatelessWidget {
  const _FeaturedOutfitOfTheDayCard({
    required this.onOpenWardrobe,
    required this.onOpenExplore,
  });

  final VoidCallback onOpenWardrobe;
  final VoidCallback onOpenExplore;

  @override
  Widget build(BuildContext context) {
    final outfit = JavaneseClothingData.curatedOutfits.first;

    return InteractiveCard(
      onTap: onOpenWardrobe,
      borderRadius: 22,
      padding: EdgeInsets.zero,
      backgroundColor: const Color(0xFF1E1712),
      border: Border.all(color: const Color(0x66E4C590), width: 1.2),
      semanticLabel: 'Busana Pilihan Hari Ini - ${outfit.title}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge & Aksara Jawa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x33E4C590),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0x66E4C590), width: 0.8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star_rounded, size: 12, color: Color(0xFFE4C590)),
                      SizedBox(width: 4),
                      Text(
                        'BUSANA PILIHAN HARI INI',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE4C590),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  outfit.javaneseScript,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFDFC08E),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outfit.title,
                  style: JText.serif(
                    18,
                    weight: FontWeight.w800,
                    color: const Color(0xFFFAF6F0),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${outfit.collectionCategory} • ${outfit.era}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB09F8F),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  outfit.summary,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFDCD2C5),
                    height: 1.45,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Komponen Ricikan Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: const [
                    _RicikanTag('Blangkon Trepes'),
                    _RicikanTag('Beskap Landhung'),
                    _RicikanTag('Batik Parang Barong'),
                    _RicikanTag('Keris Ladrang Solo'),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE4C590),
                          foregroundColor: const Color(0xFF14100D),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.view_in_ar_rounded, size: 16),
                        label: const Text(
                          'Coba di Studio 3D',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onPressed: onOpenWardrobe,
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE4C590),
                        side: const BorderSide(color: Color(0x66E4C590), width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onOpenExplore,
                      child: const Text(
                        'Koleksi Lain',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _RicikanTag extends StatelessWidget {
  const _RicikanTag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF221812),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x33E4C590), width: 0.6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFFE4C590),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}



/// Carousel Ragam Busana Unggulan Jawa Tengah
class _FeaturedGarmentsCarousel extends StatelessWidget {
  const _FeaturedGarmentsCarousel({
    required this.onSelectItem,
    required this.onSeeAll,
  });

  final ValueChanged<ClothingItem> onSelectItem;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final items = [
      ...JavaneseClothingData.upperBodyItems.take(3),
      ...JavaneseClothingData.headwearItems.take(2),
      ...JavaneseClothingData.lowerBodyItems.take(2),
      ...JavaneseClothingData.accessoryItems.take(2),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khasanah Busana Unggulan',
                  style: JText.serif(
                    17,
                    weight: FontWeight.w800,
                    color: const Color(0xFFFAF6F0),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Rasukan, bebet, dan ricikan Jawa Tengah',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA69383),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE4C590),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 165,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return InteractiveCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(12),
                backgroundColor: const Color(0xFF1F1813),
                border: Border.all(
                  color: const Color(0x33E4C590),
                  width: 0.8,
                ),
                semanticLabel: item.name,
                onTap: () => onSelectItem(item),
                child: SizedBox(
                  width: 135,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2219),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.category.icon,
                          size: 18,
                          color: const Color(0xFFE4C590),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.javaneseScript,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFFDFC08E),
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFAF6F0),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.region.title.split('(').first.trim(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9E8D7F),
                        ),
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
}


/// Banner Fitur Flagship AI Busana Budaya Jawa: AI Try-On Studio & AI Abdi Pakar Busana
class _HomeAiFashionFeaturesBanner extends StatelessWidget {
  const _HomeAiFashionFeaturesBanner({
    required this.onOpenAiStudio,
    required this.onOpenAiAssistant,
  });

  final VoidCallback onOpenAiStudio;
  final VoidCallback onOpenAiAssistant;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InteractiveCard(
            onTap: onOpenAiStudio,
            borderRadius: 16,
            padding: const EdgeInsets.all(12),
            backgroundColor: const Color(0xFF1E1712),
            border: Border.all(
              color: const Color(0x66DFB76C),
              width: 1.0,
            ),
            semanticLabel: 'Buka AI Studio Virtual Try-On',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0x33DFB76C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x88DFB76C), width: 0.8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: Color(0xFFFFDF9E),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x22DFB76C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AI TRY-ON',
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFDF9E),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'AI Fashion Studio',
                  style: JText.serif(
                    13,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Peraga fotorealistik busana adat',
                  style: JText.serif(
                    10,
                    color: const Color(0xFFC7B7A6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InteractiveCard(
            onTap: onOpenAiAssistant,
            borderRadius: 16,
            padding: const EdgeInsets.all(12),
            backgroundColor: const Color(0xFF1E1712),
            border: Border.all(
              color: const Color(0x66DFB76C),
              width: 1.0,
            ),
            semanticLabel: 'Buka AI Abdi Pakar Busana',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0x33DFB76C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x88DFB76C), width: 0.8),
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        size: 16,
                        color: Color(0xFFFFDF9E),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x22DFB76C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AI ASISTEN',
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFDF9E),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Abdi Pakar Busana',
                  style: JText.serif(
                    13,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Konsultasi filosofi & pakem',
                  style: JText.serif(
                    10,
                    color: const Color(0xFFC7B7A6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
