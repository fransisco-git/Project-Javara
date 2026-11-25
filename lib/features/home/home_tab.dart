import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../data/culture_items.dart';
import '../../widgets/motion.dart';
import '../heritage/culture_detail_screen.dart';
import '../fashion/screens/clothing_detail_screen.dart';
import '../fashion/screens/jelajahi_busana_screen.dart';
import '../fashion/screens/clothing_catalog_screen.dart';
import '../fashion/screens/batik_motif_gallery_screen.dart';
import '../fashion/data/javanese_clothing_data.dart';
import '../fashion/models/javanese_clothing_models.dart';
import '../../services/saved_garments_service.dart';
import '../../widgets/skeleton_shimmer.dart';
import '../../widgets/interactive_feedback.dart';
import 'javara_bottom_nav.dart';
import 'widgets/category_theme_icons.dart';

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
  final _searchFocusNode = FocusNode();
  final _isScrolledNotifier = ValueNotifier<bool>(false);
  String _q = '';
  bool _isLoading = true;
  bool _isSearchOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pra-decode & cache tekstur visual utama ke VRAM agar mulus tanpa stutter
    precacheImage(
      const AssetImage('assets/images/buddha_hand_left.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/buddha_hand_right.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/candi_3d_cinema.jpg'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/candi_3d_cutout.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/model_kebaya_kartini_solo.jpg'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/model_jawi_jangkep_solo.jpg'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/model_solo_basahan_bride.jpg'),
      context,
    );
  }

  @override
  void initState() {
    super.initState();
    SavedGarmentsService.instance.initialize();
    _scrollController.addListener(_onScroll);
    // Mensimulasikan pemuatan data khasanah awal yang mulus dan realistis
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _onScroll() {
    final offset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final isScrolled = offset > 10.0;
    if (isScrolled != _isScrolledNotifier.value) {
      _isScrolledNotifier.value = isScrolled;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _search.dispose();
    _searchFocusNode.dispose();
    _isScrolledNotifier.dispose();
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
    if (label == 'Busana') {
      Navigator.of(context).push(fadeSlideRoute(const ClothingCatalogScreen()));
    } else if (label.contains('Keraton')) {
      Navigator.of(context).push(
        fadeSlideRoute(
          const ClothingCatalogScreen(initialRegion: TraditionRegion.surakarta),
        ),
      );
    } else if (label.contains('Pria') || label.contains('Kakung')) {
      Navigator.of(context).push(
        fadeSlideRoute(
          const ClothingCatalogScreen(initialGender: GenderTarget.pria),
        ),
      );
    } else if (label.contains('Wanita') || label.contains('Putri')) {
      Navigator.of(context).push(
        fadeSlideRoute(
          const ClothingCatalogScreen(initialGender: GenderTarget.wanita),
        ),
      );
    } else if (label.contains('Batik') ||
        label.contains('Jarik') ||
        label.contains('Wastra')) {
      Navigator.of(context)
          .push(fadeSlideRoute(const BatikMotifGalleryScreen()));
    } else if (label.contains('Aksesoris') || label.contains('Ricikan')) {
      Navigator.of(context).push(
        fadeSlideRoute(
          const ClothingCatalogScreen(
            initialCategory: ClothingCategory.accessories,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(fadeSlideRoute(const ClothingCatalogScreen()));
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
    final allItems = [...popularItems, ...pickedItems];
    final popular = _q.isEmpty ? popularItems : _filter(allItems);
    final empty = popular.isEmpty;
    final topPadding = MediaQuery.of(context).padding.top;

    return MouseRegion(
      onHover: (e) =>
          _updatePointer(e.localPosition, MediaQuery.of(context).size),
      child: Listener(
        onPointerMove: (e) =>
            _updatePointer(e.localPosition, MediaQuery.of(context).size),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: _Javara3DTempleBackground(
                  scrollController: _scrollController,
                  pointerNotifier: _pointerNotifier,
                ),
              ),
            ),

            Positioned.fill(
              child: RepaintBoundary(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _isLoading
                          ? Padding(
                              key: const ValueKey('home_skeleton'),
                              padding: EdgeInsets.fromLTRB(
                                0,
                                topPadding + 10,
                                0,
                                110,
                              ),
                              child: const HomeTabSkeletonView(),
                            )
                          : JavaraPullRefresh(
                              key: const ValueKey('home_content'),
                              onRefresh: () async {
                                HapticFeedback.mediumImpact();
                                await Future.delayed(
                                  const Duration(milliseconds: 800),
                                );
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
                                padding: EdgeInsets.fromLTRB(
                                  20,
                                  topPadding + 62,
                                  20,
                                  JavaraBottomNav.contentBottomPadding(context),
                                ),
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                children: [
                                  // --- MODE TAMPILAN UTAMA (EDITORIAL BERANDA) ---
                                  if (_q.isEmpty) ...[
                                    // Panggung visual tertata rapi di atas dengan ruang lega di tengah
                                    const SizedBox(height: 28),
                                    // 1. Hero Editorial ("Kebaya Kartini Solo Sutra")
                                    StaggerIn(
                                      index: 1,
                                      child: _HeroCard(
                                        onStart: () {
                                          Navigator.of(context).push(
                                            fadeSlideRoute(
                                              const JelajahiBusanaScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // 2. 3 Kategori Utama
                                    StaggerIn(
                                      index: 2,
                                      child: _Categories(
                                        onTap: _onCategoryTapped,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // 3. Grid "Warisan Populer" (Dinaikkan agar koleksi busana langsung terlihat)
                                    if (popular.isNotEmpty) ...[
                                      _SectionHeader(
                                        title: 'Warisan Populer',
                                        onSeeAll: () => widget.onOpenTab(1),
                                      ),
                                      const SizedBox(height: 14),
                                      _PopularGrid(
                                        items: popular,
                                        onTap: (item) => Navigator.of(context)
                                            .push(
                                              fadeSlideRoute(
                                                CultureDetailScreen(
                                                  item: item,
                                                  onOpenMap: () =>
                                                      widget.onOpenTab(1),
                                                ),
                                              ),
                                            ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],

                                    // 4. Sorotan Kurasi "Busana Pilihan Hari Ini"
                                    StaggerIn(
                                      index: 3,
                                      child: _FeaturedOutfitOfTheDayCard(
                                        onOpenExplore: () =>
                                            Navigator.of(context).push(
                                              fadeSlideRoute(
                                                const JelajahiBusanaScreen(),
                                              ),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 26),
                                  ],

                                  // --- MODE HASIL PENCARIAN ---
                                  if (_q.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    if (empty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 40,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Tidak ada hasil untuk "${_search.text.trim()}"',
                                            style: JText.serif(
                                              14,
                                              color: const Color(0xFFB3A394),
                                            ),
                                          ),
                                        ),
                                      )
                                    else ...[
                                      _SectionHeader(
                                        title:
                                            'Hasil Pencarian (${popular.length})',
                                        onSeeAll: () => widget.onOpenTab(1),
                                      ),
                                      const SizedBox(height: 14),
                                      _PopularGrid(
                                        items: popular,
                                        onTap: (item) => Navigator.of(context)
                                            .push(
                                              fadeSlideRoute(
                                                CultureDetailScreen(
                                                  item: item,
                                                  onOpenMap: () =>
                                                      widget.onOpenTab(1),
                                                ),
                                              ),
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),

            // --- TOP APP BAR HEADER: LOGO JAVARA & MINIMALIST ACTION ICONS ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isScrolledNotifier,
                  builder: (context, isScrolled, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, 10),
                      decoration: BoxDecoration(
                        color: isScrolled
                            ? const Color(0xE60D0914)
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: isScrolled
                                ? const Color(0x22DFB76C)
                                : Colors.transparent,
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 540),
                          child: _HomeTopHeader(
                            isSearchOpen: _isSearchOpen,
                            controller: _search,
                            focusNode: _searchFocusNode,
                            onOpenSearch: () {
                              HapticFeedback.lightImpact();
                              setState(() => _isSearchOpen = true);
                              _searchFocusNode.requestFocus();
                            },
                            onCloseSearch: () {
                              HapticFeedback.lightImpact();
                              _search.clear();
                              _searchFocusNode.unfocus();
                              setState(() {
                                _q = '';
                                _isSearchOpen = false;
                              });
                            },
                            onSearchChanged: (v) {
                              setState(() => _q = v.trim().toLowerCase());
                            },
                          ),
                        ),
                      ),
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

/// PANEL GLASSMORPHISM OBSIDIAN JAVARA
/// Panel kaca gelap tembus pandang dengan kilauan border emas halus.
class _JavaraGlassPanel extends StatelessWidget {
  const _JavaraGlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xEE140E1B),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: const Color(0x38DFB76C), width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
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
  State<_Javara3DTempleBackground> createState() =>
      _Javara3DTempleBackgroundState();
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
        ui.lerpDouble(_smoothScroll, targetScroll, 0.065) ?? targetScroll;
    _smoothPointerX = ui.lerpDouble(_smoothPointerX, ptr.dx, 0.055) ?? ptr.dx;
    _smoothPointerY = ui.lerpDouble(_smoothPointerY, ptr.dy, 0.055) ?? ptr.dy;

    _elapsedTime += 0.016;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    final scrollRatio = (_smoothScroll / 650.0).clamp(0.0, 1.2);

    // KINEMATIKA GERAK TANGAN MUDRA BUDDHA (DARI TERTUTUP MENJADI TERBUKA SAAT DI-SCROLL)
    // 0.0 (Scroll = 0) : Kedua tangan TERTUTUP menyatu rapat di tengah (Anjali Mudra / Sembah Suci)
    // 1.0 (Scroll > 0) : Kedua tangan TERBUKA menyibak ke pojok kiri & kanan menyingkap Candi Borobudur
    // Jarak rentang diperpanjang ke 520px & kurva easeInOutCubic agar buka-tutup tenang & tidak cepat menutup
    final openProgress = (_smoothScroll / 520.0).clamp(0.0, 1.0);
    final openCurve = Curves.easeInOutCubic.transform(openProgress);

    // Dimensi dan proporsi tangan fotorealistik diperbesar sesuai preferensi user
    final handHeight = (w * 0.98).clamp(360.0, 480.0);
    final leftHandWidth = handHeight * (682.0 / 735.0);
    final rightHandWidth = handHeight * (694.0 / 735.0);
    final centerX = w / 2;

    // Posisi Tertutup di tengah (Closed Clapping Meeting Point):
    final leftClosedX = centerX - leftHandWidth + 3.0;
    final rightClosedX = centerX - 3.0;

    // Posisi Terbuka di pojokan (Menyibak ke kiri & kanan secara dramatis):
    final openDistance = (w * 0.36).clamp(120.0, 180.0);
    final leftOpenX = leftClosedX - openDistance;
    final rightOpenX = rightClosedX + openDistance;

    // Interpolasi dari TERTUTUP -> TERBUKA seiring scroll
    final leftTargetX =
        ui.lerpDouble(leftClosedX, leftOpenX, openCurve)! +
        (_smoothPointerX * 8.0);
    final rightTargetX =
        ui.lerpDouble(rightClosedX, rightOpenX, openCurve)! +
        (_smoothPointerX * 8.0);

    // Parallax posisi vertikal tangan:
    final handsY =
        ui.lerpDouble(115.0, 155.0, openCurve)! -
        (_smoothScroll * 0.12) +
        (_smoothPointerY * 12.0);

    // Rotasi 3D spasial telapak tangan:
    // Saat tertutup (0.0): tegak menghadap satu sama lain menyatu (sembah suci)
    // Saat terbuka (1.0): berotasi menyibak ke luar secara 3D
    final leftHandYaw =
        ui.lerpDouble(0.0, -0.42, openCurve)! + (_smoothPointerX * 0.05);
    final leftHandPitch = (_smoothPointerY * -0.05) + (scrollRatio * 0.04);
    final leftHandRoll =
        ui.lerpDouble(0.0, -0.16, openCurve)! + (_smoothPointerX * 0.02);

    final rightHandYaw =
        ui.lerpDouble(0.0, 0.42, openCurve)! + (_smoothPointerX * 0.05);
    final rightHandPitch = (_smoothPointerY * -0.05) + (scrollRatio * 0.04);
    final rightHandRoll =
        ui.lerpDouble(0.0, 0.16, openCurve)! + (_smoothPointerX * 0.02);

    final leftHandMatrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0016)
      ..rotateX(leftHandPitch)
      ..rotateY(leftHandYaw)
      ..rotateZ(leftHandRoll);

    final rightHandMatrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0016)
      ..rotateX(rightHandPitch)
      ..rotateY(rightHandYaw)
      ..rotateZ(rightHandRoll);

    final handsOpacity = (1.0 - ((_smoothScroll - 600.0) / 450.0)).clamp(
      0.35,
      1.0,
    );

    // DOLLY ZOOM SINEMATIK CANDI:
    final ambientBreath = math.sin(_elapsedTime * 1.3) * 0.012;
    final zoom = 1.0 + (scrollRatio * 0.45) + ambientBreath;

    // Sudut 3D Spasial Candi (Pitch, Yaw, Roll):
    final pitch =
        (scrollRatio * 0.12) +
        (_smoothPointerY * -0.05) +
        (math.sin(_elapsedTime * 1.1) * 0.010);
    final yaw =
        (_smoothPointerX * 0.08) + (math.sin(_smoothScroll * 0.0035) * 0.025);
    final roll =
        (_smoothPointerX * 0.015) + (math.sin(_elapsedTime * 0.8) * 0.006);

    // Translasi Vertikal & Horizontal Parallax Candi:
    final translateY =
        -_smoothScroll * 0.28 + (math.sin(_elapsedTime * 1.5) * 5.0);
    final translateX =
        (_smoothPointerX * 16.0) + (math.sin(_smoothScroll * 0.004) * 10.0);

    final templeMatrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0016)
      // ignore: deprecated_member_use
      ..translate(translateX, translateY, 0.0)
      // ignore: deprecated_member_use
      ..scale(zoom, zoom, 1.0)
      ..rotateX(pitch)
      ..rotateY(yaw)
      ..rotateZ(roll);

    return Stack(
      fit: StackFit.expand,
      children: [
        // --- 1. LANGIT OBSIDIAN DUSK MISTIS (THREEUI KAGE STYLE) ---
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF040206), // Puncak langit malam obsidian
                Color(0xFF0D0814),
                Color(0xFF1B0E1E), // Atmospheric dusk
                Color(0xFF2E1715), // Warm volcanic sunset horizon
                Color(0xFF07040B), // Deep ground
              ],
              stops: [0.0, 0.25, 0.55, 0.82, 1.0],
            ),
          ),
        ),

        // --- 2. WATERMARK TIPOGRAFI ARSITEKTURAL RAKSASA (KAGE STYLE: "J A V A R A") ---
        Positioned.fill(
          child: _JavaraArchitecturalWatermark(
            scrollOffset: _smoothScroll,
            pointerX: _smoothPointerX,
          ),
        ),

        // --- 3. SURYA MANDALA AKASA (GOD RAYS & RADIANT GOLD CORONA) ---
        Positioned.fill(
          child: CustomPaint(
            painter: _JavaraSuryaMandalaPainter(
              scrollOffset: _smoothScroll,
              elapsedTime: _elapsedTime,
              pointerX: _smoothPointerX,
            ),
          ),
        ),

        // --- 4. MODEL 3D CANDI BOROBUDUR SINEMATIK (OCTANE RENDER QUALITY) ---
        Positioned(
          top: -20,
          left: -w * 0.12,
          right: -w * 0.12,
          bottom: -70,
          child: RepaintBoundary(
            child: Transform(
              transform: templeMatrix,
              alignment: Alignment.center,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/candi_3d_cinema.jpg',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    excludeFromSemantics: true,
                  ),
                  Image.asset(
                    'assets/images/candi_3d_cutout.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- 5. AURA ENERGI SUCI ANJALI MUDRA (BLOOM & SACRED RIPPLES SAAT TELAPAK BERTEMU DI TENGAH) ---
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _AnjaliMudraEnergyPainter(
                contactPoint: Offset(
                  centerX + (_smoothPointerX * 8.0),
                  handsY + (handHeight * 0.44),
                ),
                openCurve: openCurve,
                elapsedTime: _elapsedTime,
              ),
            ),
          ),
        ),

        // --- 6. TANGAN KIRI BUDDHA 3D (MEMBUKA MENYIBAK KE KIRI SEIRING SCROLL) ---
        Positioned(
          top: handsY,
          left: leftTargetX,
          width: leftHandWidth,
          height: handHeight,
          child: RepaintBoundary(
            child: IgnorePointer(
              child: Opacity(
                opacity: handsOpacity,
                child: Transform(
                  transform: leftHandMatrix,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/buddha_hand_left.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ),
        ),

        // --- 7. TANGAN KANAN BUDDHA 3D (MEMBUKA MENYIBAK KE KANAN SEIRING SCROLL) ---
        Positioned(
          top: handsY,
          left: rightTargetX,
          width: rightHandWidth,
          height: handHeight,
          child: RepaintBoundary(
            child: IgnorePointer(
              child: Opacity(
                opacity: handsOpacity,
                child: Transform(
                  transform: rightHandMatrix,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/buddha_hand_right.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ),
        ),

        // --- 8. KABUT VOLUMETRIK & 32 PARTIKEL KUNANG-KUNANG EMAS ---
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

        // --- 10. VIGNETTE PEREDUP BAWAH (MEMASTIKAN KONTEN TERBACA JELAS) ---
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x22000000),
                    Colors.transparent,
                    const Color(0x6607040B),
                    const Color(0xF507040B),
                  ],
                  stops: const [0.0, 0.20, 0.60, 1.0],
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

/// Melukis Pendaran Aura Emas Suci & Gelombang Anjali Mudra saat telapak tangan bertemu di tengah
class _AnjaliMudraEnergyPainter extends CustomPainter {
  _AnjaliMudraEnergyPainter({
    required this.contactPoint,
    required this.openCurve,
    required this.elapsedTime,
  });

  final Offset contactPoint;
  final double openCurve;
  final double elapsedTime;

  @override
  void paint(Canvas canvas, Size size) {
    // Pendaran sakral paling terang saat tangan menyatu tertutup di tengah (openCurve = 0),
    // dan menghilang perlahan seiring tangan membuka menyibak (openCurve > 0.45)
    if (openCurve > 0.45) return;

    final intensity = ((0.45 - openCurve) / 0.45).clamp(0.0, 1.0);

    // 1. Pendaran Inti Emas Luhur (Golden Prana Halo Core)
    final pulse = math.sin(elapsedTime * 3.5) * 6.0;
    final coreRadius = (46.0 + pulse) * intensity;
    final corePaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFFFFBE8).withValues(alpha: 0.95 * intensity),
              const Color(0xFFFFDF9E).withValues(alpha: 0.75 * intensity),
              const Color(0xFFFFB84D).withValues(alpha: 0.40 * intensity),
              Colors.transparent,
            ],
            stops: const [0.0, 0.35, 0.70, 1.0],
          ).createShader(
            Rect.fromCircle(center: contactPoint, radius: coreRadius * 2.0),
          );

    canvas.drawCircle(contactPoint, coreRadius * 2.0, corePaint);

    // 2. Lingkaran Gelombang Suci Berkembang (Concentric Sacred Ripples)
    final ripplePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 3; i++) {
      final phase = (elapsedTime * 1.2 + (i * 0.33)) % 1.0;
      final r = (22.0 + phase * 95.0) * intensity;
      final alpha = ((1.0 - phase) * 0.45 * intensity).clamp(0.0, 1.0);
      ripplePaint.color = const Color(0xFFFFD700).withValues(alpha: alpha);
      canvas.drawCircle(contactPoint, r, ripplePaint);
    }

    // 3. Kilau Bintang Berlian 8 Arah (Prabha Starburst) saat tangan tertutup rapat di tengah
    if (intensity > 0.40) {
      final starIntensity = ((intensity - 0.40) / 0.60);
      final starPaint = Paint()
        ..color = const Color(0xFFFFFFFF)
            .withValues(alpha: 0.90 * starIntensity)
        ..style = PaintingStyle.fill;

      final longRay =
          (40.0 + math.sin(elapsedTime * 6.0) * 8.0) * starIntensity;
      final shortRay = longRay * 0.34;

      final path = Path()
        ..moveTo(contactPoint.dx, contactPoint.dy - longRay)
        ..quadraticBezierTo(
          contactPoint.dx,
          contactPoint.dy,
          contactPoint.dx + shortRay,
          contactPoint.dy - shortRay,
        )
        ..quadraticBezierTo(
          contactPoint.dx,
          contactPoint.dy,
          contactPoint.dx + longRay,
          contactPoint.dy,
        )
        ..quadraticBezierTo(
          contactPoint.dx,
          contactPoint.dy,
          contactPoint.dx + shortRay,
          contactPoint.dy + shortRay,
        )
        ..quadraticBezierTo(
          contactPoint.dx,
          contactPoint.dy,
          contactPoint.dx,
          contactPoint.dy + longRay,
        )
        ..quadraticBezierTo(
          contactPoint.dx,
          contactPoint.dy,
          contactPoint.dx - shortRay,
          contactPoint.dy + shortRay,
        )
        ..quadraticBezierTo(
          contactPoint.dx,
          contactPoint.dy,
          contactPoint.dx - longRay,
          contactPoint.dy,
        )
        ..quadraticBezierTo(
          contactPoint.dx,
          contactPoint.dy,
          contactPoint.dx - shortRay,
          contactPoint.dy - shortRay,
        )
        ..close();

      canvas.drawPath(path, starPaint);

      // Pusat kilau intan putih murni
      final diamondCore = Paint()
        ..color = const Color(0xFFFFFFFF)
            .withValues(alpha: 0.95 * starIntensity);
      canvas.drawCircle(contactPoint, 4.0 * starIntensity, diamondCore);
    }
  }

  @override
  bool shouldRepaint(covariant _AnjaliMudraEnergyPainter oldDelegate) => true;
}

/// TOP APP BAR HEADER DENGAN LOGO JAVARA & MINIMALIST ACTION ICONS SESUAI GAMBAR REFERENSI
class _HomeTopHeader extends StatelessWidget {
  const _HomeTopHeader({
    required this.isSearchOpen,
    required this.controller,
    required this.focusNode,
    required this.onOpenSearch,
    required this.onCloseSearch,
    required this.onSearchChanged,
  });

  final bool isSearchOpen;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onOpenSearch;
  final VoidCallback onCloseSearch;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: isSearchOpen
          ? Container(
              key: const ValueKey('header_search_input'),
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xE6140E1B),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0x66DFB76C), width: 1.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFFDFB76C),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: true,
                      onChanged: onSearchChanged,
                      textInputAction: TextInputAction.search,
                      style: JText.serif(14, color: Colors.white),
                      cursorColor: const Color(0xFFFFD700),
                      decoration: InputDecoration(
                        hintText:
                            'Cari busana, kebaya, beskap, batik, jarik...',
                        hintStyle: JText.serif(
                          13.5,
                          color: const Color(0xFFA69584),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup pencarian',
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 19,
                      color: Color(0xFFDFB76C),
                    ),
                    onPressed: onCloseSearch,
                    splashRadius: 20,
                  ),
                ],
              ),
            )
          : Row(
              key: const ValueKey('header_logo_bar'),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LOGO JAVARA DI ATAS KIRI (Clean, Bold, Modern Tracking sesuai Gambar Referensi)
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Semantics(
                      header: true,
                      label: 'Javara Logo',
                      child: const Text(
                        'J A V A R A',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.4,
                          color: Color(0xFFFFFDF8),
                          shadows: [
                            Shadow(
                              color: Color(0x99000000),
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // TOMBOL AKSI MINIMALIS DI ATAS KANAN (Search)
                _TopHeaderIconButton(
                  icon: Icons.search_rounded,
                  tooltip: 'Cari Busana & Khasanah',
                  onTap: onOpenSearch,
                ),
              ],
            ),
    );
  }
}

/// Tombol Ikon Bundar Minimalis di Header Atas Beranda (Sesuai Referensi Gambar Minimalis)
class _TopHeaderIconButton extends StatelessWidget {
  const _TopHeaderIconButton({
    this.icon,
    this.iconWidget,
    required this.tooltip,
    required this.onTap,
  }) : assert(icon != null || iconWidget != null);

  final IconData? icon;
  final Widget? iconWidget;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Material(
            color: Colors.transparent,
            child: InkResponse(
              onTap: onTap,
              radius: 24,
              containedInkWell: true,
              child: Center(
                child:
                    iconWidget ??
                    Icon(icon, color: const Color(0xFFFAF6F0), size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// MODEL ITEM HERO ADIBUSANA JAVARA
class _HeroAdibusanaItem {
  const _HeroAdibusanaItem({
    required this.tag,
    required this.javaneseScript,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.buttonLabel,
    required this.routeBuilder,
  });

  final String tag;
  final String javaneseScript;
  final String title;
  final String subtitle;
  final String imagePath;
  final String buttonLabel;
  final Widget Function() routeBuilder;
}

/// HERO SHOWCASE ADIBUSANA AGENG KERATON JAWA TENGAH
/// Menggantikan hero lama dengan pameran busana adat adiluhung beresolusi tinggi,
/// tipografi editorial mewah, dan narasi filosofis otentik tanpa elemen semu.
class _HeroCard extends StatefulWidget {
  const _HeroCard({required this.onStart});
  final VoidCallback onStart;

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  late final PageController _pageController;
  int _currentPage = 0;

  static final List<_HeroAdibusanaItem> _items = [
    _HeroAdibusanaItem(
      tag: 'ADIBUSANA NINGRAT PUTRI',
      javaneseScript: 'ꦏꦼꦧꦪꦏꦂꦠꦶꦤꦶ',
      title: 'Kebaya Kartini Solo Sutra',
      subtitle: 'Keanggunan putri bangsawan berhias peniti renteng kencana dan jarik Parang Kusumo.',
      imagePath: 'assets/images/model_kebaya_kartini_solo.jpg',
      buttonLabel: 'Koleksi Busana Putri',
      routeBuilder: () =>
          const ClothingCatalogScreen(initialGender: GenderTarget.wanita),
    ),
    _HeroAdibusanaItem(
      tag: 'ADIBUSANA AGENG KSATRIA',
      javaneseScript: 'ꦗꦮꦶꦗꦁꦏꦼꦥ꧀',
      title: 'Jawi Jangkep Keprabon',
      subtitle: 'Busana resmi ksatria Keraton Surakarta Hadiningrat berhias beskap sikepan & keris ladrang.',
      imagePath: 'assets/images/model_jawi_jangkep_solo.jpg',
      buttonLabel: 'Koleksi Busana Pria',
      routeBuilder: () =>
          const ClothingCatalogScreen(initialGender: GenderTarget.pria),
    ),
    _HeroAdibusanaItem(
      tag: 'MAHAKARYA PENGANTIN',
      javaneseScript: 'ꦱꦺꦴꦭꦺꦴꦧꦱꦲꦤ꧀',
      title: 'Solo Basahan Kampuhan',
      subtitle: 'Tata rias pengantin ageng tertua keraton berbalut dodot kampuh prada emas & melati ronce.',
      imagePath: 'assets/images/model_solo_basahan_bride.jpg',
      buttonLabel: 'Jelajahi Busana Adat',
      routeBuilder: () => const JelajahiBusanaScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 228,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x66DFB76C), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // PageView Slider
            PageView.builder(
              controller: _pageController,
              itemCount: _items.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final item = _items[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Foto Busana Adat Beresolusi Tinggi
                    Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    ),

                    // Gradasi Bayangan Sinematik Obsidian (Memastikan Keterbacaan Teks Sempurna)
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xF50A0710),
                            Color(0xD90A0710),
                            Color(0x800A0710),
                            Color(0x150A0710),
                          ],
                          stops: [0.0, 0.45, 0.72, 1.0],
                        ),
                      ),
                    ),

                    // Konten Teks Editorial & Tombol Aksi
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Badge Pilar Budaya & Aksara Jawa
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0x38DFB76C),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0x88DFB76C),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome,
                                          size: 11,
                                          color: Color(0xFFFFDF9E),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          item.tag,
                                          style: JText.sans(
                                            8.5,
                                            weight: FontWeight.w800,
                                            color: const Color(0xFFFFDF9E),
                                          ).copyWith(letterSpacing: 0.9),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    item.javaneseScript,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xBFDFB76C),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Judul Koleksi Busana Adat
                              Text(
                                item.title,
                                style: JText.editorial(
                                  21,
                                  weight: FontWeight.w700,
                                  color: const Color(0xFFFFFDF8),
                                  height: 1.15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 5),

                              // Deskripsi Filosofis Singkat
                              Text(
                                item.subtitle,
                                style: JText.sans(
                                  11,
                                  color: const Color(0xFFD6C8B8),
                                  height: 1.35,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 12),

                              // Tombol Eksplorasi Solid Emas Kencana
                              InteractiveScale(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(
                                    context,
                                  ).push(fadeSlideRoute(item.routeBuilder()));
                                },
                                pressedScale: 0.94,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8.5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFE4C590),
                                        Color(0xFFC79B3A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            item.buttonLabel,
                                            style: JText.sans(
                                              11.5,
                                              weight: FontWeight.w700,
                                              color: const Color(0xFF14100D),
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 13,
                                        color: Color(0xFF14100D),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Indikator Titik Carousel di Pojok Kanan Bawah
            Positioned(
              bottom: 12,
              right: 14,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  _items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 16 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFFE4C590)
                          : const Color(0x66DFB76C),
                      borderRadius: BorderRadius.circular(3),
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

/// KATEGORI PILAR ADIBUSANA JAWA TENGAH (Busana, Aksesoris, Batik)
class _Categories extends StatelessWidget {
  const _Categories({required this.onTap});
  final ValueChanged<String> onTap;

  static const _items = [
    (
      iconType: JavaraCategoryIconType.busana,
      title: 'Busana',
      subtitle: 'Pria & Wanita',
      actionKey: 'Busana',
    ),
    (
      iconType: JavaraCategoryIconType.aksesoris,
      title: 'Aksesoris',
      subtitle: 'Ricikan Adat',
      actionKey: 'Aksesoris',
    ),
    (
      iconType: JavaraCategoryIconType.batik,
      title: 'Batik',
      subtitle: 'Motif Pakem',
      actionKey: 'Batik',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final item in _items)
          Expanded(
            child: InteractiveScale(
              pressedScale: 0.92,
              semanticLabel: 'Kategori ${item.title}',
              onTap: () => onTap(item.actionKey),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _JavaraGlassPanel(
                      padding: EdgeInsets.zero,
                      radius: 18,
                      child: Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const RadialGradient(
                            center: Alignment.topLeft,
                            radius: 1.2,
                            colors: [Color(0x35DFB76C), Color(0x05DFB76C)],
                          ),
                        ),
                        child: ExcludeSemantics(
                          child: JavaraCategoryThemeIcon(
                            key: ValueKey('category_icon_${item.actionKey.toLowerCase()}'),
                            type: item.iconType,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.title,
                              style: JText.serif(
                                11.5,
                                weight: FontWeight.w700,
                                color: const Color(0xFFFFF0D0),
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 1.5),
                            Text(
                              item.subtitle,
                              style: JText.sans(
                                9.5,
                                weight: FontWeight.w500,
                                color: const Color(0xFFAFA08F),
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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

/// Format label kategori dan asal busana (singkat & tidak terpotong)
String _formatCategoryOrigin(CultureItem item) {
  final lowerMeta = item.meta.toLowerCase();
  final lowerCat = item.category.toLowerCase();
  final lowerId = item.id.toLowerCase();
  final lowerTitle = item.title.toLowerCase();

  if (lowerMeta.contains('rembang') ||
      lowerMeta.contains('jepara') ||
      lowerId.contains('rembang')) {
    return 'REMBANG · WANITA';
  } else if (lowerMeta.contains('wastra') ||
      lowerCat.contains('batik') ||
      lowerMeta.contains('batik') ||
      lowerTitle.contains('batik')) {
    return 'SURAKARTA · WASTRA';
  } else if (lowerMeta.contains('pengantin') ||
      lowerTitle.contains('pengantin') ||
      lowerId.contains('pengantin')) {
    return 'SURAKARTA · PENGANTIN';
  } else if (lowerMeta.contains('pria') ||
      lowerTitle.contains('beskap') ||
      lowerTitle.contains('surjan')) {
    return 'SURAKARTA · PRIA';
  } else if (lowerMeta.contains('wanita') || lowerTitle.contains('kebaya')) {
    return 'SURAKARTA · WANITA';
  }
  return 'SURAKARTA · ADILUHUNG';
}

/// GRID WARISAN POPULER - Editorial Fashion Lookbook & Arsip Museum
class _PopularGrid extends StatelessWidget {
  const _PopularGrid({required this.items, required this.onTap});
  final List<CultureItem> items;
  final ValueChanged<CultureItem> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const crossAxisSpacing = 14.0;
        const mainAxisSpacing = 28.0;
        final w = (c.maxWidth - crossAxisSpacing) / 2;
        return Wrap(
          spacing: crossAxisSpacing,
          runSpacing: mainAxisSpacing,
          children: [
            for (final item in items)
              SizedBox(
                width: w,
                child: _EditorialCultureCard(item: item, onTap: onTap),
              ),
          ],
        );
      },
    );
  }
}

/// KARTU EDITORIAL BUSANA ADAT - Arsip Museum Keraton Jawa Tengah
class _EditorialCultureCard extends StatelessWidget {
  const _EditorialCultureCard({required this.item, required this.onTap});

  final CultureItem item;
  final ValueChanged<CultureItem> onTap;

  @override
  Widget build(BuildContext context) {
    final isBatikOrTextile =
        item.image.contains('batik') ||
        item.category.toLowerCase().contains('batik') ||
        item.title.toLowerCase().contains('batik');

    return InteractiveScale(
      pressedScale: 0.98,
      semanticLabel: item.title,
      onTap: () => onTap(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Bingkai Foto Potret (AspectRatio 3 / 4)
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0x2EC5A467), width: 0.6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.4),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Base Image
                    Image.asset(
                      'assets/images/${item.image}',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      filterQuality: FilterQuality.medium,
                      frameBuilder: (_, child, frame, sync) => AnimatedOpacity(
                        opacity: (sync || frame != null) ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: child,
                      ),
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFF181512),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Color(0x44B89B67),
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Subtle warm tint overlay untuk wastra/batik datar yang lebih terang
                    if (isBatikOrTextile)
                      const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0x1814100C)),
                      ),

                    // Gradasi vignette tipis di 20% bagian atas dan bawah
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x4D0D0C0B),
                            Colors.transparent,
                            Colors.transparent,
                            Color(0x4D0D0C0B),
                          ],
                          stops: [0.0, 0.2, 0.8, 1.0],
                        ),
                      ),
                    ),

                    // Minimalist bookmark icon di pojok kanan atas foto
                    Positioned(
                      top: 6,
                      right: 6,
                      child: ValueListenableBuilder<Set<String>>(
                        valueListenable:
                            SavedGarmentsService.instance.savedItemIdsNotifier,
                        builder: (context, savedIds, _) {
                          final isSaved = savedIds.contains(item.id);
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              SavedGarmentsService.instance.toggleSave(item.id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_outline_rounded,
                                color: const Color(0xFFEFEAE0),
                                size: 19,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Tipografi & Teks Langsung di Atas Kanvas (Borderless Footer)
          const SizedBox(height: 10),
          Text(
            _formatCategoryOrigin(item),
            style: JText.sans(
              10,
              weight: FontWeight.w400,
              color: const Color(0xFFB89B67),
            ).copyWith(letterSpacing: 1.3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Container(width: 18, height: 1, color: const Color(0x66C5A467)),
          const SizedBox(height: 5),
          Text(
            item.title,
            style: JText.serif(
              15,
              weight: FontWeight.w500,
              color: const Color(0xFFF2ECE1),
            ).copyWith(height: 1.25),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Card Busana Pilihan Hari Ini (Featured Outfit of the Day)
/// Disajikan dengan layout editorial tenang, bebas tombol mencolok yang berebut fokus.
class _FeaturedOutfitOfTheDayCard extends StatelessWidget {
  const _FeaturedOutfitOfTheDayCard({this.onOpenExplore});

  final VoidCallback? onOpenExplore;

  @override
  Widget build(BuildContext context) {
    final outfit = JavaneseClothingData.curatedOutfits.first;

    void navigateToDetail() {
      HapticFeedback.lightImpact();
      final item = JavaneseClothingData.clothingItems.firstWhere(
        (it) => it.id == outfit.upperBodyId,
        orElse: () => JavaneseClothingData.clothingItems.first,
      );
      Navigator.of(context)
          .push(fadeSlideRoute(ClothingDetailScreen(item: item)));
    }

    return InteractiveCard(
      onTap: navigateToDetail,
      borderRadius: 20,
      padding: EdgeInsets.zero,
      backgroundColor: const Color(0xFF181614),
      border: Border.all(color: const Color(0x14FFFFFF), width: 1.0),
      semanticLabel: 'Busana Pilihan Hari Ini - ${outfit.title}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge & Aksara Jawa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1AE4C590),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0x33E4C590),
                      width: 0.8,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Color(0xFFE4C590),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'BUSANA PILIHAN HARI INI',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
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

                // Tombol Sekunder / Ghost Button: Lihat Detail Busana →
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFAF6F0),
                          backgroundColor: const Color(0x0FFFFFFF),
                          side: const BorderSide(
                            color: Color(0x22FFFFFF),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: navigateToDetail,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lihat Detail Busana',
                              style: JText.sans(
                                12,
                                weight: FontWeight.w600,
                                color: const Color(0xFFFAF6F0),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Color(0xFFE4C590),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (onOpenExplore != null) ...[
                      const SizedBox(width: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB09F8F),
                          side: const BorderSide(
                            color: Color(0x14FFFFFF),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: onOpenExplore,
                        child: Text(
                          'Koleksi Lain',
                          style: JText.sans(
                            12,
                            weight: FontWeight.w600,
                            color: const Color(0xFFB09F8F),
                          ),
                        ),
                      ),
                    ],
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
