import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme.dart';
import '../../../core/transitions.dart';
import '../../../services/saved_garments_service.dart';
import '../../home/javara_bottom_nav.dart';
import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';
import '../widgets/garment_visual.dart';
import 'clothing_detail_screen.dart';

/// Screen 02 — Katalog Busana Tradisional Jawa Tengah (UNIQLO x ZARA Editorial)
///
/// Memadukan kejelasan struktur katalog busana (penataan anatomi, kategori jelas,
/// spesifikasi material terperinci) dengan estetika editorial mode mewah berskala museum.
class ClothingCatalogScreen extends StatefulWidget {
  const ClothingCatalogScreen({
    super.key,
    this.isTab = false,
    this.initialCategory,
    this.initialGender,
    this.initialRegion,
  });

  final bool isTab;
  final ClothingCategory? initialCategory;
  final GenderTarget? initialGender;
  final TraditionRegion? initialRegion;

  @override
  State<ClothingCatalogScreen> createState() => _ClothingCatalogScreenState();
}

class _ClothingCatalogScreenState extends State<ClothingCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mode Tampilan: Grid Editorial vs List Detail
  bool _isGridView = true;

  // Filter Terpilih
  ClothingCategory? _selectedCategory;
  GenderTarget? _selectedGender;
  TraditionRegion? _selectedRegion;
  bool _showCuratedOutfitsOnly = false;

  // Status Favorit
  Set<String> _favoriteIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedGender = widget.initialGender;
    _selectedRegion = widget.initialRegion;
    _loadFavorites();
    SavedGarmentsService.instance.savedItemIdsNotifier.addListener(_onSavedIdsChanged);
  }

  void _onSavedIdsChanged() {
    if (!mounted) return;
    setState(() {
      _favoriteIds = SavedGarmentsService.instance.savedItemIdsNotifier.value;
    });
  }

  @override
  void dispose() {
    SavedGarmentsService.instance.savedItemIdsNotifier.removeListener(_onSavedIdsChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    await SavedGarmentsService.instance.initialize();
    if (mounted) {
      setState(() {
        _favoriteIds = SavedGarmentsService.instance.savedItemIdsNotifier.value;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(String id) async {
    HapticFeedback.lightImpact();
    final isSaved = await SavedGarmentsService.instance.toggleSave(id);
    if (mounted) {
      setState(() {
        if (isSaved) {
          _favoriteIds.add(id);
        } else {
          _favoriteIds.remove(id);
        }
      });
      final item = JavaneseClothingData.getItemById(id);
      final name = item?.name ?? 'Busana';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1400),
          backgroundColor: const Color(0xFF241A14),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0x55E4C590), width: 0.8),
          ),
          content: Text(
            isSaved ? '$name disimpan ke Wardrobe' : '$name dihapus dari Wardrobe',
            style: const TextStyle(color: Color(0xFFFAF6F0), fontSize: 12.5),
          ),
        ),
      );
    }
  }

  List<ClothingItem> _getFilteredItems() {
    return JavaneseClothingData.clothingItems.where((item) {
      // Filter Kategori
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      // Filter Gender
      if (_selectedGender != null &&
          item.gender != _selectedGender &&
          item.gender != GenderTarget.unisex) {
        return false;
      }
      // Filter Wilayah
      if (_selectedRegion != null && item.region != _selectedRegion) {
        return false;
      }
      // Pencarian Teks
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = item.name.toLowerCase().contains(q);
        final matchJawa = item.javaneseScript.contains(q);
        final matchRegion = item.region.title.toLowerCase().contains(q);
        final matchMaterial = item.material.toLowerCase().contains(q);
        final matchPhilosophy =
            item.philosophicalMeaning.toLowerCase().contains(q);
        if (!matchName &&
            !matchJawa &&
            !matchRegion &&
            !matchMaterial &&
            !matchPhilosophy) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<TraditionalOutfit> _getFilteredOutfits() {
    return JavaneseClothingData.curatedOutfits.where((outfit) {
      // Filter Gender
      if (_selectedGender != null &&
          outfit.gender != _selectedGender &&
          outfit.gender != GenderTarget.unisex) {
        return false;
      }
      // Filter Wilayah
      if (_selectedRegion != null && outfit.region != _selectedRegion) {
        return false;
      }
      // Pencarian Teks
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = outfit.title.toLowerCase().contains(q);
        final matchJawa = outfit.javaneseScript.contains(q);
        final matchRegion = outfit.region.title.toLowerCase().contains(q);
        final matchSummary = outfit.summary.toLowerCase().contains(q);
        if (!matchTitle && !matchJawa && !matchRegion && !matchSummary) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  int get _activeFilterCount {
    var count = 0;
    if (_selectedCategory != null) count++;
    if (_selectedGender != null) count++;
    if (_selectedRegion != null) count++;
    if (_showCuratedOutfitsOnly) count++;
    return count;
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedGender = null;
      _selectedRegion = null;
      _showCuratedOutfitsOnly = false;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();
    final filteredOutfits = _getFilteredOutfits();
    final totalCount = _showCuratedOutfitsOnly
        ? filteredOutfits.length
        : filteredItems.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: JBackground(
        variant: HeritageBackgroundVariant.wardrobe,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. TOP EDITORIAL APP BAR
              _buildTopBar(context),

              // 2. SEARCH & CONTROLS BAR
              _buildSearchAndControlsBar(totalCount),

              // 3. CATEGORY SCROLL PILLS
              _buildCategoryPillRow(),

              const SizedBox(height: 8),

              // 4. MAIN CONTENT CATALOG VIEW
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFDFB76C),
                          strokeWidth: 2,
                        ),
                      )
                    : totalCount == 0
                        ? _buildEmptyState()
                        : _showCuratedOutfitsOnly
                            ? _buildOutfitsList(filteredOutfits)
                            : _isGridView
                                ? _buildItemsGrid(filteredItems)
                                : _buildItemsList(filteredItems),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// App Bar Atas Bergaya Editorial Museum Mode
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!widget.isTab)
            CircleAvatar(
              backgroundColor: const Color(0x20B08D57),
              radius: 18,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Color(0xFF382315),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'KATALOG BUSANA ADAT',
                    style: JText.editorial(
                      18,
                      weight: FontWeight.w700,
                      color: const Color(0xFF382315),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Text(
                  'ꦏꦠꦭꦺꦴꦒ꧀ꦧꦸꦱꦤꦗꦮꦶ',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF7D6C5D),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isTab) const SizedBox(width: 36),
        ],
      ),
    );
  }

  /// Bar Pencarian & Tombol Pengaturan Filter / Tampilan
  Widget _buildSearchAndControlsBar(int resultCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              // Kolom Pencarian Teks
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0x33B08D57),
                      width: 0.8,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF382315),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari busana, makna, serat, wilayah...',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8C7B6D),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: Color(0xFFB08D57),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Color(0xFFB08D57),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Tombol Buka Sheet Filter
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: _activeFilterCount > 0
                          ? const Color(0xFFB08D57)
                          : const Color(0xFFFFFDF9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0x33B08D57),
                        width: 0.8,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: _activeFilterCount > 0
                            ? const Color(0xFFFFFDF9)
                            : const Color(0xFF382315),
                      ),
                      onPressed: _showFilterBottomSheet,
                    ),
                  ),
                  if (_activeFilterCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFB5603A),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_activeFilterCount',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),

              // Tombol Toggle Tampilan Grid / List
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0x33B08D57),
                    width: 0.8,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    _isGridView
                        ? Icons.view_agenda_outlined
                        : Icons.grid_view_rounded,
                    size: 20,
                    color: const Color(0xFF382315),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isGridView = !_isGridView);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Info Total & Reset Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Menampilkan $resultCount warisan busana adat',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5C4632),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_activeFilterCount > 0 || _searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: _resetFilters,
                  child: const Text(
                    'Reset Filter',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6E5019),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Barisan Chip Kategori Anatomi Busana
  Widget _buildCategoryPillRow() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Semua Koleksi
          _buildCategoryPill(
            label: 'Semua Busana',
            isSelected: _selectedCategory == null && !_showCuratedOutfitsOnly,
            onTap: () {
              setState(() {
                _selectedCategory = null;
                _showCuratedOutfitsOnly = false;
              });
            },
          ),
          const SizedBox(width: 8),
          // 2. Setelan Lengkap (Curated Outfits)
          _buildCategoryPill(
            label: 'Setelan Lengkap Adat',
            icon: Icons.style_rounded,
            isSelected: _showCuratedOutfitsOnly,
            onTap: () {
              setState(() {
                _showCuratedOutfitsOnly = true;
                _selectedCategory = null;
              });
            },
          ),
          const SizedBox(width: 8),
          // 3. Kategori Anatomi Satuan
          for (final cat in ClothingCategory.values) ...[
            _buildCategoryPill(
              label: cat.label.split('(').first.trim(),
              icon: cat.icon,
              isSelected: !_showCuratedOutfitsOnly && _selectedCategory == cat,
              onTap: () {
                setState(() {
                  _showCuratedOutfitsOnly = false;
                  _selectedCategory = cat;
                });
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryPill({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF382315)
              : const Color(0xFFFFFDF9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB08D57)
                : const Color(0x33B08D57),
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? const Color(0xFFFFDF9E)
                    : const Color(0xFF382315),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFFFFDF9E)
                    : const Color(0xFF382315),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tampilan Grid Editorial 2 Kolom (ZARA Editorial Layout)
  Widget _buildItemsGrid(List<ClothingItem> items) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        widget.isTab
            ? JavaraBottomNav.contentBottomPadding(context)
            : MediaQuery.paddingOf(context).bottom + 24,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.64,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isFav = _favoriteIds.contains(item.id);

        return _buildGarmentGridCard(item, isFav);
      },
    );
  }

  /// Kartu Grid Busana Editorial
  Widget _buildGarmentGridCard(ClothingItem item, bool isFav) {
    final genderShort = item.gender.label.split('(').first.trim();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          fadeSlideRoute(ClothingDetailScreen(item: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0x28B08D57),
            width: 0.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10382315),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar / Foto Busana atau Tile Tipografi Aksara Jawa
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: GarmentPhotoVisual(
                      item: item,
                      alignment: Alignment.topCenter,
                      fallbackFontSize: 26,
                      fallbackPadding: const EdgeInsets.fromLTRB(
                        12,
                        36,
                        12,
                        12,
                      ),
                      photoOverlay: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.28),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.32),
                            ],
                            stops: const [0.0, 0.28, 0.72, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Badge Asal Wilayah
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 40,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xCC14100D),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0x66DFB76C),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          item.region.title.split('(').first.trim(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFDF9E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  // Tombol Bookmark / Favorit
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(item.id),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xAA14100D),
                        child: Icon(
                          isFav
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 16,
                          color: isFav
                              ? const Color(0xFFDFB76C)
                              : const Color(0xFFC7B7A6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Metadata Ringkas Busana
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: JText.serif(
                        12.5,
                        weight: FontWeight.w800,
                        color: const Color(0xFF2C2219),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$genderShort · ${item.socialContext.label}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF5C4632),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  /// Tampilan List Detail (UNIQLO Technical Specs View)
  Widget _buildItemsList(List<ClothingItem> items) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        widget.isTab
            ? JavaraBottomNav.contentBottomPadding(context)
            : MediaQuery.paddingOf(context).bottom + 24,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final isFav = _favoriteIds.contains(item.id);

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              fadeSlideRoute(ClothingDetailScreen(item: item)),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0x28B08D57),
                width: 0.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10382315),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Thumbnail Gambar / Tipografi Aksara Jawa
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: GarmentPhotoVisual(
                      item: item,
                      alignment: Alignment.topCenter,
                      fallbackFontSize: 15,
                      fallbackPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Data Spesifikasi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x1F6E5019),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.category.label.split('(').first.trim(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6E5019),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isFav
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 18,
                              color: isFav
                                  ? const Color(0xFF7A5B21)
                                  : const Color(0xFF7D6C5D),
                            ),
                            onPressed: () => _toggleFavorite(item.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.name,
                        style: JText.serif(
                          13.5,
                          weight: FontWeight.w800,
                          color: const Color(0xFF2C2219),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.javaneseScript,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF5C4632),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.region.title} · ${item.socialContext.label}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF5C4632),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tampilan Setelan Lengkap Tradisional (Curated Outfits)
  Widget _buildOutfitsList(List<TraditionalOutfit> outfits) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        widget.isTab
            ? JavaraBottomNav.contentBottomPadding(context)
            : MediaQuery.paddingOf(context).bottom + 24,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: outfits.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final outfit = outfits[index];

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1712),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0x66DFB76C),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Header Model Busana Lengkap
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: const Color(0xFF261D16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        outfit.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFF2A2018),
                          child: const Center(
                            child: Icon(
                              Icons.style_rounded,
                              size: 48,
                              color: Color(0x66DFB76C),
                            ),
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 14,
                        right: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              outfit.javaneseScript,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFE4C590),
                              ),
                            ),
                            Text(
                              outfit.title,
                              style: JText.editorial(
                                18,
                                weight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outfit.summary,
                      style: JText.serif(
                        11.5,
                        color: const Color(0xFFC7B7A6),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${outfit.region.title} · ${outfit.era}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDFB76C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Tampilan Kosong Ketika Pencarian / Filter Tidak Menemukan Hasil
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: Color(0xFF7A5B21),
            ),
            const SizedBox(height: 16),
            Text(
              'Warisan Busana Tidak Ditemukan',
              style: JText.serif(
                16,
                weight: FontWeight.w700,
                color: const Color(0xFF2C2219),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba sesuaikan kata kunci atau atur ulang filter pencarian untuk menemukan koleksi busana adat Jawa Tengah lainnya.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF5C4632),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDFB76C),
                foregroundColor: const Color(0xFF14100D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _resetFilters,
              child: const Text(
                'Reset Semua Filter',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Sheet Filter Komprehensif (Wilayah, Gender, Kategori)
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1410),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0x44DFB76C),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saring Busana Adat',
                          style: JText.serif(
                            18,
                            weight: FontWeight.w800,
                            color: const Color(0xFFFFDF9E),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetFilters();
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(color: Color(0xFFDFB76C)),
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: Color(0x22DFB76C)),
                    const SizedBox(height: 10),

                    // Filter 1: Target Gender
                    const Text(
                      'PENGGUNA BUSANA (GENDER)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC7B7A6),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Semua Gender'),
                          selected: _selectedGender == null,
                          onSelected: (_) {
                            setState(() => _selectedGender = null);
                            setSheetState(() {});
                          },
                          selectedColor: const Color(0xFFDFB76C),
                          backgroundColor: const Color(0xFF261D17),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: _selectedGender == null
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: _selectedGender == null
                                ? const Color(0xFF14100D)
                                : const Color(0xFFFAF6F0),
                          ),
                        ),
                        for (final g in GenderTarget.values)
                          ChoiceChip(
                            label: Text(g.label.split('(').first.trim()),
                            selected: _selectedGender == g,
                            onSelected: (sel) {
                              setState(() => _selectedGender = sel ? g : null);
                              setSheetState(() {});
                            },
                            selectedColor: const Color(0xFFDFB76C),
                            backgroundColor: const Color(0xFF261D17),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: _selectedGender == g
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _selectedGender == g
                                  ? const Color(0xFF14100D)
                                  : const Color(0xFFFAF6F0),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Filter 2: Asal Wilayah Budaya
                    const Text(
                      'WILAYAH BUDAYA JAWA TENGAH',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC7B7A6),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Semua Daerah'),
                          selected: _selectedRegion == null,
                          onSelected: (_) {
                            setState(() => _selectedRegion = null);
                            setSheetState(() {});
                          },
                          selectedColor: const Color(0xFFDFB76C),
                          backgroundColor: const Color(0xFF261D17),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: _selectedRegion == null
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: _selectedRegion == null
                                ? const Color(0xFF14100D)
                                : const Color(0xFFFAF6F0),
                          ),
                        ),
                        for (final reg in TraditionRegion.values)
                          ChoiceChip(
                            label: Text(reg.title.split('(').first.trim()),
                            selected: _selectedRegion == reg,
                            onSelected: (sel) {
                              setState(() => _selectedRegion = sel ? reg : null);
                              setSheetState(() {});
                            },
                            selectedColor: const Color(0xFFDFB76C),
                            backgroundColor: const Color(0xFF261D17),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: _selectedRegion == reg
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _selectedRegion == reg
                                  ? const Color(0xFF14100D)
                                  : const Color(0xFFFAF6F0),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Tombol Terapkan
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDFB76C),
                          foregroundColor: const Color(0xFF14100D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Terapkan Saringan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

