import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme.dart';
import '../../../core/transitions.dart';
import '../../../widgets/interactive_feedback.dart';
import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';
import 'clothing_detail_screen.dart';
import 'javanese_wardrobe_screen.dart';
import 'jelajahi_busana_screen.dart';
import 'batik_motif_gallery_screen.dart';
import 'javanese_fashion_map_screen.dart';
import 'sinau_busana_screen.dart';
import 'ai_fashion_studio_screen.dart';
import 'ai_cultural_assistant_screen.dart';
import 'javara_studio_screen.dart';

/// Tab Wardrobe — Pusat eksplorasi & Virtual Try-On busana adat Jawa Tengah.
/// Terintegrasi dengan Anywear Decart AI Live Studio (On-Cam Camera First)
/// serta katalog ensiklopedia busana pria & wanita, akses studio 3D,
/// galeri batik, peta busana, dan fitur edukasi.
class WardrobeTab extends StatefulWidget {
  const WardrobeTab({super.key});

  @override
  State<WardrobeTab> createState() => _WardrobeTabState();
}

class _WardrobeTabState extends State<WardrobeTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Mode Tampilan: 0 = Live Anywear On-Cam Studio (Default), 1 = Ensiklopedia & Koleksi
  int _studioModeIndex = 0;

  GenderTarget _selectedGender = GenderTarget.pria;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _selectedGender =
            _tabController.index == 0 ? GenderTarget.pria : GenderTarget.wanita;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<ClothingItem> get _filteredItems {
    final all = [
      ...JavaneseClothingData.headwearItems,
      ...JavaneseClothingData.upperBodyItems,
      ...JavaneseClothingData.lowerBodyItems,
      ...JavaneseClothingData.accessoryItems,
    ];
    return all.where((item) => item.gender == _selectedGender).toList();
  }

  List<TraditionalOutfit> get _filteredOutfits {
    return JavaneseClothingData.curatedOutfits
        .where((o) => o.gender == _selectedGender)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Mode Utama: Live On-Cam Anywear Studio (Decart AI Style)
    if (_studioModeIndex == 0) {
      return JavaraStudioScreen(
        isEmbeddedInTab: true,
        initialMode: StudioViewingMode.liveCamera,
        onSwitchToCatalogTab: () {
          HapticFeedback.selectionClick();
          setState(() => _studioModeIndex = 1);
        },
      );
    }

    // Mode Sekunder: Ensiklopedia & Koleksi Busana Tradisional Lengkap
    final bottomPad = MediaQuery.of(context).padding.bottom + 80;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: JavaraPullRefresh(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await Future.delayed(const Duration(milliseconds: 600));
            if (mounted) setState(() {});
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Header dengan Tombol Cepat Kembali ke Live On-Cam Studio
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF261C14),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0x44E4C590),
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(
                              Icons.checkroom_rounded,
                              color: Color(0xFFE4C590),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Koleksi Busana Adat',
                                  style: JText.serif(
                                    18,
                                    weight: FontWeight.w700,
                                    color: const Color(0xFFFAF6F0),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Ensiklopedia Warisan Jawa Tengah',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFFA89989),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tombol Langsung Kembali ke Live On-Cam Studio
                          InteractiveScale(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _studioModeIndex = 0);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFDFB76C),
                                    Color(0xFFB08D57),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33DFB76C),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.camera_alt_rounded,
                                    color: Color(0xFF14100D),
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'On-Cam',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF14100D),
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
                ),
              ),

              // Gender Tab Switcher
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1712),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0x33E4C590),
                        width: 0.8,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: const Color(0xFFE4C590),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: const Color(0xFF14100D),
                      unselectedLabelColor: const Color(0xFFA89989),
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      splashBorderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(3),
                      tabs: const [
                        Tab(text: 'Busana Pria'),
                        Tab(text: 'Busana Wanita'),
                      ],
                    ),
                  ),
                ),
              ),

              // Flagship Editorial Banners: AI Studio & AI Pakar Busana
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      // Banner 1: AI Photorealistic Fashion Studio
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            fadeSlideRoute(const AiFashionStudioScreen()),
                          ),
                          child: Container(
                            height: 104,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF2C1F16),
                                  Color(0xFF1E1510),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0x66DFB76C),
                                width: 1.0,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0x33DFB76C),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome_rounded,
                                        color: Color(0xFFDFB76C),
                                        size: 16,
                                      ),
                                    ),
                                    const Text(
                                      'FASHN AI',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFDFB76C),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI Fashion Studio',
                                      style: JText.serif(
                                        13,
                                        weight: FontWeight.w800,
                                        color: const Color(0xFFFAF6F0),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Virtual Try-On Model Nyata',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFB5A493),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Banner 2: AI Cultural Assistant
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            fadeSlideRoute(const AiCulturalAssistantScreen()),
                          ),
                          child: Container(
                            height: 104,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF261A28),
                                  Color(0xFF171019),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0x66DFB76C),
                                width: 1.0,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0x33DFB76C),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: Color(0xFFDFB76C),
                                        size: 16,
                                      ),
                                    ),
                                    const Text(
                                      'AI GUIDE',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFDFB76C),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Abdi Pakar Busana',
                                      style: JText.serif(
                                        13,
                                        weight: FontWeight.w800,
                                        color: const Color(0xFFFAF6F0),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Konsultasi Adat & Filosofi',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFB5A493),
                                      ),
                                    ),
                                  ],
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

              // Quick Access Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      _QuickAction(
                        icon: Icons.view_in_ar_rounded,
                        label: 'Studio 3D',
                        onTap: () => Navigator.of(context).push(
                          fadeSlideRoute(const JavaneseWardrobeScreen()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _QuickAction(
                        icon: Icons.layers_rounded,
                        label: 'Galeri Batik',
                        onTap: () => Navigator.of(context).push(
                          fadeSlideRoute(const BatikMotifGalleryScreen()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _QuickAction(
                        icon: Icons.map_rounded,
                        label: 'Peta Busana',
                        onTap: () => Navigator.of(context).push(
                          fadeSlideRoute(const JavaneseFashionMapScreen()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _QuickAction(
                        icon: Icons.school_rounded,
                        label: 'Sinau',
                        onTap: () => Navigator.of(context).push(
                          fadeSlideRoute(const SinauBusanaScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Setelan Busana Lengkap Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Setelan Busana Lengkap',
                        style: JText.serif(
                          14,
                          weight: FontWeight.w700,
                          color: const Color(0xFFFAF6F0),
                        ),
                      ),
                      InteractiveScale(
                        onTap: () => Navigator.of(context).push(
                          fadeSlideRoute(const JelajahiBusanaScreen()),
                        ),
                        child: Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE4C590),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Horizontal Outfit Cards
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredOutfits.length.clamp(0, 6),
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final outfit = _filteredOutfits[index];
                      return _OutfitPreviewCard(
                        outfit: outfit,
                        onTap: () => Navigator.of(context).push(
                          fadeSlideRoute(
                            JavaneseWardrobeScreen(initialOutfit: outfit),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Koleksi Busana Per Komponen
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Komponen Busana',
                    style: JText.serif(
                      14,
                      weight: FontWeight.w700,
                      color: const Color(0xFFFAF6F0),
                    ),
                  ),
                ),
              ),

              // Clothing Items Grid
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _filteredItems[index];
                      return _ClothingItemCard(
                        item: item,
                        onTap: () => Navigator.of(context).push(
                          fadeSlideRoute(
                            ClothingDetailScreen(item: item),
                          ),
                        ),
                      );
                    },
                    childCount: _filteredItems.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InteractiveScale(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        pressedScale: 0.93,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1712),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0x33E4C590),
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFFE4C590), size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC4B4A2),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutfitPreviewCard extends StatelessWidget {
  const _OutfitPreviewCard({
    required this.outfit,
    required this.onTap,
  });

  final TraditionalOutfit outfit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      borderRadius: 16,
      padding: EdgeInsets.zero,
      semanticLabel: outfit.title,
      backgroundColor: const Color(0xFF1E1712),
      border: Border.all(color: const Color(0x44E4C590), width: 0.8),
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF261C15),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x33E4C590),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      outfit.gender.label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE4C590),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    outfit.title,
                    style: JText.serif(
                      13,
                      weight: FontWeight.w700,
                      color: const Color(0xFFFAF6F0),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Body: era + origin
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      outfit.era,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC79B3A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      outfit.region.title,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFA89989),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.view_in_ar_rounded,
                          size: 12,
                          color: Color(0xFFE4C590),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Buka di Studio 3D',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE4C590),
                          ),
                        ),
                      ],
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
}

