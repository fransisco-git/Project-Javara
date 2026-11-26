import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../../core/theme.dart';
import '../../../core/transitions.dart';
import '../../../services/saved_garments_service.dart';
import '../../heritage/culture_detail_screen.dart';
import '../../home/javara_bottom_nav.dart';
import '../models/javanese_clothing_models.dart';
import '../widgets/garment_visual.dart';
import 'clothing_detail_screen.dart';

/// Tab Koleksi Tersimpan - Halaman terpisah khusus untuk melihat dan mengelola
/// seluruh item busana yang telah disimpan pengguna.
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
  @override
  void initState() {
    super.initState();
    SavedGarmentsService.instance.initialize();
  }

  void _removeSavedEntry(SavedGarmentEntry entry) {
    HapticFeedback.lightImpact();
    SavedGarmentsService.instance.toggleSave(entry.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF241A14),
        behavior: SnackBarBehavior.floating,
        content: Text(
          '${entry.title} dihapus dari koleksi tersimpan.',
          style: const TextStyle(color: Color(0xFFFAF6F0), fontSize: 12.5),
        ),
        action: SnackBarAction(
          label: 'Urungkan',
          textColor: JColors.antiqueGold,
          onPressed: () {
            SavedGarmentsService.instance.toggleSave(entry.id);
          },
        ),
      ),
    );
  }

  void _openEntryDetail(SavedGarmentEntry entry) {
    HapticFeedback.selectionClick();
    final clothing = entry.clothingItem;
    if (clothing != null) {
      Navigator.of(context).push(
        fadeSlideRoute(ClothingDetailScreen(item: clothing)),
      );
      return;
    }
    final culture = entry.cultureItem;
    if (culture != null) {
      Navigator.of(context).push(
        fadeSlideRoute(CultureDetailScreen(item: culture)),
      );
    }
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
              _buildHeader(),
              _buildSavedItemsBar(),
              Expanded(
                child: _buildSavedGarmentsList(),
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
                  'ꦏꦺꦴꦭꦺꦏ꧀ꦱꦶꦠꦼꦂꦱꦶꦩ꧀ꦥꦤ꧀ • Item Busana Favorit',
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

  Widget _buildSavedItemsBar() {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: SavedGarmentsService.instance.savedItemIdsNotifier,
      builder: (context, savedIds, _) {
        final itemCount = SavedGarmentsService.instance.getSavedEntries().length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            children: [
              Text(
                'Item Busana',
                style: JText.sans(
                  12.5,
                  weight: FontWeight.w700,
                  color: const Color(0xFFFFDF9E),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x2ADFB76C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x44DFB76C), width: 0.8),
                ),
                child: Text(
                  '$itemCount',
                  style: JText.sans(
                    10.5,
                    weight: FontWeight.w700,
                    color: const Color(0xFFFFDF9E),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedGarmentsList() {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: SavedGarmentsService.instance.savedItemIdsNotifier,
      builder: (context, savedIds, _) {
        final entries = SavedGarmentsService.instance.getSavedEntries();

        if (entries.isEmpty) {
          return _buildEmptyState(
            icon: Icons.bookmark_border_rounded,
            title: 'Belum Ada Busana Tersimpan',
            description:
                'Tandai busana adat favorit di Beranda atau katalog Koleksi untuk menyimpannya ke daftar pusaka Anda.',
            ctaLabel: 'Jelajahi Koleksi Busana',
            onCtaTap: () => widget.onOpenCatalog?.call(),
          );
        }

        return ListView.separated(
          scrollCacheExtent: const ScrollCacheExtent.pixels(400),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            JavaraBottomNav.contentBottomPadding(context),
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return RepaintBoundary(child: _buildSavedCard(entry));
          },
        );
      },
    );
  }

  Widget _buildSavedThumbnail(SavedGarmentEntry entry) {
    final clothing = entry.clothingItem;
    if (clothing != null) {
      return GarmentPhotoVisual(
        item: clothing,
        alignment: Alignment.topCenter,
        fallbackFontSize: 15,
        fallbackPadding: const EdgeInsets.all(6),
      );
    }

    final culture = entry.cultureItem!;
    final thumbCacheWidth = (76 * MediaQuery.devicePixelRatioOf(context))
        .round()
        .clamp(120, 320);

    return Image.asset(
      culture.imageAssetPath,
      key: ValueKey(culture.imageAssetPath),
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      cacheWidth: thumbCacheWidth,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: Color(0xFF181512),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: Color(0x44B89B67),
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCard(SavedGarmentEntry entry) {
    final ClothingItem? clothing = entry.clothingItem;
    return Material(
      color: const Color(0xFF1E1712),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openEntryDetail(entry),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x33DFB76C), width: 1.0),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Thumbnail Busana (identik dengan Koleksi & Beranda)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: ColoredBox(
                    color: const Color(0xFF261D16),
                    child: _buildSavedThumbnail(entry),
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
                            entry.title,
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
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: const Icon(
                            Icons.bookmark_rounded,
                            color: JColors.antiqueGold,
                          ),
                          tooltip: 'Hapus dari Tersimpan',
                          onPressed: () => _removeSavedEntry(entry),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle,
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
                      entry.description,
                      style: JText.sans(
                        11,
                        weight: FontWeight.w400,
                        color: const Color(0xFFB0A290),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (clothing != null && widget.onOpenWardrobe != null) ...[
                      const SizedBox(height: 8),

                      // Tombol Coba di Wardrobe
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            SavedGarmentsService.instance.requestEquip(clothing);
                            widget.onOpenWardrobe?.call();
                          },
                          icon: const Icon(Icons.checkroom_outlined, size: 14),
                          label: const Text('Coba di Wardrobe'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E2218),
                            foregroundColor: const Color(0xFFFFDF9E),
                            elevation: 0,
                            side: const BorderSide(
                              color: Color(0x66DFB76C),
                              width: 0.8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
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
