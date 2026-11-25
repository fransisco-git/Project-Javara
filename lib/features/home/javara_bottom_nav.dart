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

/// Bar Navigasi Bawah Datar Solid Selebar Layar khas JAVARA.
///
/// Karakteristik Desain:
/// 1. Full-Width Solid Flat Bar: Menempel di tepi bawah tanpa margin dan tanpa
///    border radius, latar hitam pekat solid (#0D0C0B), garis atas 1 px #262626.
/// 2. Struktur Identik di Semua Tab: 4 slot selebar sama, ikon 24×24, jarak 4 px,
///    dan label huruf kapital (10.5, letterSpacing 1.0, FontWeight.w500).
/// 3. State Aktif & Nonaktif Tegas: Aktif putih (#FFFFFF) dengan ikon terisi,
///    nonaktif abu (#8E8E93) dengan ikon outline, tanpa titik indikator.
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
  static const Color surfaceColor = Color(0xFF0D0C0B);
  static const Color topBorderColor = Color(0xFF262626);

  /// Padding bawah standar untuk konten scrollable di atas bottom bar solid
  /// (Scaffold menggunakan `extendBody: false`, sehingga konten berhenti tepat
  /// di atas navbar dan cukup diberi ruang napas bawah yang rapi).
  static double contentBottomPadding(
    BuildContext context, {
    double extra = 24.0,
  }) {
    return extra;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: surfaceColor,
        border: Border(
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
