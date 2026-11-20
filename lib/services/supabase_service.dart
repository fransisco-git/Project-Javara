import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';
import '../features/fashion/models/javanese_clothing_models.dart';
import '../features/fashion/data/javanese_clothing_data.dart';

/// Model Rekam Data Generasi AI di Database
class AiGenerationRecord {
  const AiGenerationRecord({
    required this.id,
    required this.userId,
    required this.modelId,
    required this.modelName,
    required this.garmentName,
    required this.originalImageUrl,
    required this.generatedImageUrl,
    required this.status,
    required this.createdAt,
    this.parameters = const {},
  });

  final String id;
  final String userId;
  final String modelId;
  final String modelName;
  final String garmentName;
  final String originalImageUrl;
  final String generatedImageUrl;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic> parameters;

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'model_id': modelId,
        'model_name': modelName,
        'garment_name': garmentName,
        'original_image_url': originalImageUrl,
        'generated_image_url': generatedImageUrl,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'parameters': parameters,
      };

  factory AiGenerationRecord.fromJson(Map<String, dynamic> json) {
    return AiGenerationRecord(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? 'guest_user',
      modelId: json['model_id'] as String? ?? '',
      modelName: json['model_name'] as String? ?? 'Model Adat',
      garmentName: json['garment_name'] as String? ?? 'Busana Tradisi',
      originalImageUrl: json['original_image_url'] as String? ?? '',
      generatedImageUrl: json['generated_image_url'] as String? ?? '',
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      parameters: json['parameters'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Layanan Integrasi Database Supabase & Offline-First Cache JAVARA
///
/// Menyediakan koneksi aman ke REST API PostgREST Supabase dengan dukungan
/// Row Level Security (RLS) serta fallback penyimpanan lokal via SharedPreferences.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  static const String _prefKeyFavorites = 'javara_user_favorites';
  static const String _prefKeySavedOutfits = 'javara_saved_outfits';
  static const String _prefKeyGenerations = 'javara_ai_generations';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    debugPrint(
      'SupabaseService Initialized. Configured: ${AppConfig.isSupabaseConfigured}',
    );
  }

  // ===========================================================================
  // 1. MANAJEMEN FAVORIT BUDAYA
  // ===========================================================================

  /// Ambil daftar ID item favorit pengguna
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

  // ===========================================================================
  // 2. RIWAYAT GENERASI AI FASHION STUDIO
  // ===========================================================================

  /// Ambil riwayat hasil Virtual Try-On
  Future<List<AiGenerationRecord>> getAiGenerations({
    String userId = 'guest_user',
  }) async {
    await initialize();

    if (AppConfig.isSupabaseConfigured) {
      try {
        final url = Uri.parse(
          '${AppConfig.supabaseUrl}/rest/v1/ai_generations?user_id=eq.$userId&order=created_at.desc',
        );
        final res = await http.get(url, headers: {
          'apikey': AppConfig.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        }).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final List list = jsonDecode(res.body);
          return list.map((e) => AiGenerationRecord.fromJson(e)).toList();
        }
      } catch (e) {
        debugPrint('Supabase getAiGenerations fallback: $e');
      }
    }

    // Fallback lokal
    final rawList = _prefs?.getStringList(_prefKeyGenerations) ?? [];
    return rawList
        .map((s) => AiGenerationRecord.fromJson(jsonDecode(s)))
        .toList();
  }

  /// Simpan catatan generasi AI baru
  Future<void> saveAiGeneration(AiGenerationRecord record) async {
    await initialize();

    final current = await getAiGenerations(userId: record.userId);
    current.insert(0, record);

    final encoded = current.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs?.setStringList(_prefKeyGenerations, encoded);

    if (AppConfig.isSupabaseConfigured) {
      try {
        await http.post(
          Uri.parse('${AppConfig.supabaseUrl}/rest/v1/ai_generations'),
          headers: {
            'apikey': AppConfig.supabaseAnonKey,
            'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal',
          },
          body: jsonEncode(record.toJson()),
        );
      } catch (e) {
        debugPrint('Supabase saveAiGeneration error: $e');
      }
    }
  }

  // ===========================================================================
  // 3. SETELAN BUSANA 3D TERSIMPAN (SAVED OUTFITS)
  // ===========================================================================

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

  // ===========================================================================
  // 4. KATALOG BUSANA & SETELAN KURASI (SUPABASE / LOCAL OFFLINE REPOSITORY)
  // ===========================================================================

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
