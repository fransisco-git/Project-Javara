import 'dart:convert';
import 'package:flutter/services.dart';

import '../data/javanese_clothing_data.dart';
import '../models/javanese_clothing_models.dart';

/// Kategori filter untuk rel busana di Cermin Busana
enum GarmentRailCategory {
  atasan('Atasan', 'tops'),
  bawahan('Bawahan', 'bottoms'),
  lengkap('Busana Lengkap', 'one-pieces');

  const GarmentRailCategory(this.label, this.fashnCategory);
  final String label;
  final String fashnCategory;
}

/// Representasi entri busana di rel cermin busana.
class GarmentRailEntry {
  const GarmentRailEntry({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.category,
    required this.regionTitle,
    required this.philosophicalMeaning,
    this.clothingItem,
    this.outfit,
  });

  final String id;
  final String name;
  final String assetPath;
  final GarmentRailCategory category;
  final String regionTitle;
  final String philosophicalMeaning;
  final ClothingItem? clothingItem;
  final TraditionalOutfit? outfit;

  bool get isOutfit => outfit != null;

  /// Mengambil satu kalimat pertama dari makna filosofis.
  String get firstSentenceMeaning {
    final clean = philosophicalMeaning.trim();
    if (clean.isEmpty) return '';
    final dotSpaceIndex = clean.indexOf('. ');
    if (dotSpaceIndex != -1) {
      return '${clean.substring(0, dotSpaceIndex)}.';
    }
    final dotIndex = clean.indexOf('.');
    if (dotIndex != -1) {
      return clean.substring(0, dotIndex + 1);
    }
    return clean;
  }
}

/// Resolver aset busana untuk Cermin Busana.
/// Memeriksa AssetManifest dan HANYA mengembalikan entri yang benar-benar
/// memiliki file fisik di `assets/garments/<id>.png`.
/// Dilarang keras melakukan fallback ke imageAsset atau gambar lain.
class GarmentImageResolver {
  GarmentImageResolver({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static String assetPathForId(String id) => 'assets/garments/$id.png';

  /// Membaca manifest aset dan memfilter busana yang valid.
  Future<List<GarmentRailEntry>> resolveAvailableGarments() async {
    final availablePaths = await _loadManifestAssetKeys();
    final results = <GarmentRailEntry>[];

    // 1. Atasan (upperBodyItems -> tops)
    for (final item in JavaneseClothingData.upperBodyItems) {
      final expectedPath = assetPathForId(item.id);
      if (availablePaths.contains(expectedPath)) {
        results.add(
          GarmentRailEntry(
            id: item.id,
            name: item.name,
            assetPath: expectedPath,
            category: GarmentRailCategory.atasan,
            regionTitle: item.region.title,
            philosophicalMeaning: item.philosophicalMeaning,
            clothingItem: item,
          ),
        );
      }
    }

    // 2. Bawahan (lowerBodyItems -> bottoms)
    for (final item in JavaneseClothingData.lowerBodyItems) {
      final expectedPath = assetPathForId(item.id);
      if (availablePaths.contains(expectedPath)) {
        results.add(
          GarmentRailEntry(
            id: item.id,
            name: item.name,
            assetPath: expectedPath,
            category: GarmentRailCategory.bawahan,
            regionTitle: item.region.title,
            philosophicalMeaning: item.philosophicalMeaning,
            clothingItem: item,
          ),
        );
      }
    }

    // 3. Busana Lengkap (curatedOutfits -> one-pieces)
    for (final outfit in JavaneseClothingData.curatedOutfits) {
      final expectedPath = assetPathForId(outfit.id);
      if (availablePaths.contains(expectedPath)) {
        results.add(
          GarmentRailEntry(
            id: outfit.id,
            name: outfit.title,
            assetPath: expectedPath,
            category: GarmentRailCategory.lengkap,
            regionTitle: outfit.region.title,
            philosophicalMeaning: outfit.culturalPhilosophy,
            outfit: outfit,
          ),
        );
      }
    }

    return results;
  }

  Future<Set<String>> _loadManifestAssetKeys() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(_bundle);
      return manifest.listAssets().toSet();
    } catch (_) {
      try {
        final manifestJson = await _bundle.loadString('AssetManifest.json');
        final dynamic decoded = jsonDecode(manifestJson);
        if (decoded is Map<String, dynamic>) {
          return decoded.keys.toSet();
        }
        return <String>{};
      } catch (_) {
        return <String>{};
      }
    }
  }
}