class _ClothingItemCard extends StatelessWidget {
  const _ClothingItemCard({
    required this.item,
    required this.onTap,
  });

  final ClothingItem item;
  final VoidCallback onTap;

  IconData get _categoryIcon {
    switch (item.category) {
      case ClothingCategory.headwear:
        return Icons.face_rounded;
      case ClothingCategory.upperBody:
        return Icons.checkroom_rounded;
      case ClothingCategory.lowerBody:
        return Icons.straighten_rounded;
      case ClothingCategory.accessories:
        return Icons.auto_awesome_rounded;
    }
  }

  String get _slotLabel {
    switch (item.category) {
      case ClothingCategory.headwear:
        return 'Penutup Kepala';
      case ClothingCategory.upperBody:
        return 'Busana Atas';
      case ClothingCategory.lowerBody:
        return 'Busana Bawah';
      case ClothingCategory.accessories:
        return 'Aksesoris';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: onTap,
      borderRadius: 16,
      padding: EdgeInsets.zero,
      semanticLabel: item.name,
      backgroundColor: const Color(0xFF1E1712),
      border: Border.all(color: const Color(0x33E4C590), width: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon placeholder for garment
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF261C15),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _categoryIcon,
                      size: 36,
                      color: const Color(0x88E4C590),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x22E4C590),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _slotLabel,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE4C590),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: JText.serif(
                    12.5,
                    weight: FontWeight.w700,
                    color: const Color(0xFFFAF6F0),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.region.title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFA89989),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

