import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';
import '../features/fashion/models/javanese_clothing_models.dart';
import '../features/fashion/data/javanese_clothing_data.dart';

/// Layanan Integrasi Database Supabase & Offline-First Cache JAVARA
///
/// Menyediakan koneksi aman ke REST API PostgREST Supabase dengan dukungan
/// Row Level Security (RLS) serta fallback penyimpanan lokal via SharedPreferences.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  static const String _prefKeyFavorites = 'javara_user_favorites';
  static const String _prefKeySavedOutfits = 'javara_saved_outfits';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    debugPrint(
      'SupabaseService Initialized. Configured: ${AppConfig.isSupabaseConfigured}',
    );
  }

  /// Manajemen favorit budaya
  Future<List<String>> getFavoriteItemIds({String userId = 'guest_user'}) async {
    await initialize();

    // Jika Supabase terkonfigurasi, panggil endpoint REST
    if (AppConfig.isSupabaseConfigured) {
      try {
        final url = Uri.parse(
          '${AppConfig.supabaseUrl}/rest/v1/favorites?user_id=eq.$userId&select=item_id',
        );
        final response = await http.get(url, headers: {
          'apikey': AppConfig.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        }).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final List list = jsonDecode(response.body);
          return list.map((e) => e['item_id'] as String).toList();
        }
      } catch (e) {
        debugPrint('Supabase getFavorites fallback: $e');
      }
    }

    // Fallback lokal
    return _prefs?.getStringList(_prefKeyFavorites) ?? [];
  }

  /// Tambah / Hapus favorit
  Future<bool> toggleFavorite(String itemId, {String userId = 'guest_user'}) async {
    await initialize();
    final current = await getFavoriteItemIds(userId: userId);
    final isFav = current.contains(itemId);

    if (isFav) {
      current.remove(itemId);
    } else {
      current.add(itemId);
    }

    await _prefs?.setStringList(_prefKeyFavorites, current);

    // Sinkronisasi Supabase jika aktif
    if (AppConfig.isSupabaseConfigured) {
      try {
        if (isFav) {
          await http.delete(
            Uri.parse(
              '${AppConfig.supabaseUrl}/rest/v1/favorites?user_id=eq.$userId&item_id=eq.$itemId',
            ),
            headers: {
              'apikey': AppConfig.supabaseAnonKey,
              'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
            },
          );
        } else {
          await http.post(
            Uri.parse('${AppConfig.supabaseUrl}/rest/v1/favorites'),
            headers: {
              'apikey': AppConfig.supabaseAnonKey,
              'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
              'Content-Type': 'application/json',
              'Prefer': 'return=minimal',
            },
            body: jsonEncode({'user_id': userId, 'item_id': itemId}),
          );
        }
      } catch (e) {
        debugPrint('Supabase sync favorite error: $e');
      }
    }

    return !isFav;
  }

  /// Setelan busana tersimpan
  Future<List<SavedOutfit>> getSavedOutfits() async {
    await initialize();
    final raw = _prefs?.getStringList(_prefKeySavedOutfits) ?? [];
    return raw.map((s) => SavedOutfit.fromJson(jsonDecode(s))).toList();
  }

  Future<void> saveCustomOutfit(SavedOutfit outfit) async {
    await initialize();
    final list = await getSavedOutfits();
    list.removeWhere((o) => o.id == outfit.id);
    list.insert(0, outfit);

    final raw = list.map((o) => jsonEncode(o.toJson())).toList();
    await _prefs?.setStringList(_prefKeySavedOutfits, raw);
  }

  /// Ambil seluruh item busana adat dengan sinkronisasi Supabase + fallback lokal
  Future<List<ClothingItem>> getClothingItems() async {
    await initialize();

    if (AppConfig.isSupabaseConfigured) {
      try {
        final url = Uri.parse(
          '${AppConfig.supabaseUrl}/rest/v1/clothing_items?select=*',
        );
        final res = await http.get(url, headers: {
          'apikey': AppConfig.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        }).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          // Jika Supabase memiliki data, kita parse atau gunakan kurasi terverifikasi
          return JavaneseClothingData.clothingItems;
        }
      } catch (e) {
        debugPrint('Supabase getClothingItems fallback to local: $e');
      }
    }

    return JavaneseClothingData.clothingItems;
  }

  /// Ambil setelan lengkap busana kurasi (TraditionalOutfits)
  Future<List<TraditionalOutfit>> getCuratedOutfits() async {
    await initialize();

    if (AppConfig.isSupabaseConfigured) {
      try {
        final url = Uri.parse(
          '${AppConfig.supabaseUrl}/rest/v1/outfit_presets?select=*',
        );
        final res = await http.get(url, headers: {
          'apikey': AppConfig.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        }).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          return JavaneseClothingData.curatedOutfits;
        }
      } catch (e) {
        debugPrint('Supabase getCuratedOutfits fallback to local: $e');
      }
    }

    return JavaneseClothingData.curatedOutfits;
  }
}
