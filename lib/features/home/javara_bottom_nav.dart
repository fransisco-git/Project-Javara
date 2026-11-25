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

/// Bar Navigasi Bawah Datar Selebar Layar khas JAVARA.
///
/// Karakteristik Desain:
/// 1. Full-Width Flat Bar: Menempel di tepi bawah tanpa margin & tanpa radius,
///    latar hitam 92% dengan `BackdropFilter` blur, dan garis atas 1 px abu gelap.
/// 2. Struktur Identik di Semua Tab: 4 slot selebar sama, masing-masing berisi
///    ikon 24×24 dalam `SizedBox`, jarak tetap 4 px, lalu label huruf kapital.
/// 3. State Aktif & Nonaktif Minimalis: Aktif menggunakan ikon terisi + label putih,
///    nonaktif menggunakan ikon outline + label abu, tanpa titik indikator.
/// 4. Hormati SafeArea bawah dan 100% bebas RenderFlex overflow.
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

  static const double barHeight = 60.0;
  static const Color activeColor = Colors.white;
  static const Color inactiveColor = Color(0xFF8E8E93);
  static const Color surfaceColor = Colors.black;
  static const Color topBorderColor = Color(0xFF262626);

  /// Padding bawah standar untuk konten scrollable agar item terakhir
  /// tidak tertutup bottom navbar.
  static double contentBottomPadding(
    BuildContext context, {
    double extra = 20.0,
  }) {
    return MediaQuery.paddingOf(context).bottom + barHeight + extra;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: 0.92),
            border: const Border(
              top: BorderSide(color: topBorderColor, width: 1.0),
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: SizedBox(
              height: barHeight,
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
                          duration: const Duration(milliseconds: 200),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeOut,
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
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    style: JText.sans(
                      10.5,
                      weight: FontWeight.w500,
                      color: isSelected ? activeColor : inactiveColor,
                      letterSpacing: 1.0,
                    ),
                    child: Text(item.label.toUpperCase(), maxLines: 1),
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
