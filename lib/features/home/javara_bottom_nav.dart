import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';

/// Data model untuk item navigasi bottom bar.
class NavItemData {
  const NavItemData({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
}

/// Floating Frosted Glass Capsule Bottom Navigation Bar khas JAVARA.
///
/// Karakteristik Desain & Interaktivitas:
/// 1. Frosted Obsidian Glassmorphism: Latar belakang kaca gelap translusen mewah
///    (`BackdropFilter` blur sigma 18) dengan gradien obsidian, specular hairline gold border,
///    dan bayangan elevasi bertingkat.
/// 2. Fluid Sliding Active Indicator: Titik emas adiluhung (`#FED897`) dan pendaran aura hangat
///    meluncur mulus (`AnimatedAlign` curve `easeOutCubic`) di atas permukaan kaca saat berpindah tab.
/// 3. Tactile Spring Feedback: Efek pegas elastis pada ikon saat ditekan (`0.92x` squash -> `1.08x` bounce)
///    disertai respon haptic getaran halus.
/// 4. Animated Icon & Typography Morph: Transisi crossfade mulus antara ikon outline dan solid,
///    serta transisi warna tipografi emas soga dinamis.
/// 5. 100% Bebas RenderFlex Overflow: Terproteksi dengan `FittedBox` dan `Flexible` untuk
///    layar sekecil 300px hingga skala teks 2.0x.
class JavaraBottomNav extends StatelessWidget {
  const JavaraBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<NavItemData> items;

  static const double _barHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFFED897);
    const inactiveColor = Color(0xFF8F857B);

    // Hitung posisi horizontal alignment tepat di tengah masing-masing slot tab
    final double slidingAlignmentX = items.isNotEmpty
        ? ((2 * index + 1) - items.length) / items.length
        : 0.0;

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        height: _barHeight,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.50),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFFDFB76C).withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36.0),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1E1712).withValues(alpha: 0.88),
                    const Color(0xFF120E0B).withValues(alpha: 0.82),
                  ],
                ),
                border: Border.all(color: const Color(0x38DFB76C), width: 1.0),
              ),
              child: Stack(
                children: [
                  IgnorePointer(
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment(slidingAlignmentX, 0.62),
                      child: Container(
                        width: 22,
                        height: 6,
                        alignment: Alignment.center,
                        child: Container(
                          width: 4.5,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: activeColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.85),
                                blurRadius: 5,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Expanded(
                          child: _InteractiveNavItem(
                            item: items[i],
                            isSelected: i == index,
                            activeColor: activeColor,
                            inactiveColor: inactiveColor,
                            onTap: () {
                              if (i != index) {
                                HapticFeedback.selectionClick();
                                onChanged(i);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Item Navigasi Standar Interaktif dengan Efek Pegas & Transisi Mulus
class _InteractiveNavItem extends StatefulWidget {
  const _InteractiveNavItem({
    required this.item,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final NavItemData item;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  State<_InteractiveNavItem> createState() => _InteractiveNavItemState();
}

class _InteractiveNavItemState extends State<_InteractiveNavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          setState(() => _isPressed = true);
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : (widget.isSelected ? 1.04 : 1.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon Navigasi dengan Efek Skala & Pendaran Halus
                AnimatedScale(
                  scale: widget.isSelected ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutBack,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                    child: Icon(
                      widget.isSelected
                          ? widget.item.activeIcon
                          : widget.item.inactiveIcon,
                      key: ValueKey(
                        '${widget.item.label}_${widget.isSelected}',
                      ),
                      size: 21,
                      color: widget.isSelected
                          ? widget.activeColor
                          : widget.inactiveColor,
                    ),
                  ),
                ),
                const SizedBox(height: 2),

                // Label Teks: Inter 11sp, semi-bold saat aktif, terproteksi FittedBox
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: JText.sans(
                        11.0,
                        weight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: widget.isSelected
                            ? widget.activeColor
                            : widget.inactiveColor,
                        letterSpacing: 0.1,
                      ),
                      child: Text(widget.item.label, maxLines: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
