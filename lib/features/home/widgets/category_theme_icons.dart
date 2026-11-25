import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Jenis ikon tematik khas Jawa Tengah untuk kategori Beranda JAVARA.
enum JavaraCategoryIconType {
  busana,
  aksesoris,
  batik,
}

/// Ikon vektor khusus bertema warisan budaya Jawa Tengah untuk kartu kategori Beranda.
class JavaraCategoryThemeIcon extends StatelessWidget {
  const JavaraCategoryThemeIcon({
    super.key,
    required this.type,
    this.size = 28,
    this.color = const Color(0xFFDFB76C),
    this.highlightColor = const Color(0xFFFFF0D0),
  });

  final JavaraCategoryIconType type;
  final double size;
  final Color color;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _JavaraCategoryIconPainter(
          type: type,
          color: color,
          highlightColor: highlightColor,
        ),
      ),
    );
  }
}

class _JavaraCategoryIconPainter extends CustomPainter {
  const _JavaraCategoryIconPainter({
    required this.type,
    required this.color,
    required this.highlightColor,
  });

  final JavaraCategoryIconType type;
  final Color color;
  final Color highlightColor;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case JavaraCategoryIconType.busana:
        _paintBusana(canvas, size);
      case JavaraCategoryIconType.aksesoris:
        _paintAksesoris(canvas, size);
      case JavaraCategoryIconType.batik:
        _paintBatik(canvas, size);
    }
  }

  /// Siluet Beskap / Kebaya Keraton dengan kerah tegak, belahan asimetris, dan kancing emas.
  void _paintBusana(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.65
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final accentDot = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    // Kerah tegak Keraton (Mandarin collar)
    final collar = Path()
      ..moveTo(w * 0.38, h * 0.14)
      ..quadraticBezierTo(w * 0.50, h * 0.21, w * 0.62, h * 0.14)
      ..lineTo(w * 0.60, h * 0.24)
      ..quadraticBezierTo(w * 0.50, h * 0.29, w * 0.40, h * 0.24)
      ..close();

    // Badan Beskap / Kebaya dengan lengan tradisional dan kelim melengkung
    final body = Path()
      ..moveTo(w * 0.40, h * 0.24)
      ..lineTo(w * 0.18, h * 0.31)
      ..lineTo(w * 0.10, h * 0.60)
      ..lineTo(w * 0.22, h * 0.63)
      ..lineTo(w * 0.28, h * 0.44)
      ..lineTo(w * 0.26, h * 0.85)
      ..quadraticBezierTo(w * 0.50, h * 0.90, w * 0.74, h * 0.85)
      ..lineTo(w * 0.72, h * 0.44)
      ..lineTo(w * 0.78, h * 0.63)
      ..lineTo(w * 0.90, h * 0.60)
      ..lineTo(w * 0.82, h * 0.31)
      ..lineTo(w * 0.60, h * 0.24);

    canvas.drawPath(body, fillPaint);
    canvas.drawPath(collar, fillPaint);
    canvas.drawPath(body, strokePaint);
    canvas.drawPath(collar, strokePaint);

    // Lipatan sikepan / kutubaru asimetris di dada
    final lapel = Path()
      ..moveTo(w * 0.46, h * 0.26)
      ..quadraticBezierTo(w * 0.56, h * 0.44, w * 0.53, h * 0.84);
    canvas.drawPath(lapel, strokePaint);

    // Tiga kancing mas tradisional
    canvas.drawCircle(Offset(w * 0.52, h * 0.40), 1.35, accentDot);
    canvas.drawCircle(Offset(w * 0.535, h * 0.53), 1.35, accentDot);
    canvas.drawCircle(Offset(w * 0.53, h * 0.66), 1.35, accentDot);
  }

  /// Siluet Keris Pusaka Jawa dengan ukiran hulu, warangka ladrang, dan bilah berluk.
  void _paintAksesoris(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.65
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(w * 0.50, h * 0.50);
    canvas.rotate(math.pi / 6); // Kemiringan anggun 30°
    canvas.translate(-w * 0.50, -h * 0.50);

    // Ukiran (hulu keris) melengkung di atas
    final hilt = Path()
      ..moveTo(w * 0.47, h * 0.28)
      ..cubicTo(w * 0.43, h * 0.18, w * 0.48, h * 0.10, w * 0.56, h * 0.12)
      ..cubicTo(w * 0.59, h * 0.15, w * 0.55, h * 0.22, w * 0.53, h * 0.28)
      ..close();

    // Warangka Ladrang (gandar atas berbentuk perahu khas Surakarta)
    final warangka = Path()
      ..moveTo(w * 0.26, h * 0.28)
      ..quadraticBezierTo(w * 0.50, h * 0.34, w * 0.74, h * 0.26)
      ..quadraticBezierTo(w * 0.76, h * 0.33, w * 0.68, h * 0.37)
      ..quadraticBezierTo(w * 0.50, h * 0.41, w * 0.31, h * 0.36)
      ..quadraticBezierTo(w * 0.25, h * 0.33, w * 0.26, h * 0.28)
      ..close();

    // Bilah Keris berluk anggun menuju ujung bawah
    final blade = Path()
      ..moveTo(w * 0.45, h * 0.38)
      ..cubicTo(w * 0.41, h * 0.49, w * 0.56, h * 0.55, w * 0.46, h * 0.67)
      ..cubicTo(w * 0.43, h * 0.75, w * 0.52, h * 0.81, w * 0.49, h * 0.90)
      ..cubicTo(w * 0.56, h * 0.80, w * 0.49, h * 0.73, w * 0.54, h * 0.64)
      ..cubicTo(w * 0.61, h * 0.53, w * 0.49, h * 0.47, w * 0.55, h * 0.38)
      ..close();

    canvas.drawPath(hilt, fillPaint);
    canvas.drawPath(warangka, fillPaint);
    canvas.drawPath(blade, fillPaint);

    canvas.drawPath(hilt, strokePaint);
    canvas.drawPath(warangka, strokePaint);
    canvas.drawPath(blade, strokePaint);

    // Mendak (cincin permata antara hulu dan warangka)
    canvas.drawLine(
      Offset(w * 0.45, h * 0.28),
      Offset(w * 0.55, h * 0.28),
      highlightPaint,
    );

    canvas.restore();
  }

  /// Motif Batik Kawung Pakem 4-kelopak simetris dengan isen-isen cecek dan inti mandala.
  void _paintBatik(Canvas canvas, Size s) {
    final center = Offset(s.width * 0.5, s.height * 0.5);
    final radius = s.width * 0.38;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    // Bingkai belah ketupat halus (garis pakem parang/kawung)
    final frame = Path()
      ..moveTo(center.dx, center.dy - radius * 1.04)
      ..lineTo(center.dx + radius * 1.04, center.dy)
      ..lineTo(center.dx, center.dy + radius * 1.04)
      ..lineTo(center.dx - radius * 1.04, center.dy)
      ..close();
    canvas.drawPath(
      frame,
      Paint()
        ..color = color.withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // 4 Kelopak Kawung simetris pada sudut diagonal (45°, 135°, 225°, 315°)
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 4) + (i * math.pi / 2);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final petal = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(radius * 0.56, -radius * 0.34, radius * 0.96, 0)
        ..quadraticBezierTo(radius * 0.56, radius * 0.34, 0, 0)
        ..close();

      canvas.drawPath(petal, fillPaint);
      canvas.drawPath(petal, strokePaint);

      // Cecek (dua titik isen-isen tradisional di ujung kelopak)
      canvas.drawCircle(Offset(radius * 0.62, 0), 1.25, dotPaint);
      canvas.restore();
    }

    // Inti pusat Kawung
    canvas.drawCircle(center, 2.7, fillPaint);
    canvas.drawCircle(center, 2.7, strokePaint);
    canvas.drawCircle(center, 1.15, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _JavaraCategoryIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.color != color ||
        oldDelegate.highlightColor != highlightColor;
  }
}
