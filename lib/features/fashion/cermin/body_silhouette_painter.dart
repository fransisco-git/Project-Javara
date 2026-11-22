import 'package:flutter/material.dart';
import '../../../core/theme.dart';

/// Painter siluet pemandu tubuh yang halus untuk cermin busana live camera.
/// Menampilkan siluet tubuh manusia proporsional (kepala, bahu, dada, pinggul, kaki)
/// agar pengguna dapat memposisikan dirinya pada jarak ±1,5 meter secara tepat.
class BodySilhouettePainter extends CustomPainter {
  const BodySilhouettePainter({
    this.strokeColor = JColors.antiqueGold,
    this.strokeWidth = 1.6,
  });

  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = strokeColor.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    // Pemandu diposisikan di 15% dari atas hingga 85% dari tinggi layar
    final topY = size.height * 0.12;
    final totalH = size.height * 0.72;

    // 1. Kepala (Head Oval)
    final headW = size.width * 0.19;
    final headH = totalH * 0.16;
    final headCenterY = topY + (headH / 2);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, headCenterY),
        width: headW,
        height: headH,
      ),
      paint,
    );

    // 2. Garis Leher & Bahu hingga Kaki (Body Contour Path)
    final path = Path();

    final neckTopY = topY + headH * 0.95;
    final shoulderY = neckTopY + totalH * 0.05;
    final shoulderW = size.width * 0.54;
    final chestY = shoulderY + totalH * 0.12;
    final chestW = size.width * 0.44;
    final waistY = chestY + totalH * 0.15;
    final waistW = size.width * 0.38;
    final hipY = waistY + totalH * 0.14;
    final hipW = size.width * 0.46;
    final bottomY = topY + totalH;

    // Sisi Kiri Tubuh
    path.moveTo(cx - (headW * 0.22), neckTopY);
    path.quadraticBezierTo(
      cx - (shoulderW * 0.35),
      shoulderY - (totalH * 0.01),
      cx - (shoulderW / 2),
      shoulderY,
    );
    // Bahu ke Lengan Luar & Dada
    path.quadraticBezierTo(
      cx - (chestW * 0.6),
      chestY - (totalH * 0.03),
      cx - (chestW / 2),
      chestY,
    );
    // Dada ke Pinggang
    path.quadraticBezierTo(
      cx - (waistW * 0.55),
      (chestY + waistY) / 2,
      cx - (waistW / 2),
      waistY,
    );
    // Pinggang ke Pinggul
    path.quadraticBezierTo(
      cx - (hipW * 0.55),
      (waistY + hipY) / 2,
      cx - (hipW / 2),
      hipY,
    );
    // Pinggul ke Kaki Kiri
    path.quadraticBezierTo(
      cx - (hipW * 0.4),
      (hipY + bottomY) / 2,
      cx - (size.width * 0.12),
      bottomY,
    );

    // Antara Dua Kaki
    path.lineTo(cx - (size.width * 0.03), bottomY);
    path.lineTo(cx, hipY + (totalH * 0.08));
    path.lineTo(cx + (size.width * 0.03), bottomY);

    // Sisi Kanan Tubuh
    path.lineTo(cx + (size.width * 0.12), bottomY);
    path.quadraticBezierTo(
      cx + (hipW * 0.4),
      (hipY + bottomY) / 2,
      cx + (hipW / 2),
      hipY,
    );
    path.quadraticBezierTo(
      cx + (waistW * 0.55),
      (waistY + hipY) / 2,
      cx + (waistW / 2),
      waistY,
    );
    path.quadraticBezierTo(
      cx + (chestW * 0.55),
      (chestY + waistY) / 2,
      cx + (chestW / 2),
      chestY,
    );
    path.quadraticBezierTo(
      cx + (chestW * 0.6),
      chestY - (totalH * 0.03),
      cx + (shoulderW / 2),
      shoulderY,
    );
    path.quadraticBezierTo(
      cx + (shoulderW * 0.35),
      shoulderY - (totalH * 0.01),
      cx + (headW * 0.22),
      neckTopY,
    );

    // Gambar siluet dengan pola garis putus-putus halus
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 7.0;
    const dashSpace = 5.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant BodySilhouettePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
