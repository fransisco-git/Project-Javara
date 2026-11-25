import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../data/culture_items.dart';
import '../../data/shop_data.dart';
import '../../widgets/photo_box.dart';
import '../heritage/cultural_order_sheet.dart';
import '../fashion/screens/my_heritage_collection_screen.dart';
import '../../widgets/interactive_feedback.dart';

/// Tab Favorit - Implementasi asli dari Figma Page 2 ('favorit.png').
/// Menampilkan daftar item yang disukai pengguna beserta filter chip kategori
/// (Semua, Makanan, Pakaian, Kerajinan, Event, Artikel).
class FavoritTab extends StatefulWidget {
  const FavoritTab({super.key, required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  @override
  State<FavoritTab> createState() => _FavoritTabState();
}

class _FavoritTabState extends State<FavoritTab> {
  late final List<FavoriteItem> _favorites;
  String _activeFilter = 'Semua';

  static const _filters = [
    'Semua',
    'Busana',
    'Batik',
    'Aksesoris',
  ];

  @override
  void initState() {
    super.initState();
    _favorites = initialFavorites();
  }

  List<FavoriteItem> get _filteredFavorites {
    if (_activeFilter == 'Semua') {
      return _favorites.where((f) => f.isFavorited).toList();
    }
    return _favorites
        .where(
          (f) =>
              f.isFavorited &&
              f.category.toUpperCase() == _activeFilter.toUpperCase(),
        )
        .toList();
  }

  void _removeFavorite(FavoriteItem item) {
    HapticFeedback.lightImpact();
    setState(() {
      item.isFavorited = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.title} dihapus dari favorit.'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Urungkan',
          textColor: JColors.gold,
          onPressed: () {
            setState(() {
              item.isFavorited = true;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredFavorites;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
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
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      color: JColors.ink,
                    ),
                    Text(
                      'Favorit',
                      style: JText.serif(
                        17.5,
                        weight: FontWeight.w700,
                        color: JColors.ink,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Menampilkan ${_filteredFavorites.length} item favorit Anda.',
                              style: JText.serif(13, color: Colors.white),
                            ),
                            backgroundColor: const Color(0xFF2E2019),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bookmark_border_rounded, size: 22),
                      color: JColors.ink,
                    ),
                  ],
                ),
              ),

              // Banner Akses Cepat Koleksi Pusaka 3D Busana Adat
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).push(
                    fadeSlideRoute(const MyHeritageCollectionScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2016),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x66DFB76C), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0x33DFB76C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.checkroom_rounded,
                            color: Color(0xFFFFDF9E),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Koleksi Pusaka Saya',
                                style: JText.serif(
                                  13,
                                  weight: FontWeight.w700,
                                  color: const Color(0xFFFAF6F0),
                                ),
                              ),
                              const Text(
                                'Setelan busana adat tersimpan di koleksi pribadi',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFC7B7A6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Color(0xFFDFB76C),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Filter Chips (Semua, Makanan, Pakaian, dst.)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((filter) {
                    final isActive = _activeFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          filter,
                          style: JText.serif(
                            12.5,
                            weight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive ? JColors.cream : JColors.ink,
                          ),
                        ),
                        selected: isActive,
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          setState(() => _activeFilter = filter);
                        },
                        backgroundColor: const Color(0xFFF4E9D8),
                        selectedColor: JColors.button,
                        checkmarkColor: JColors.gold,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isActive
                                ? JColors.button
                                : const Color(0xFFDEC5A4),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Daftar Item Favorit
              Expanded(
                child: JavaraPullRefresh(
                  onRefresh: () async {
                    HapticFeedback.mediumImpact();
                    await Future.delayed(const Duration(milliseconds: 700));
                    if (mounted) setState(() {});
                  },
                  child: items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 80,
                                left: 32,
                                right: 32,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.favorite_border_rounded,
                                    size: 48,
                                    color: JColors.sand,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _activeFilter == 'Semua'
                                        ? 'Belum ada item favorit.'
                                        : 'Tidak ada favorit untuk kategori $_activeFilter.',
                                    textAlign: TextAlign.center,
                                    style: JText.serif(
                                      14.5,
                                      color: JColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () => widget.onOpenTab(1),
                                    child: Text(
                                      'Jelajahi Warisan Budaya',
                                      style: JText.serif(
                                        13,
                                        weight: FontWeight.w600,
                                        color: JColors.terracotta,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _buildFavoritCard(item);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritCard(FavoriteItem item) {
    final catColor = switch (item.category) {
      'BUSANA' => const Color(0xFFC79B3A),
      'BATIK' => const Color(0xFF8C5835),
      'AKSESORIS' => const Color(0xFF5A3A25),
      _ => JColors.muted,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          final cultureItem = CultureItem(
            id: item.id,
            title: item.title,
            tag: item.category,
            meta: item.subtitle,
            image: item.image,
            price: item.subtitle.startsWith('Rp') ? item.subtitle : null,
            description:
                'Karya busana autentik khas Jawa Tengah: ${item.title}. Menjaga pakem tradisi turun-temurun.',
            history:
                'Warisan busana adiluhung yang telah ada sejak berabad-abad di tanah Jawa.',
            location: 'Jawa Tengah',
            regency: 'Jawa Tengah',
            highlights: const [
              '100% Orisinal Lokal',
              'Kain & Jahitan Halus',
              'Sesuai Pakem Tradisi',
            ],
          );
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CulturalOrderSheet(item: cultureItem),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF9),
            borderRadius: BorderRadius.circular(14),
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
                      item.category,
                      style: JText.serif(
                        9.5,
                        weight: FontWeight.w700,
                        color: catColor,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.subtitle,
                      style: JText.serif(12, color: JColors.muted),
                    ),
                  ],
                ),
              ),
              // Tombol hapus favorit
              IconButton(
                onPressed: () => _removeFavorite(item),
                icon: const Icon(Icons.favorite_rounded, size: 22),
                color: JColors.terracotta,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
