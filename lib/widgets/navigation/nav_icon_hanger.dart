import 'package:flutter/material.dart';

/// Custom bottom-navbar icon for the Koleksi tab: a minimal clothing hanger.
class NavIconHanger extends StatelessWidget {
  const NavIconHanger({
    super.key,
    required this.isActive,
    this.size = 24.0,
    this.inactiveColor = const Color(0xFFB8B0A6),
    this.activeColor = const Color(0xFFFED897),
  });

  final bool isActive;
  final double size;
  final Color inactiveColor;
  final Color activeColor;

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
          painter: _NavHangerPainter(
            isActive: isActive,
            inactiveColor: inactiveColor,
            activeColor: activeColor,
          ),
        ),
      ),
    );
  }
}

class _NavHangerPainter extends CustomPainter {
  const _NavHangerPainter({
    required this.isActive,
    required this.inactiveColor,
    required this.activeColor,
  });

  final bool isActive;
  final Color inactiveColor;
  final Color activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;

    // Top hook path
    final hookPath = Path()
      ..moveTo(9.8 * s, 6.4 * s)
      ..cubicTo(9.8 * s, 3.8 * s, 14.2 * s, 3.8 * s, 14.2 * s, 6.2 * s)
      ..cubicTo(14.2 * s, 7.6 * s, 12.0 * s, 8.1 * s, 12.0 * s, 9.6 * s);

    // Triangular shoulder + horizontal bar path
    final bodyPath = Path()
      ..moveTo(12.0 * s, 9.6 * s)
      ..lineTo(20.6 * s, 15.8 * s)
      ..quadraticBezierTo(21.7 * s, 16.6 * s, 21.2 * s, 17.7 * s)
      ..quadraticBezierTo(20.8 * s, 18.6 * s, 19.7 * s, 18.6 * s)
      ..lineTo(4.3 * s, 18.6 * s)
      ..quadraticBezierTo(3.2 * s, 18.6 * s, 2.8 * s, 17.7 * s)
      ..quadraticBezierTo(2.3 * s, 16.6 * s, 3.4 * s, 15.8 * s)
      ..close();

    if (!isActive) {
      final strokePaint = Paint()
        ..color = inactiveColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(hookPath, strokePaint);
      canvas.drawPath(bodyPath, strokePaint);
      return;
    }

    // Active state: filled white hanger silhouette + crisp white hook
    final fillPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    final hookPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(hookPath, hookPaint);
  }

  @override
  bool shouldRepaint(covariant _NavHangerPainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.activeColor != activeColor;
  }
}
