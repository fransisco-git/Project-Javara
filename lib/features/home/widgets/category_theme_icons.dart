import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Jenis ikon tematik khas Jawa Tengah untuk kategori Beranda JAVARA.
enum JavaraCategoryIconType {
  busana,
  aksesoris,
  batik,
}

/// Ikon vektor monoline minimalis bertema warisan Jawa Tengah (grid 24×24, stroke 1.5).
/// Dirancang bersih tanpa fill keruh, tanpa gradien, dan tanpa ornamen berlebih.
class JavaraCategoryThemeIcon extends StatelessWidget {
  const JavaraCategoryThemeIcon({
    super.key,
    required this.type,
    this.size = 26,
    this.color = JColors.accentGold,
  });

  final JavaraCategoryIconType type;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _JavaraCategoryIconPainter(
          type: type,
          color: color,
        ),
      ),
    );
  }
}

class _JavaraCategoryIconPainter extends CustomPainter {
  const _JavaraCategoryIconPainter({
    required this.type,
    required this.color,
  });

  final JavaraCategoryIconType type;
  final Color color;

  Paint _stroke(double s) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5 * s
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    switch (type) {
      case JavaraCategoryIconType.busana:
        _paintBusana(canvas, s);
      case JavaraCategoryIconType.aksesoris:
        _paintAksesoris(canvas, s);
      case JavaraCategoryIconType.batik:
        _paintBatik(canvas, s);
    }
  }

  /// Busana: Siluet kerah tegak & lipatan asimetris Beskap/Kebaya Keraton.
  void _paintBusana(Canvas canvas, double s) {
    final paint = _stroke(s);

    // 1. Kerah tegak Mandarin + bahu dan siluet tubuh ramping
    final silhouette = Path()
      ..moveTo(9.2 * s, 4.2 * s)
      ..lineTo(9.2 * s, 6.2 * s)
      ..lineTo(4.2 * s, 8.6 * s)
      ..lineTo(6.2 * s, 12.6 * s)
      ..lineTo(7.8 * s, 11.8 * s)
      ..lineTo(7.4 * s, 19.6 * s)
      ..quadraticBezierTo(12.0 * s, 20.6 * s, 16.6 * s, 19.6 * s)
      ..lineTo(16.2 * s, 11.8 * s)
      ..lineTo(17.8 * s, 12.6 * s)
      ..lineTo(19.8 * s, 8.6 * s)
      ..lineTo(14.8 * s, 6.2 * s)
      ..lineTo(14.8 * s, 4.2 * s);

    // Garis atas kerah tegak
    final collarTop = Path()
      ..moveTo(9.2 * s, 4.2 * s)
      ..quadraticBezierTo(12.0 * s, 5.4 * s, 14.8 * s, 4.2 * s);

    // 2. Lipatan asimetris sikepan / beskap menyilang dari kerah kanan ke bawah
    final lapel = Path()
      ..moveTo(14.5 * s, 6.3 * s)
      ..quadraticBezierTo(11.6 * s, 9.6 * s, 11.2 * s, 19.8 * s);

    // 3. Aksen kancing/bros tunggal tegas di dada
    canvas.drawPath(silhouette, paint);
    canvas.drawPath(collarTop, paint);
    canvas.drawPath(lapel, paint);
    canvas.drawLine(
      Offset(12.6 * s, 10.6 * s),
      Offset(14.0 * s, 10.6 * s),
      paint,
    );
  }

  /// Aksesoris: Siluet diagonal Keris Ladrang minimalis (hulu, warangka, bilah berluk).
  void _paintAksesoris(Canvas canvas, double s) {
    final paint = _stroke(s);

    canvas.save();
    canvas.translate(12.0 * s, 12.0 * s);
    canvas.rotate(math.pi / 4); // Diagonal 45° yang tegas dan seimbang
    canvas.translate(-12.0 * s, -12.0 * s);

    // 1. Hulu (ukiran) melengkung ringkas di atas
    final hilt = Path()
      ..moveTo(12.0 * s, 8.2 * s)
      ..lineTo(12.0 * s, 5.2 * s)
      ..quadraticBezierTo(12.0 * s, 3.2 * s, 14.4 * s, 3.6 * s);

    // 2. Warangka Ladrang (perahu melengkung elegan)
    final warangka = Path()
      ..moveTo(7.4 * s, 7.6 * s)
      ..quadraticBezierTo(12.0 * s, 9.8 * s, 16.6 * s, 7.6 * s);

    // 3. Bilah Keris berluk halus meruncing ke ujung bawah
    final blade = Path()
      ..moveTo(12.0 * s, 8.8 * s)
      ..cubicTo(10.0 * s, 11.2 * s, 14.0 * s, 13.4 * s, 11.4 * s, 16.2 * s)
      ..quadraticBezierTo(10.8 * s, 17.8 * s, 12.0 * s, 20.6 * s);

    canvas.drawPath(hilt, paint);
    canvas.drawPath(warangka, paint);
    canvas.drawPath(blade, paint);

    canvas.restore();
  }

  /// Batik: Motif geometris Kawung pakem 4-kelopak simetris murni.
  void _paintBatik(Canvas canvas, double s) {
    final paint = _stroke(s);
    final center = Offset(12.0 * s, 12.0 * s);

    // 4 kelopak Kawung simetris pada sumbu diagonal (45°, 135°, 225°, 315°)
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 4) + (i * math.pi / 2);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final petal = Path()
        ..moveTo(1.8 * s, 0)
        ..quadraticBezierTo(5.6 * s, -3.2 * s, 9.4 * s, 0)
        ..quadraticBezierTo(5.6 * s, 3.2 * s, 1.8 * s, 0)
        ..close();

      canvas.drawPath(petal, paint);
      canvas.restore();
    }

    // Inti belah ketupat kecil di tengah sebagai pengikat motif
    final core = Path()
      ..moveTo(12.0 * s, 10.2 * s)
      ..lineTo(13.8 * s, 12.0 * s)
      ..lineTo(12.0 * s, 13.8 * s)
      ..lineTo(10.2 * s, 12.0 * s)
      ..close();
    canvas.drawPath(core, paint);
  }

  @override
  bool shouldRepaint(covariant _JavaraCategoryIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
