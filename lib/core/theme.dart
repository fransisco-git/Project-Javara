import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/heritage_background.dart';
export '../widgets/heritage_background.dart'
    show HeritageBackgroundVariant, JavaraHeritageBackground;

/// Palet Warna Resmi JAVARA — Cultural Luxury & Javanese Heritage
/// Menggabungkan kehangatan naskah kuno, kayu jati berukir, beludru keraton, dan prada emas.
class JColors {
  JColors._();

  // --- Master Palette Utama JAVARA ---
  static const warmIvory = Color(0xFFF5F0E8); // Latar terang utama editorial
  static const deepJavaBrown = Color(
    0xFF30251F,
  ); // Kayu jati gelap / busana keraton
  static const antiqueGold = Color(0xFFB08D57); // Aksen prada kencana adiluhung
  static const accentGold = Color(0xFFFED897); // Aksen krem emas utama (navbar & CTA)
  static const charcoal = Color(0xFF242321); // Teks kontras tinggi & bingkai
  static const softSand = Color(0xFFE8DED0); // Kartu sekunder & pembatas halus

  // --- Master Palette Sekunder ---
  static const mutedTerracotta = Color(
    0xFFA8664F,
  ); // Genteng candi & tembikar Kasongan
  static const batikIndigo = Color(
    0xFF394B5B,
  ); // Nila celup alami batik pesisiran
  static const forestGreen = Color(
    0xFF465447,
  ); // Daun sirih & lumut batu Borobudur

  // --- Kompatibilitas Warisan & Tema Eksisting ---
  static const night = Color(0xFF2E2019); // Splash & latar teks gelap
  static const button = Color(0xFF3A261D); // Tombol utama ksatria
  static const cream = Color(0xFFF4E9D8); // Krem naskah kuno
  static const sand = Color(0xFFE0C9A6); // Pasir pantai selatan
  static const field = Color(0xFFE3CDAB); // Latar input & tombol sosial
  static const surfaceCard = Color(
    0xFFFFFBF4,
  ); // Kartu Beranda naskah primissima
  static const gold = Color(0xFFC79B3A); // Emas kencana bercahaya
  static const terracotta = Color(0xFFB5603A); // Terakota klasik
  static const sage = Color(0xFF6A7B5B); // Hijau pupus
  static const ink = Color(0xFF2B1A12); // Tinta cina naskah
  static const muted = Color(0xFF6B5845); // Teks redup berwibawa
  static const hint = Color(0xFF5F4E3C); // Placeholder terbaca
  static const error = Color(0xFFB3261E);
  static const success = Color(0xFF3F6B3A);
  static const errorSoft = Color(0x1AB3261E);
  static const errorLine = Color(0x66B3261E);
  static const successSoft = Color(0x1F3F6B3A);
  static const successLine = Color(0x663F6B3A);
}

/// Hirarki Tipografi JAVARA — Paduan Anggun Editorial & Ketajaman Antarmuka
class JText {
  JText._();

  /// Tipografi Editorial Mewah (Cormorant Garamond)
  /// Digunakan untuk Judul Utama, Header Editorial Mode, & Kutipan Filosofis
  static TextStyle editorial(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = JColors.ink,
    double? height,
    FontStyle? style,
    double? letterSpacing,
  }) => GoogleFonts.cormorantGaramond(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    fontStyle: style,
    letterSpacing: letterSpacing,
  );

  /// Tipografi Antarmuka Modern & Jelas (Inter)
  /// Digunakan untuk Label Navigasi, Metadata Busana, Tag, & Tombol Aksi
  static TextStyle sans(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = JColors.ink,
    double? height,
    FontStyle? style,
    double? letterSpacing,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    fontStyle: style,
    letterSpacing: letterSpacing,
  );

  /// Tipografi Narasi Tradisi Budaya (Lora)
  /// Digunakan untuk Paragraf Cerita, Deskripsi Sejarah, & Makna Filosofis
  static TextStyle serif(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = JColors.ink,
    double? height,
    FontStyle? style,
    double? letterSpacing,
  }) => GoogleFonts.lora(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    fontStyle: style,
    letterSpacing: letterSpacing,
  );
}

/// Konstruksi Tema Global JAVARA Material 3
ThemeData buildJavaraTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: JColors.antiqueGold,
        brightness: Brightness.light,
      ).copyWith(
        primary: JColors.deepJavaBrown,
        onPrimary: JColors.warmIvory,
        secondary: JColors.antiqueGold,
        onSecondary: JColors.deepJavaBrown,
        surface: JColors.warmIvory,
        onSurface: JColors.charcoal,
        error: JColors.error,
      );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: JColors.warmIvory,
    textTheme: GoogleFonts.loraTextTheme(base.textTheme)
        .apply(bodyColor: JColors.charcoal, displayColor: JColors.charcoal),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: JColors.deepJavaBrown,
      selectionColor: Color(0x33B08D57),
      selectionHandleColor: JColors.antiqueGold,
    ),
    splashFactory: InkRipple.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

/// Latar Halaman: Gradasi Warisan Budaya Adiluhung Jawa Tengah
class JBackground extends StatelessWidget {
  const JBackground({
    super.key,
    required this.child,
    this.dark = false,
    this.variant,
  });

  final Widget child;
  final bool dark;
  final HeritageBackgroundVariant? variant;

  @override
  Widget build(BuildContext context) {
    final effectiveVariant =
        variant ??
        (dark
            ? HeritageBackgroundVariant.darkVelvet
            : HeritageBackgroundVariant.warmParchment);

    return JavaraHeritageBackground(variant: effectiveVariant, child: child);
  }
}
