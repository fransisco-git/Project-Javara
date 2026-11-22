import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';

/// Data model untuk item navigasi bottom bar.
class NavItemData {
  const NavItemData({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    this.isPill = false,
  });

  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final bool isPill;
}

/// Bar navigasi bawah 4-tab docked khas JAVARA berdesain retail minimalis (Uniqlo/H&M clarity).
///
/// Karakteristik Anti-AI-Slop:
/// 1. Flat, docked container dengan warna permukaan solid yang menyatu dengan tema aplikasi.
/// 2. Border hairline 1px di sisi atas tanpa drop-shadow tebal, tanpa gradasi dekoratif, dan tanpa efek glow.
/// 3. Ikon outline bersih saat inaktif, ikon filled solid saat aktif.
/// 4. Label tipografi Inter 11.5sp semi-bold berkontras tinggi dengan penanganan SafeArea bottom yang presisi.
/// 5. Menggunakan FittedBox protektif sehingga 100% bebas RenderFlex overflow di layar sempit (300px - 412px)
///    maupun skala teks besar (hingga 2.0x).
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

  static const double _barHeight = 58.0;

  @override
  Widget build(BuildContext context) {
    // Palet warna retail editorial JAVARA
    // Permukaan solid gelap mewah, border hairline tipis, warna aktif emas soga adiluhung
    const surfaceColor = Color(0xFF14100D);
    const hairlineBorderColor = Color(0x33DFB76C);
    const activeColor = Color(0xFFFFDF9E);
    const inactiveColor = Color(0xFF8F8073);

    return Container(
      decoration: const BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: BorderSide(
            color: hairlineBorderColor,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: SizedBox(
          height: _barHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _buildNavItem(
                    context: context,
                    itemIndex: i,
                    isSelected: i == index,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int itemIndex,
    required bool isSelected,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final item = items[itemIndex];

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: activeColor.withAlpha(20),
          highlightColor: Colors.transparent,
          onTap: () {
            if (!isSelected) {
              HapticFeedback.selectionClick();
            }
            onChanged(itemIndex);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon Navigasi: Clean outline saat inaktif, filled solid saat aktif
                Icon(
                  isSelected ? item.activeIcon : item.inactiveIcon,
                  size: 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 3),

                // Label Teks: Inter 11.5sp, semi-bold saat aktif, terproteksi FittedBox
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      style: JText.sans(
                        11.5,
                        weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? activeColor : inactiveColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
