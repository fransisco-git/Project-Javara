import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme.dart';

/// Clipper khusus untuk memotong tampilan sisi kiri slider komparasi.
class _WipeClipper extends CustomClipper<Rect> {
  const _WipeClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(covariant _WipeClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}

/// Widget slider pembanding Sebelum / Sesudah (Before/After Wipe Slider).
/// Memungkinkan pengguna menggeser pemisah horizontal secara interaktif untuk
/// melihat perbedaan sebelum dan sesudah pengenaan busana adat.
class BeforeAfterWipeSlider extends StatefulWidget {
  const BeforeAfterWipeSlider({
    super.key,
    required this.beforeChild,
    required this.afterChild,
    this.initialPosition = 0.5,
    this.beforeLabel = 'Foto Anda',
    this.afterLabel = 'Busana Adat',
  });

  final Widget beforeChild;
  final Widget afterChild;
  final double initialPosition;
  final String beforeLabel;
  final String afterLabel;

  @override
  State<BeforeAfterWipeSlider> createState() => _BeforeAfterWipeSliderState();
}

class _BeforeAfterWipeSliderState extends State<BeforeAfterWipeSlider> {
  late double _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition.clamp(0.0, 1.0);
  }

  void _updatePosition(double localDx, double width) {
    if (width <= 0) return;
    final newPos = (localDx / width).clamp(0.05, 0.95);
    if ((newPos - _position).abs() > 0.005) {
      setState(() => _position = newPos);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Semantics(
          label: 'Penggeser perbandingan sebelum dan sesudah busana',
          slider: true,
          value: '${(_position * 100).toInt()}%',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) {
              HapticFeedback.selectionClick();
              _updatePosition(details.localPosition.dx, w);
            },
            onHorizontalDragUpdate: (details) {
              _updatePosition(details.localPosition.dx, w);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Lapisan Belakang: Foto Sesudah (After / Busana Adat)
                Positioned.fill(child: widget.afterChild),

                // 2. Lapisan Depan (Clipped): Foto Sebelum (Before / Foto Pengguna)
                Positioned.fill(
                  child: ClipRect(
                    clipper: _WipeClipper(_position),
                    child: widget.beforeChild,
                  ),
                ),

                // 3. Label Penunjuk di Atas
                Positioned(
                  top: 14,
                  left: 14,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _position > 0.15 ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: JColors.antiqueGold.withAlpha(100),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        widget.beforeLabel,
                        style: JText.sans(
                          11,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _position < 0.85 ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: JColors.antiqueGold.withAlpha(100),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        widget.afterLabel,
                        style: JText.sans(
                          11,
                          weight: FontWeight.w600,
                          color: JColors.antiqueGold,
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Garis Pembatas Vertikal (Gold Divider)
                Positioned(
                  left: (w * _position) - 1.0,
                  top: 0,
                  bottom: 0,
                  width: 2.0,
                  child: Container(color: JColors.antiqueGold),
                ),

                // 5. Tombol Handle Geser (Diameter 40dp, Touch Area 48dp)
                Positioned(
                  left: (w * _position) - 24.0,
                  top: (h / 2) - 24.0,
                  width: 48.0,
                  height: 48.0,
                  child: Center(
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: JColors.antiqueGold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(120),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.compare_arrows_rounded,
                          color: JColors.deepJavaBrown,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
