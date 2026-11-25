import 'package:flutter/material.dart';

/// Custom bottom-navbar icon for the Beranda tab: a two-door wardrobe
/// with upright rectangular silhouette, center seam, two small handles,
/// and two short legs at the bottom.
class NavIconWardrobe extends StatelessWidget {
  const NavIconWardrobe({
    super.key,
    required this.isActive,
    this.size = 24.0,
    this.inactiveColor = const Color(0xFFB8B0A6),
    this.activeColor = Colors.white,
    this.cutoutColor = const Color(0xFF18130E),
  });

  final bool isActive;
  final double size;
  final Color inactiveColor;
  final Color activeColor;
  final Color cutoutColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) {
          final scale = Tween<double>(begin: 0.9, end: 1.0).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
        child: CustomPaint(
          key: ValueKey<bool>(isActive),
          size: Size.square(size),
          painter: _NavWardrobePainter(
            isActive: isActive,
            inactiveColor: inactiveColor,
            activeColor: activeColor,
            cutoutColor: cutoutColor,
          ),
        ),
      ),
    );
  }
}

class _NavWardrobePainter extends CustomPainter {
  const _NavWardrobePainter({
    required this.isActive,
    required this.inactiveColor,
    required this.activeColor,
    required this.cutoutColor,
  });

  final bool isActive;
  final Color inactiveColor;
  final Color activeColor;
  final Color cutoutColor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4.5 * s, 2.5 * s, 15.0 * s, 16.5 * s),
      Radius.circular(2.0 * s),
    );

    if (!isActive) {
      final strokePaint = Paint()
        ..color = inactiveColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Upright two-door wardrobe outline
      canvas.drawRRect(bodyRect, strokePaint);

      // Center vertical divider line
      canvas.drawLine(
        Offset(12.0 * s, 2.5 * s),
        Offset(12.0 * s, 19.0 * s),
        strokePaint,
      );

      // Two small handles near the center line
      canvas.drawLine(
        Offset(9.5 * s, 9.6 * s),
        Offset(9.5 * s, 12.2 * s),
        strokePaint,
      );
      canvas.drawLine(
        Offset(14.5 * s, 9.6 * s),
        Offset(14.5 * s, 12.2 * s),
        strokePaint,
      );

      // Two short legs at the bottom
      canvas.drawLine(
        Offset(6.8 * s, 19.0 * s),
        Offset(6.8 * s, 21.5 * s),
        strokePaint,
      );
      canvas.drawLine(
        Offset(17.2 * s, 19.0 * s),
        Offset(17.2 * s, 21.5 * s),
        strokePaint,
      );
      return;
    }

    // Active state: filled white body + legs
    final fillPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(bodyRect, fillPaint);

    final legPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(6.8 * s, 18.8 * s),
      Offset(6.8 * s, 21.5 * s),
      legPaint,
    );
    canvas.drawLine(
      Offset(17.2 * s, 18.8 * s),
      Offset(17.2 * s, 21.5 * s),
      legPaint,
    );

    // Cutout seam and handles in navbar background color
    final seamCutoutPaint = Paint()
      ..color = cutoutColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * s
      ..strokeCap = StrokeCap.butt;

    canvas.drawLine(
      Offset(12.0 * s, 2.5 * s),
      Offset(12.0 * s, 19.0 * s),
      seamCutoutPaint,
    );

    final handleCutoutPaint = Paint()
      ..color = cutoutColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * s
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(9.5 * s, 9.6 * s),
      Offset(9.5 * s, 12.2 * s),
      handleCutoutPaint,
    );
    canvas.drawLine(
      Offset(14.5 * s, 9.6 * s),
      Offset(14.5 * s, 12.2 * s),
      handleCutoutPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NavWardrobePainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.cutoutColor != cutoutColor;
  }
}
