import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

/// Foto dari assets/images/ dengan sudut membulat dan pengganti jika file belum ada.
class AssetPhoto extends StatelessWidget {
  const AssetPhoto({
    super.key,
    required this.file,
    this.radius = 16,
    this.aspectRatio,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.semanticLabel,
  });

  final String file;
  final double radius;
  final double? aspectRatio;
  final double? width;
  final double? height;
  final AlignmentGeometry alignment;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget img = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        'assets/images/$file',
        fit: BoxFit.cover,
        alignment: alignment,
        filterQuality: FilterQuality.medium,
        width: width,
        height: height,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
        frameBuilder: (_, child, frame, sync) => AnimatedOpacity(
          opacity: (sync || frame != null) ? 1 : 0,
          duration: const Duration(milliseconds: 400),
          child: child,
        ),
        errorBuilder: (_, _, _) => Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD9C3A0), Color(0xFF9C7B57)],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              color: Color(0x88FFFBF4),
              size: 28,
            ),
          ),
        ),
      ),
    );
    if (aspectRatio != null) {
      img = AspectRatio(aspectRatio: aspectRatio!, child: img);
    }
    return img;
  }
}

/// Efek mengecil sedikit saat ditekan; dipakai untuk kartu yang bisa diketuk.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
  });
  final Widget child;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Label kecil huruf kapital di atas judul (mis. "RASA KHAS YOGYAKARTA").
TextStyle tagStyle() => JText.serif(
  10,
  weight: FontWeight.w700,
  color: JColors.terracotta,
).copyWith(letterSpacing: 0.6);
