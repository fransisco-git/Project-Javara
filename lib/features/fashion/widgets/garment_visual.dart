import 'package:flutter/material.dart';

import '../models/javanese_clothing_models.dart';

/// Tile fallback tipografi aksara Jawa datar untuk item busana tanpa foto.
///
/// Menggunakan latar datar [ClothingItem.primaryColor] (tanpa gradasi/ornamen
/// dan tanpa ikon) dengan aksara Jawa [ClothingItem.javaneseScript] di tengah
/// berwarna [ClothingItem.accentColor].
class GarmentTypographyFallback extends StatelessWidget {
  const GarmentTypographyFallback({
    super.key,
    required this.item,
    this.fontSize = 26.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  final ClothingItem item;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: item.primaryColor,
      child: Padding(
        padding: padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : 160.0;
            return Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Text(
                    item.javaneseScript,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: fontSize,
                      height: 1.5,
                      color: item.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Penampil visual busana bersama (Grid, List, dan Hero Detail).
///
/// Prioritas sumber gambar:
/// 1. [ClothingItem.assetImagePath] jika non-null dan non-empty.
/// 2. [ClothingItem.photoAsset] (`assets/koleksi/<id>.jpg`).
/// 3. Jika aset tidak ditemukan, menampilkan [GarmentTypographyFallback].
///
/// [photoOverlay] hanya dirender ketika gambar berhasil dimuat, sehingga tile
/// tipografi datar tetap bersih tanpa scrim/gradasi tambahan.
class GarmentPhotoVisual extends StatelessWidget {
  const GarmentPhotoVisual({
    super.key,
    required this.item,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.medium,
    this.fallbackFontSize = 26.0,
    this.fallbackPadding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 10,
    ),
    this.photoOverlay,
  });

  final ClothingItem item;
  final AlignmentGeometry alignment;
  final FilterQuality filterQuality;
  final double fallbackFontSize;
  final EdgeInsetsGeometry fallbackPadding;
  final Widget? photoOverlay;

  String get effectiveAssetPath {
    final explicit = item.assetImagePath;
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }
    return item.photoAsset;
  }

  @override
  Widget build(BuildContext context) {
    final path = effectiveAssetPath;
    return Image.asset(
      path,
      key: ValueKey(path),
      fit: BoxFit.cover,
      alignment: alignment,
      filterQuality: filterQuality,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        final hasFrame = wasSynchronouslyLoaded || frame != null;
        if (!hasFrame || photoOverlay == null) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            photoOverlay!,
          ],
        );
      },
      errorBuilder: (_, _, _) => GarmentTypographyFallback(
        item: item,
        fontSize: fallbackFontSize,
        padding: fallbackPadding,
      ),
    );
  }
}
