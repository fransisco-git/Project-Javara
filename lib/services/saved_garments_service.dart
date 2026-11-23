import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/fashion/data/javanese_clothing_data.dart';
import '../features/fashion/models/javanese_clothing_models.dart';
import 'supabase_service.dart';

/// Layanan reaktif terpadu untuk item & setelan busana yang disimpan pengguna.
/// Menghubungkan aksi simpan/bookmark dari Koleksi (katalog & detail)
/// langsung ke layar Wardrobe secara instan tanpa perlu reload.
class SavedGarmentsService {
  SavedGarmentsService._();
  static final SavedGarmentsService instance = SavedGarmentsService._();

  static const String _prefKeyFavorites = 'javara_user_favorites';
  static const String _prefKeySavedOutfits = 'javara_saved_outfits';

  SharedPreferences? _prefs;

  /// Notifier reaktif untuk daftar ID busana yang disimpan.
  final ValueNotifier<Set<String>> savedItemIdsNotifier =
      ValueNotifier<Set<String>>({});

  /// Notifier reaktif untuk daftar setelan kreasi pengguna.
  final ValueNotifier<List<SavedOutfit>> savedOutfitsNotifier =
      ValueNotifier<List<SavedOutfit>>([]);

  /// Request reaktif untuk memasang busana ke Kanvas Wardrobe dari layar lain.
  final ValueNotifier<ClothingItem?> requestedEquipGarmentNotifier =
      ValueNotifier<ClothingItem?>(null);

  /// Request reaktif untuk menerapkan setelan ke Kanvas Wardrobe dari layar lain.
  final ValueNotifier<SavedOutfit?> requestedEquipOutfitNotifier =
      ValueNotifier<SavedOutfit?>(null);

  /// Meminta Wardrobe memasang busana tertentu ke kanvas.
  void requestEquip(ClothingItem item) {
    requestedEquipGarmentNotifier.value = item;
  }

  /// Meminta Wardrobe menerapkan setelan ke kanvas.
  void requestApplyOutfit(SavedOutfit outfit) {
    requestedEquipOutfitNotifier.value = outfit;
  }

  bool _initialized = false;

  /// Inisialisasi awal membaca dari penyimpanan lokal dan Supabase.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (_) {}

    // 1. Baca item tersimpan lokal
    final localFavorites = _prefs?.getStringList(_prefKeyFavorites) ?? [];
    savedItemIdsNotifier.value = localFavorites.toSet();

    // 2. Baca setelan tersimpan lokal
    final localOutfitsRaw = _prefs?.getStringList(_prefKeySavedOutfits) ?? [];
    final loadedOutfits = <SavedOutfit>[];
    for (final raw in localOutfitsRaw) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        loadedOutfits.add(SavedOutfit.fromJson(decoded));
      } catch (_) {}
    }
    savedOutfitsNotifier.value = loadedOutfits;

    _initialized = true;

    // 3. Sinkronisasi dengan Supabase di latar belakang
    _syncWithSupabase();
  }

  Future<void> _syncWithSupabase() async {
    try {
      final remoteFavs = await SupabaseService.instance.getFavoriteItemIds();
      if (remoteFavs.isNotEmpty) {
        final merged = {...savedItemIdsNotifier.value, ...remoteFavs};
        savedItemIdsNotifier.value = merged;
        await _prefs?.setStringList(_prefKeyFavorites, merged.toList());
      }
    } catch (_) {}
  }

  /// Cek apakah suatu item tersimpan di Wardrobe.
  bool isSaved(String itemId) {
    return savedItemIdsNotifier.value.contains(itemId);
  }

  /// Toggle simpan/hapus item busana ke Wardrobe.
  Future<bool> toggleSave(String itemId) async {
    await initialize();

    final current = Set<String>.from(savedItemIdsNotifier.value);
    final willSave = !current.contains(itemId);

    if (willSave) {
      current.add(itemId);
    } else {
      current.remove(itemId);
    }

    savedItemIdsNotifier.value = current;
    try {
      await _prefs?.setStringList(_prefKeyFavorites, current.toList());
    } catch (_) {}

    // Teruskan ke SupabaseService untuk persistensi remote
    SupabaseService.instance.toggleFavorite(itemId).catchError((_) => false);

    return willSave;
  }

  /// Mengambil daftar objek `ClothingItem` dari item yang tersimpan.
  List<ClothingItem> getSavedClothingItems() {
    final ids = savedItemIdsNotifier.value;
    return JavaneseClothingData.clothingItems
        .where((item) => ids.contains(item.id))
        .toList();
  }

  /// Menyimpan setelan paduan busana baru ke `Setelan Saya`.
  Future<void> saveOutfit(SavedOutfit outfit) async {
    await initialize();

    final list = List<SavedOutfit>.from(savedOutfitsNotifier.value);
    list.removeWhere((o) => o.id == outfit.id);
    list.insert(0, outfit);

    savedOutfitsNotifier.value = list;

    final raw = list.map((o) => jsonEncode(o.toJson())).toList();
    try {
      await _prefs?.setStringList(_prefKeySavedOutfits, raw);
    } catch (_) {}

    // Sync ke Supabase
    SupabaseService.instance.saveCustomOutfit(outfit).catchError((_) {});
  }

  /// Menghapus setelan tersimpan.
  Future<void> deleteOutfit(String outfitId) async {
    await initialize();

    final list = List<SavedOutfit>.from(savedOutfitsNotifier.value)
      ..removeWhere((o) => o.id == outfitId);

    savedOutfitsNotifier.value = list;

    final raw = list.map((o) => jsonEncode(o.toJson())).toList();
    try {
      await _prefs?.setStringList(_prefKeySavedOutfits, raw);
    } catch (_) {}
  }
}
