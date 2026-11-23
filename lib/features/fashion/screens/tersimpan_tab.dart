import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme.dart';
import '../../../services/saved_garments_service.dart';
import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';

/// Tab Koleksi Tersimpan - Halaman terpisah khusus untuk melihat dan mengelola
/// seluruh item busana bookmark dan setelan pusaka yang telah disimpan pengguna.
class TersimpanTab extends StatefulWidget {
  const TersimpanTab({
    super.key,
    this.onOpenCatalog,
    this.onOpenWardrobe,
  });

  final VoidCallback? onOpenCatalog;
  final VoidCallback? onOpenWardrobe;

  @override
  State<TersimpanTab> createState() => _TersimpanTabState();
}

class _TersimpanTabState extends State<TersimpanTab> {
  // 0: Item Busana, 1: Setelan Pusaka
  int _activeSubTab = 0;

  @override
  void initState() {
    super.initState();
    SavedGarmentsService.instance.initialize();
  }

  void _removeGarment(ClothingItem item) {
    HapticFeedback.lightImpact();
    SavedGarmentsService.instance.toggleSave(item.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF241A14),
        behavior: SnackBarBehavior.floating,
        content: Text(
          '${item.name} dihapus dari koleksi tersimpan.',
          style: const TextStyle(color: Color(0xFFFAF6F0), fontSize: 12.5),
        ),
        action: SnackBarAction(
          label: 'Urungkan',
          textColor: JColors.antiqueGold,
          onPressed: () {
            SavedGarmentsService.instance.toggleSave(item.id);
          },
        ),
      ),
    );
  }

  void _deleteOutfit(SavedOutfit outfit) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1712),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x33DFB76C)),
        ),
        title: Text(
          'Hapus Setelan?',
          style: JText.editorial(16, weight: FontWeight.w700, color: const Color(0xFFFAF6F0)),
        ),
        content: Text(
          'Setelan "${outfit.customName}" akan dihapus dari koleksi tersimpan Anda.',
          style: JText.sans(12.5, color: const Color(0xFFD4C8B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: JText.sans(13, color: const Color(0xFFB0A290)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B251E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              SavedGarmentsService.instance.deleteOutfit(outfit.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 1400),
                  backgroundColor: const Color(0xFF241A14),
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    'Setelan "${outfit.customName}" dihapus.',
                    style: const TextStyle(color: Color(0xFFFAF6F0), fontSize: 12.5),
                  ),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: JBackground(
        variant: HeritageBackgroundVariant.wardrobe,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Header Khusus Koleksi Tersimpan
              _buildHeader(),

              // 2. Segment Switcher: Item Busana vs Setelan Pusaka
              _buildSubTabSwitcher(),

              // 3. Konten List Reaktif
              Expanded(
                child: _activeSubTab == 0
                    ? _buildSavedGarmentsList()
                    : _buildSavedOutfitsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF261D16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x33DFB76C)),
            ),
            child: const Icon(
              Icons.bookmark_rounded,
              color: JColors.antiqueGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Koleksi Tersimpan',
                  style: JText.editorial(
                    20,
                    weight: FontWeight.w700,
                    color: const Color(0xFFFAF6F0),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'ꦏꦺꦴꦭꦺꦏ꧀ꦱꦶꦠꦼꦂꦱꦶꦩ꧀ꦥꦤ꧀ • Pusaka & Setelan Favorit',
                  style: JText.sans(
                    11,
                    weight: FontWeight.w400,
                    color: const Color(0xFFB0A290),
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

  Widget _buildSubTabSwitcher() {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: SavedGarmentsService.instance.savedItemIdsNotifier,
      builder: (context, savedIds, _) {
        return ValueListenableBuilder<List<SavedOutfit>>(
          valueListenable: SavedGarmentsService.instance.savedOutfitsNotifier,
          builder: (context, savedOutfits, _) {
            final itemCount = savedIds.length;
            final outfitCount = savedOutfits.length;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1712),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x22DFB76C)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSubTabButton(
                      index: 0,
                      label: 'Item Busana',
                      count: itemCount,
                      isSelected: _activeSubTab == 0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildSubTabButton(
                      index: 1,
                      label: 'Setelan Pusaka',
                      count: outfitCount,
                      isSelected: _activeSubTab == 1,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubTabButton({
    required int index,
    required String label,
    required int count,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_activeSubTab != index) {
            HapticFeedback.selectionClick();
            setState(() => _activeSubTab = index);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2C2017) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0x66DFB76C) : Colors.transparent,
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: JText.sans(
                    12,
                    weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFFFFDF9E) : const Color(0xFF8F8073),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0x33DFB76C) : const Color(0x11FFFFFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: JText.sans(
                      10.5,
                      weight: FontWeight.w700,
                      color: isSelected ? const Color(0xFFFFDF9E) : const Color(0xFF8F8073),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedGarmentsList() {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: SavedGarmentsService.instance.savedItemIdsNotifier,
      builder: (context, savedIds, _) {
        final items = SavedGarmentsService.instance.getSavedClothingItems();

        if (items.isEmpty) {
          return _buildEmptyState(
            icon: Icons.bookmark_border_rounded,
            title: 'Belum Ada Busana Tersimpan',
            description:
                'Tandai busana adat favorit saat menjelajahi katalog Koleksi untuk menyimpannya ke daftar pusaka Anda.',
            ctaLabel: 'Jelajahi Koleksi Busana',
            onCtaTap: () => widget.onOpenCatalog?.call(),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).padding.bottom + 90,
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildGarmentCard(item);
          },
        );
      },
    );
  }

  Widget _buildGarmentCard(ClothingItem item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1712),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33DFB76C), width: 1.0),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Thumbnail Busana
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 76,
              height: 76,
              color: const Color(0xFF261D16),
              child: Image.asset(
                'assets/garments/${item.id}.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Image.asset(
                  item.imageAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Detail Teks & Aksi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: JText.serif(
                          14.5,
                          weight: FontWeight.w700,
                          color: const Color(0xFFFAF6F0),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      icon: const Icon(
                        Icons.bookmark_rounded,
                        color: JColors.antiqueGold,
                      ),
                      tooltip: 'Hapus dari Tersimpan',
                      onPressed: () => _removeGarment(item),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.region.title} • ${item.category.label}',
                  style: JText.sans(
                    11,
                    weight: FontWeight.w600,
                    color: const Color(0xFFDFB76C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.philosophicalMeaning,
                  style: JText.sans(
                    11,
                    weight: FontWeight.w400,
                    color: const Color(0xFFB0A290),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Tombol Coba di Wardrobe
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      SavedGarmentsService.instance.requestEquip(item);
                      widget.onOpenWardrobe?.call();
                    },
                    icon: const Icon(Icons.checkroom_outlined, size: 14),
                    label: const Text('Coba di Wardrobe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E2218),
                      foregroundColor: const Color(0xFFFFDF9E),
                      elevation: 0,
                      side: const BorderSide(color: Color(0x66DFB76C), width: 0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
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

  Widget _buildSavedOutfitsList() {
    return ValueListenableBuilder<List<SavedOutfit>>(
      valueListenable: SavedGarmentsService.instance.savedOutfitsNotifier,
      builder: (context, outfits, _) {
        if (outfits.isEmpty) {
          return _buildEmptyState(
            icon: Icons.checkroom_outlined,
            title: 'Belum Ada Setelan Tersimpan',
            description:
                'Kombinasikan atasan, bawahan, dan aksesori di Wardrobe Kanvas Gaya lalu simpan setelan kreasi Anda di sini.',
            ctaLabel: 'Rancang di Wardrobe',
            onCtaTap: () => widget.onOpenWardrobe?.call(),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).padding.bottom + 90,
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: outfits.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final outfit = outfits[index];
            return _buildOutfitCard(outfit);
          },
        );
      },
    );
  }

  Widget _buildOutfitCard(SavedOutfit outfit) {
    final head = JavaneseClothingData.getItemById(outfit.headwearId);
    final upper = JavaneseClothingData.getItemById(outfit.upperBodyId);
    final lower = JavaneseClothingData.getItemById(outfit.lowerBodyId);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1712),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33DFB76C), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outfit.customName,
                      style: JText.serif(
                        15,
                        weight: FontWeight.w700,
                        color: const Color(0xFFFAF6F0),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${outfit.gender.label} • Keselarasan Budaya: ${'★' * outfit.harmonyRating}',
                      style: JText.sans(
                        11,
                        weight: FontWeight.w600,
                        color: const Color(0xFFDFB76C),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF8F8073)),
                tooltip: 'Hapus Setelan',
                onPressed: () => _deleteOutfit(outfit),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0x22DFB76C)),

          // Rincian Komponen Busana
          if (head != null) _buildOutfitLayerRow('Kepala', head.name),
          if (upper != null) _buildOutfitLayerRow('Atasan', upper.name),
          if (lower != null) _buildOutfitLayerRow('Bawahan', lower.name),

          const SizedBox(height: 10),

          // Tombol Terapkan ke Kanvas Wardrobe
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                SavedGarmentsService.instance.requestApplyOutfit(outfit);
                widget.onOpenWardrobe?.call();
              },
              icon: const Icon(Icons.palette_outlined, size: 15),
              label: const Text('Terapkan ke Wardrobe Kanvas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: JColors.antiqueGold,
                foregroundColor: const Color(0xFF14100D),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitLayerRow(String category, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0x1ADFB76C),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              category,
              style: JText.sans(
                9.5,
                weight: FontWeight.w700,
                color: const Color(0xFFDFB76C),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: JText.sans(
                11.5,
                weight: FontWeight.w500,
                color: const Color(0xFFE8E0D5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    required String ctaLabel,
    required VoidCallback onCtaTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0x1ADFB76C),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x33DFB76C), width: 1.2),
              ),
              child: Icon(
                icon,
                size: 32,
                color: const Color(0xFFDFB76C),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: JText.editorial(
                17,
                weight: FontWeight.w700,
                color: const Color(0xFFFAF6F0),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: JText.sans(
                12,
                weight: FontWeight.w400,
                color: const Color(0xFFB0A290),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: JColors.antiqueGold,
                foregroundColor: const Color(0xFF14100D),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onCtaTap,
              child: Text(
                ctaLabel,
                style: JText.sans(12.5, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
