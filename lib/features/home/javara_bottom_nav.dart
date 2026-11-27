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
    this.iconBuilder,
  });

  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Widget Function(BuildContext context, bool isSelected)? iconBuilder;
}

/// Floating Frosted Glass Capsule Bottom Navigation Bar khas JAVARA.
///
/// Karakteristik Desain:
/// 1. Frosted Obsidian Glassmorphism: Latar gelap beropasitas tinggi dengan
///    `BackdropFilter` blur sigma 18 dan border emas sangat tipis agar label
///    tetap terbaca jelas di atas foto terang.
/// 2. Struktur Identik di Semua Tab: Setiap tab memiliki ikon tetap 24×24 dalam
///    `SizedBox`, jarak tetap 4 px, dan label teks dengan baseline sejajar.
/// 3. Warna Aksen Seragam: State aktif memakai krem emas `#FED897` pada ikon
///    terisi maupun label (tanpa titik indikator bawah).
/// 4. 100% Bebas RenderFlex Overflow: Terproteksi `FittedBox` dan `Flexible`
///    untuk layar 300px hingga skala teks 2.0x.
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

  static const double barHeight = 64.0;
  static const double bottomMargin = 8.0;
  static const Color activeColor = JColors.accentGold;
  static const Color inactiveColor = Color(0xFFB8B0A6);
  static const Color surfaceColor = Color(0xFF16110D);

  /// Padding bawah standar untuk konten scrollable agar item terakhir
  /// tidak tertutup pil navbar mengambang.
  static double contentBottomPadding(
    BuildContext context, {
    double extra = 20.0,
  }) {
    return MediaQuery.paddingOf(context).bottom +
        barHeight +
        bottomMargin +
        extra;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        height: barHeight,
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: bottomMargin,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.48),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36.0),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1B1511).withValues(alpha: 0.94),
                    const Color(0xFF120E0B).withValues(alpha: 0.92),
                  ],
                ),
                border: Border.all(
                  color: const Color(0x18DFB76C),
                  width: 0.6,
                ),
              ),
              child: Row(
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
            ),
          ),
        ),
      ),
    );
  }
}

/// Item Navigasi Standar dengan Struktur Identik di Semua Tab
class _InteractiveNavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => HapticFeedback.lightImpact(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 24,
                child: Center(
                  child: item.iconBuilder != null
                      ? item.iconBuilder!(context, isSelected)
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeOutCubic,
                          transitionBuilder: (child, anim) {
                            final scale = Tween<double>(
                              begin: 0.9,
                              end: 1.0,
                            ).animate(anim);
                            return FadeTransition(
                              opacity: anim,
                              child: ScaleTransition(
                                scale: scale,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            isSelected ? item.activeIcon : item.inactiveIcon,
                            key: ValueKey('${item.label}_$isSelected'),
                            size: 24,
                            color: isSelected ? activeColor : inactiveColor,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 15,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomCenter,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    style: JText.sans(
                      11.0,
                      weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? activeColor : inactiveColor,
                      letterSpacing: 0.1,
                    ),
                    child: Text(item.label, maxLines: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
