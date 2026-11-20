import 'package:flutter/material.dart';

/// Daerah utama di Pulau Jawa yang dapat dipilih pengguna.
class RegionInfo {
  const RegionInfo({
    required this.id,
    required this.name,
    required this.tagline,
    required this.image,
    this.isSelected = false,
  });

  final String id;
  final String name;
  final String tagline;
  final String image;
  final bool isSelected;
}

/// Kabupaten/Kota di Jawa Tengah untuk Peta Budaya Interaktif.
class RegencyInfo {
  const RegencyInfo({
    required this.id,
    required this.name,
    required this.title,
    required this.specialty,
    required this.landmark,
    required this.description,
    required this.icon,
    required this.mapOffset,
    this.elevation = 'Dataran Rendah',
    this.culturalZone = 'Jawa Tengah',
    this.highlightImage = 'home_hero.png',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.heritageCategory = 'Candi & Sejarah',
    this.traditionalDish = '',
  });

  final String id;
  final String name;
  final String title;
  final String specialty;
  final String landmark;
  final String description;
  final IconData icon;

  /// Posisi relatif (0.0 - 1.0) pada peta interaktif Jawa Tengah.
  final Offset mapOffset;
  final String elevation;
  final String culturalZone;
  final String highlightImage;
  final double latitude;
  final double longitude;
  final String heritageCategory;
  final String traditionalDish;

  String get coordinatesFormatted {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';
    final latAbs = latitude.abs();
    final lngAbs = longitude.abs();
    final latDeg = latAbs.floor();
    final latMin = ((latAbs - latDeg) * 60).floor();
    final lngDeg = lngAbs.floor();
    final lngMin = ((lngAbs - lngDeg) * 60).floor();
    return "$latDeg°$latMin' $latDir · $lngDeg°$lngMin' $lngDir";
  }
}

/// Rute Perjalanan Budaya Tematik Kurasi JAVARA.
class CuratedCulturalRoute {
  const CuratedCulturalRoute({
    required this.id,
    required this.title,
    required this.theme,
    required this.duration,
    required this.regencyNames,
    required this.summary,
    required this.coverImage,
    required this.keyStops,
    required this.badgeColor,
  });

  final String id;
  final String title;
  final String theme;
  final String duration;
  final List<String> regencyNames;
  final String summary;
  final String coverImage;
  final List<String> keyStops;
  final Color badgeColor;
}

/// Kategori item penjelajahan budaya Jawa.
enum ExploreCategory {
  budaya('BUDAYA', Color(0xFFB5603A)),
  produk('PRODUK', Color(0xFFC79B3A)),
  busana('BUSANA', Color(0xFF6A7B5B)),
  event('EVENT', Color(0xFF5A3A25)),
  kriya('KRIYA', Color(0xFF8C5835));

  const ExploreCategory(this.label, this.badgeColor);
  final String label;
  final Color badgeColor;
}

/// Item warisan budaya, produk, kuliner, atau event.
class ExploreItem {
  const ExploreItem({
    required this.id,
    required this.regionId,
    this.regencyId,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.image,
    this.isStory = false,
    this.price,
    this.eventDate,
    this.readingTime,
    this.storyHeadline,
    this.storyIntro,
    this.storyParagraphs = const [],
    this.relatedProducts = const [],
    this.quizTopic,
  });

  final String id;
  final String regionId;
  final String? regencyId;
  final ExploreCategory category;
  final String title;
  final String subtitle;
  final String image;
  final bool isStory;
  final String? price;
  final String? eventDate;
  final String? readingTime;
  final String? storyHeadline;
  final String? storyIntro;
  final List<String> storyParagraphs;
  final List<RelatedProduct> relatedProducts;
  final String? quizTopic;
}

/// Produk terkait yang muncul di akhir halaman Cerita Budaya (Figma Page 2).
class RelatedProduct {
  const RelatedProduct({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String icon; // emoji atau simbol
}

/// Soal Kuis Budaya (diambil dari Figma Page 2 'fitur_belajar').
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final String question;
  final String category;
  final List<String> options;
  final int correctIndex;
  final String explanation; // Muncul di "Tahukah kamu?"
}
