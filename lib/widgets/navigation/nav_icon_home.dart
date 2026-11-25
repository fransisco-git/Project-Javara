import 'package:flutter/material.dart';

/// Custom bottom-navbar icon for the Beranda tab: a crisp architectural house
/// with a sharp triangular roof, rectangular body, and a small centered door.
class NavIconHome extends StatelessWidget {
  const NavIconHome({
    super.key,
    required this.isActive,
    this.size = 24.0,
    this.inactiveColor = const Color(0xFFB8B0A6),
    this.activeColor = const Color(0xFFFED897),
    this.cutoutColor = const Color(0xFF16110D),
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
          painter: _NavHomePainter(
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

class _NavHomePainter extends CustomPainter {
  const _NavHomePainter({
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

    // Crisp house silhouette: triangular roof + rectangular body, no chimney, no curves
    final housePath = Path()
      ..moveTo(12.0 * s, 3.0 * s)
      ..lineTo(20.5 * s, 10.5 * s)
      ..lineTo(20.5 * s, 20.5 * s)
      ..lineTo(3.5 * s, 20.5 * s)
      ..lineTo(3.5 * s, 10.5 * s)
      ..close();

    if (!isActive) {
      final strokePaint = Paint()
        ..color = inactiveColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * s
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.miter;

      canvas.drawPath(housePath, strokePaint);

      // Small rectangular door at bottom center
      final doorPath = Path()
        ..moveTo(9.5 * s, 20.5 * s)
        ..lineTo(9.5 * s, 13.8 * s)
        ..lineTo(14.5 * s, 13.8 * s)
        ..lineTo(14.5 * s, 20.5 * s);

      canvas.drawPath(doorPath, strokePaint);
      return;
    }

    // Active state: filled house body + door cutout in navbar background color
    final fillPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(housePath, fillPaint);

    final cutoutPaint = Paint()
      ..color = cutoutColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(9.5 * s, 13.8 * s, 5.0 * s, 6.8 * s),
      cutoutPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NavHomePainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.cutoutColor != cutoutColor;
  }
}
