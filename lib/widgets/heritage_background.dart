import 'package:flutter/material.dart';

/// Varian Latar Belakang Bernuansa Warisan Budaya Jawa Tengah
enum HeritageBackgroundVariant {
  /// Latar hangat kain mori/lontar keraton untuk Jelajah & eksplorasi
  explore,

  /// Latar luhur Kasunanan untuk Profil & pencapaian budaya
  profile,

  /// Latar panggung pencahayaan studio busana adat gelap mewah (Wardrobe)
  wardrobe,

  /// Latar sanggar adiluhung gelap berfokus pada ketenangan belajar (Kuis)
  kuis,

  /// Latar umum krem hangat bercahaya
  warmParchment,

  /// Latar gelap obsidian beludru
  darkVelvet,
}

/// Widget Latar Belakang Artistik Khasanah Budaya JAVARA.
/// Menghilangkan tampilan "flat" dengan memadukan multi-stop organic gradients,
/// pencahayaan ambient radial, dan ornamen motif Kawung/Parang beropasitas halus (subtle watermark)
/// yang mencerminkan martabat adiluhung busana Jawa Tengah tanpa melanggar aturan anti-slop.
class JavaraHeritageBackground extends StatelessWidget {
  const JavaraHeritageBackground({
    super.key,
    required this.child,
    this.variant = HeritageBackgroundVariant.explore,
  });

  final Widget child;
  final HeritageBackgroundVariant variant;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _BaseGradientLayer(variant: variant),
                CustomPaint(
                  isComplex: true,
                  willChange: false,
                  painter: _JavaneseKawungWatermarkPainter(variant: variant),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _getVignetteGradient(variant),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Konten Utama
        child,
      ],
    );
  }

  Gradient _getVignetteGradient(HeritageBackgroundVariant v) {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Color(0x064A2D19),
        Color(0x144A2D19),
      ],
      stops: [0.6, 0.85, 1.0],
    );
  }
}

/// Lapisan Gradasi Warna Dasar Berkarakter Budaya Jawa
class _BaseGradientLayer extends StatelessWidget {
  const _BaseGradientLayer({required this.variant});

  final HeritageBackgroundVariant variant;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case HeritageBackgroundVariant.explore:
        // Gradasi jelajah: Hangatnya fajar tanah Jawa, transisi dari krem gading,
        // soga kencana, hingga pasir hangat pegunungan Dieng dan pesisir.
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFAF5EC), // Ivory fajar
                Color(0xFFF4ECE0), // Mori soga muda
                Color(0xFFEFE3D0), // Pasir hangat
                Color(0xFFE5D5BD), // Soga klasik lereng Menoreh
              ],
              stops: [0.0, 0.28, 0.65, 1.0],
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.85),
                radius: 1.25,
                colors: [
                  Color(0x55FFF7E8), // Pendaran cahaya mentari atas
                  Color(0x1ADFB76C), // Semburat emas
                  Colors.transparent,
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
        );

      case HeritageBackgroundVariant.profile:
        // Gradasi profil: Karaton Kasunanan, nuansa beledu marun & emas soga yang lembut
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF9F3EA), // Pucuk gading
                Color(0xFFF5EADA), // Soga emas luhur
                Color(0xFFEBDBC7), // Kayu cendana
                Color(0xFFE2CCB2), // Tanah keraton
              ],
              stops: [0.0, 0.35, 0.70, 1.0],
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.3, -0.6),
                radius: 1.1,
                colors: [
                  Color(0x40FFEEC9),
                  Color(0x15DFB76C),
                  Colors.transparent,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );

      case HeritageBackgroundVariant.wardrobe:
        // Gradasi studio wardrobe: Pencahayaan panggung museum busana adat yang hangat dan terang.
        // Nuansa krem sutra mori, soga muda keraton, dengan pendaran keemasan adiluhung.
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFAF6EE), // Mori gading
                Color(0xFFF3ECE0), // Soga muda adiluhung
                Color(0xFFEBDBC7), // Serat kain alami
                Color(0xFFE2CFAF), // Pasir keemasan
              ],
              stops: [0.0, 0.30, 0.70, 1.0],
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.65),
                radius: 1.3,
                colors: [
                  Color(0x35DFB76C), // Sorot lampu emas hangat ke gantungan busana
                  Color(0x18C29D5E), // Pendaran soga keemasan
                  Colors.transparent,
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
        );

      case HeritageBackgroundVariant.kuis:
        // Gradasi kuis & sinau: Suasana hening dan khidmat sanggar keraton yang terang & jernih.
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF9F4EB), // Pustaka gading
                Color(0xFFF1E6D4), // Naskah lontar hangat
                Color(0xFFE8D7C0), // Serat kayu jati terang
                Color(0xFFDFCCB1), // Soga krem klasik
              ],
              stops: [0.0, 0.35, 0.75, 1.0],
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.3, -0.5),
                radius: 1.2,
                colors: [
                  Color(0x28DFB76C), // Semburat cahaya lentera emas
                  Color(0x0CC59B58),
                  Colors.transparent,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );

      case HeritageBackgroundVariant.warmParchment:
        return const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFAF6EE),
                Color(0xFFF3E9DA),
                Color(0xFFE9DAC4),
              ],
            ),
          ),
        );

      case HeritageBackgroundVariant.darkVelvet:
        return const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF7F2E9),
                Color(0xFFEDE2D1),
                Color(0xFFE4D3BD),
              ],
            ),
          ),
        );
    }
  }
}

/// Melukis Watermark Geometris Motif Batik Kawung Jawa Tradisional.
/// Didesain dengan goresan garis presisi dan opasitas sangat halus (0.02 - 0.045)
/// sehingga memberikan tekstur kain adiluhung yang nyata tanpa mengganggu keterbacaan teks/kartu.
class _JavaneseKawungWatermarkPainter extends CustomPainter {
  const _JavaneseKawungWatermarkPainter({required this.variant});

  final HeritageBackgroundVariant variant;

  @override
  void paint(Canvas canvas, Size size) {
    // Seluruh varian konsisten pada tema terang/krem warisan budaya Jawa Tengah
    final strokeColor = const Color(0xFF6E4825).withValues(alpha: 0.032); // Cokelat soga halus di latar terang

    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    final dotPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Jarak antar titik pusar motif Kawung
    const step = 56.0;
    const radius = 22.0;

    for (double x = -step / 2; x < size.width + step; x += step) {
      for (double y = -step / 2; y < size.height + step; y += step) {
        // Lingkaran pusat kecil (pancer)
        canvas.drawCircle(Offset(x, y), 2.2, dotPaint);

        // 4 kelopak elips melingkar melambangkan "Sedulur Papat Lima Pancer"
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x + radius * 0.55, y),
            width: radius * 1.1,
            height: radius * 0.58,
          ),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x - radius * 0.55, y),
            width: radius * 1.1,
            height: radius * 0.58,
          ),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y + radius * 0.55),
            width: radius * 0.58,
            height: radius * 1.1,
          ),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y - radius * 0.55),
            width: radius * 0.58,
            height: radius * 1.1,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _JavaneseKawungWatermarkPainter oldDelegate) =>
      oldDelegate.variant != variant;
}
