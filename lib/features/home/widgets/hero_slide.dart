import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme.dart';

/// Immutable data model for a single editorial hero carousel slide.
class HeroSlideData {
  const HeroSlideData({
    required this.eyebrow,
    required this.title,
    required this.imagePath,
    required this.routeBuilder,
    this.imageAlignment = Alignment.topCenter,
  });

  final String eyebrow;
  final String title;
  final String imagePath;
  final Widget Function() routeBuilder;
  final Alignment imageAlignment;
}

/// Shared editorial hero slide template used across all 3 slides on the home screen.
///
/// Renders a full-bleed photo (`BoxFit.cover`), a bottom-only dark readability
/// gradient (transparent top → ~75% black bottom), and exactly three left-aligned
/// elements: uppercase eyebrow, large serif title, and a thin-outlined
/// "LIHAT KOLEKSI" button.
class HeroSlide extends StatelessWidget {
  const HeroSlide({
    super.key,
    required this.data,
    required this.onTapAction,
  });

  static const String ctaLabel = 'LIHAT KOLEKSI';

  final HeroSlideData data;
  final VoidCallback onTapAction;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Full-bleed garment photography
        Image.asset(
          data.imagePath,
          fit: BoxFit.cover,
          alignment: data.imageAlignment,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF14100D)),
        ),

        // 2. Bottom readability scrim only (transparent top -> 75% black bottom)
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.42, 0.72, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0x66000000),
                  Color(0xBF000000), // ~75% black
                ],
              ),
            ),
          ),
        ),

        // 3. Left-aligned editorial copy: eyebrow, serif title, outline CTA
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.eyebrow.toUpperCase(),
                  style: JText.sans(
                    11,
                    weight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 2.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  data.title,
                  style: JText.editorial(
                    28,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onTapAction();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.85),
                      width: 1.0,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    minimumSize: const Size(0, 42),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    ctaLabel,
                    style: JText.sans(
                      11.5,
                      weight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
