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
    this.imageAlignment = const Alignment(0, -0.6),
  });

  final String eyebrow;
  final String title;
  final String imagePath;
  final Widget Function() routeBuilder;
  final Alignment imageAlignment;
}

/// Shared editorial hero slide template used across all 3 slides on the home screen.
///
/// Renders a full-bleed photo (`BoxFit.cover`, aligned upward at `Alignment(0, -0.6)`),
/// a bottom-only dark readability gradient (transparent up to 40% → ~85% black at bottom),
/// and left-aligned eyebrow, serif title, and 40 dp outline CTA above the in-hero indicator.
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
        // 1. Full-bleed garment photography aligned upward to keep face & upper garment clear
        Image.asset(
          data.imagePath,
          fit: BoxFit.cover,
          alignment: data.imageAlignment,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF14100D)),
        ),

        // 2. Bottom readability scrim (transparent up to 40% -> ~85% black at bottom)
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.40, 0.66, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0x94000000), // ~58% black under eyebrow for high contrast
                  Color(0xD9000000), // ~85% black at hero base
                ],
              ),
            ),
          ),
        ),

        // 3. Left-aligned editorial copy above the 3-segment indicator (12 dp from base)
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.eyebrow.toUpperCase(),
                  style: JText.sans(
                    10.5,
                    weight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.90),
                    letterSpacing: 2.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  data.title,
                  style: JText.editorial(
                    23,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: OutlinedButton(
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      ctaLabel,
                      style: JText.sans(
                        11,
                        weight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.8,
                      ),
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
