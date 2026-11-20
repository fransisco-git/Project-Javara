import 'package:flutter/material.dart';

/// Kategori Bagian Busana Tradisional Jawa
enum ClothingCategory {
  headwear('Penutup Kepala (Iketan/Blangkon)', Icons.face_rounded),
  upperBody('Busana Atasan (Rasukan)', Icons.checkroom_rounded),
  lowerBody('Busana Bawahan (Bebet/Jarik)', Icons.layers_rounded),
  accessories('Ricikan & Aksesoris', Icons.military_tech_rounded);

  const ClothingCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Target Gender Busana
enum GenderTarget {
  pria('Pria (Kakung)', Icons.man_rounded),
  wanita('Wanita (Putri)', Icons.woman_rounded),
  unisex('Universal / Pasangan', Icons.people_rounded);

  const GenderTarget(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Wilayah Budaya Tradisi di Jawa Tengah
enum TraditionRegion {
  surakarta('Surakarta Hadiningrat', 'Solo & Mangkunegaran', 'ꦱꦸꦫꦏꦂꦠ'),
  yogyakarta('Yogyakarta Hadiningrat', 'Kraton & Pakualaman', 'ꦔꦪꦺꦴꦒꦾꦏꦂꦠ'),
  banyumas('Banyumasan', 'Banyumas, Purwokerto & Cilacap', 'ꦧꦚꦸꦩꦱ꧀'),
  pekalongan('Pesisir Pekalongan', 'Kota Batik Dunia & Pantura', 'ꦥꦼꦏꦭꦺꦴꦔꦤ꧀'),
  kudus('Kudus & Muria', 'Pesisiran & Sunan Kudus', 'ꦏꦸꦢꦸꦱ꧀'),
  jepara('Jepara Pesisiran', 'Bumi Kartini & Ratu Kalinyamat', 'ꦗꦼꦥꦫ'),
  semarang('Semarang Pesisiran', 'Akulturasi Pesisir Jawa-Pecinan', 'ꦱꦼꦩꦫꦁ');

  const TraditionRegion(this.title, this.subtitle, this.javaneseScript);
  final String title;
  final String subtitle;
  final String javaneseScript;
}

/// Konteks Sosial & Tata Busana Tradisional
enum SocialContext {
  keratonBangsawan('Keraton & Bangsawan', 'Upacara Agung Kasunanan & Kadipaten'),
  priyayiFormal('Priyayi & Pejabat Formal', 'Paseban, Pertemuan Resmi & Birokrasi Adat'),
  keseharianRakyat('Busana Keseharian Rakyat', 'Busana Sehari-hari, Tani & Kriya Tradisi'),
  pengantinTradisi('Busana Pengantin Adat', 'Tata Rias Pengantin Adiluhung Jawa'),
  upacaraSekaten('Upacara Ritual & Sakral', 'Hajad Dalem Sekaten, Grebeg, & Karaton');

  const SocialContext(this.label, this.description);
  final String label;
  final String description;
}

/// Model Entitas Satuan Busana Tradisional
class ClothingItem {
  const ClothingItem({
    required this.id,
    required this.name,
    required this.javaneseScript,
    required this.category,
    required this.gender,
    required this.region,
    required this.period,
    required this.socialContext,
    required this.material,
    required this.philosophicalMeaning,
    required this.cuttingAndConstruction,
    required this.compatibilityKeys,
    required this.colorPalette,
    required this.textureMotif,
    required this.historicalNotes,
    required this.references,
    this.primaryColor = const Color(0xFF2C2219),
    this.accentColor = const Color(0xFFE4C590),
    this.assetImagePath,
  });

  final String id;
  final String name;
  final String javaneseScript;
  final ClothingCategory category;
  final GenderTarget gender;
  final TraditionRegion region;
  final String period;
  final SocialContext socialContext;
  final String material;
  final String philosophicalMeaning;
  final String cuttingAndConstruction;
  final List<String> compatibilityKeys; // Kunci keselarasan sejarah
  final List<Color> colorPalette;
  final String textureMotif;
  final String historicalNotes;
  final String references;
  final Color primaryColor;
  final Color accentColor;
  final String? assetImagePath;

  String get imageAsset {
    if (assetImagePath != null && assetImagePath!.isNotEmpty) return assetImagePath!;
    if (category == ClothingCategory.upperBody) {
      if (gender == GenderTarget.wanita || name.toLowerCase().contains('kebaya')) {
        return 'assets/images/kebaya.png';
      }
      return 'assets/images/model_surjan_pranakan_solo.jpg';
    } else if (category == ClothingCategory.lowerBody) {
      return 'assets/images/batik.png';
    } else if (category == ClothingCategory.headwear) {
      return 'assets/images/wayang.png';
    }
    return 'assets/images/candi_3d_hero.jpg';
  }

  bool isCompatibleWith(ClothingItem other) {
    if (compatibilityKeys.isEmpty || other.compatibilityKeys.isEmpty) return true;
    return compatibilityKeys.any((key) => other.compatibilityKeys.contains(key));
  }
}

/// Model Motif Batik Tradisional
class BatikMotif {
  const BatikMotif({
    required this.id,
    required this.name,
    required this.javaneseScript,
    required this.meaning,
    required this.category,
    required this.historicalUsage,
    required this.primaryTone,
    required this.isLarangan,
  });

  final String id;
  final String name;
  final String javaneseScript;
  final String meaning;
  final String category; // Geometris, Flora, Semen, Parang
  final String historicalUsage;
  final Color primaryTone;
  final bool isLarangan; // Motif larangan keraton (hanya raja/pangeran)
}

/// Model Setelan Busana Lengkap Kurasi ("Jelajahi Busana")
class TraditionalOutfit {
  const TraditionalOutfit({
    required this.id,
    required this.title,
    required this.javaneseScript,
    required this.collectionCategory,
    required this.gender,
    required this.region,
    required this.era,
    required this.headwearId,
    required this.upperBodyId,
    required this.lowerBodyId,
    required this.accessoryIds,
    required this.summary,
    required this.culturalPhilosophy,
    required this.etiquetteRules,
    required this.historicalSources,
    required this.dominantColors,
  });

  final String id;
  final String title;
  final String javaneseScript;
  final String collectionCategory; // Keraton, Priyayi, Keseharian, Pengantin, dsb.
  final GenderTarget gender;
  final TraditionRegion region;
  final String era;
  final String headwearId;
  final String upperBodyId;
  final String lowerBodyId;
  final List<String> accessoryIds;
  final String summary;
  final String culturalPhilosophy;
  final String etiquetteRules;
  final String historicalSources;
  final List<Color> dominantColors;

  String get imageAsset {
    final lowerId = id.toLowerCase();
    if (lowerId.contains('kebaya') || lowerId.contains('kartini')) {
      return 'assets/images/model_kebaya_kartini_solo.jpg';
    } else if (lowerId.contains('kanigaran') || lowerId.contains('basahan') || lowerId.contains('pengantin')) {
      return 'assets/images/model_solo_basahan_bride.jpg';
    } else if (lowerId.contains('surjan') || lowerId.contains('lurik')) {
      return 'assets/images/model_surjan_pranakan_solo.jpg';
    }
    return 'assets/images/model_jawi_jangkep_solo.jpg';
  }
  String get socialContext => collectionCategory;
}

/// Model Koleksi Busana Tersimpan Milik Pengguna ("Koleksi Pusaka Saya")
class SavedOutfit {
  const SavedOutfit({
    required this.id,
    required this.customName,
    required this.savedDate,
    required this.gender,
    required this.headwearId,
    required this.upperBodyId,
    required this.lowerBodyId,
    required this.accessoryIds,
    required this.isHistoricallyVerified,
    required this.harmonyRating,
    this.notes = '',
  });

  final String id;
  final String customName;
  final DateTime savedDate;
  final GenderTarget gender;
  final String headwearId;
  final String upperBodyId;
  final String lowerBodyId;
  final List<String> accessoryIds;
  final bool isHistoricallyVerified;
  final int harmonyRating; // 1-5 bintang
  final String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'customName': customName,
        'savedDate': savedDate.toIso8601String(),
        'gender': gender.name,
        'headwearId': headwearId,
        'upperBodyId': upperBodyId,
        'lowerBodyId': lowerBodyId,
        'accessoryIds': accessoryIds,
        'isHistoricallyVerified': isHistoricallyVerified,
        'harmonyRating': harmonyRating,
        'notes': notes,
      };

  factory SavedOutfit.fromJson(Map<String, dynamic> json) => SavedOutfit(
        id: json['id'] as String,
        customName: json['customName'] as String,
        savedDate: DateTime.parse(json['savedDate'] as String),
        gender: GenderTarget.values.firstWhere(
          (g) => g.name == json['gender'],
          orElse: () => GenderTarget.pria,
        ),
        headwearId: json['headwearId'] as String,
        upperBodyId: json['upperBodyId'] as String,
        lowerBodyId: json['lowerBodyId'] as String,
        accessoryIds: List<String>.from(json['accessoryIds'] as List),
        isHistoricallyVerified: json['isHistoricallyVerified'] as bool? ?? true,
        harmonyRating: json['harmonyRating'] as int? ?? 5,
        notes: json['notes'] as String? ?? '',
      );
}

/// Model Kuis & Tantangan Edukasi Busana Adat
class FashionQuizItem {
  const FashionQuizItem({
    required this.id,
    required this.question,
    required this.javaneseScript,
    required this.options,
    required this.correctOptionIndex,
    required this.historicalExplanation,
    required this.category,
  });

  final String id;
  final String question;
  final String javaneseScript;
  final List<String> options;
  final int correctOptionIndex;
  final String historicalExplanation;
  final String category;
}

