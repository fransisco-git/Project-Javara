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

/// Floating Capsule Bottom Navigation Bar khas JAVARA berdesain retail luxury adiluhung.
///
/// Karakteristik Desain (Anti-AI-Slop & Editorial Parity):
/// 1. Floating Stadium Capsule: Mengambang di atas bottom SafeArea dengan margin samping 16dp
///    dan sudut kurva continuous capsule (`BorderRadius.circular(36)`).
/// 2. Luxury Obsidian Surface: Permukaan solid gelap mewah (`#161311`), dibingkai border hairline
///    emas Jawa Tengah halus (`Color(0x33DFB76C)`) serta ambient shadow lembut.
/// 3. Center Hero Action (Hanger Pill): Tombol pil stadium oval di posisi tengah (`#261D16`)
///    dengan outline emas solid (`Color(0xFFDFB76C)`) yang memuat ikon gantungan busana adat (hanger)
///    tanpa teks label di bawahnya.
/// 4. Indikator Titik Aktif: Dot emas (`#FED897`) berukuran 3.5px yang muncul tepat di bawah
///    teks label tab yang sedang aktif, tanpa menyebabkan layout shift.
/// 5. 100% Bebas RenderFlex Overflow: Diproteksi dengan FittedBox dan Flexible agar tetap stabil
///    di layar sekecil 300px hingga skala teks 2.0x.
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
    // Palet warna editorial retail mewah JAVARA
    const surfaceColor = Color(0xFF161311);
    const capsuleBorderColor = Color(0x33DFB76C);
    const activeColor = Color(0xFFFED897);
    const inactiveColor = Color(0xFF8F857B);
    const pillBgColor = Color(0xFF261D16);
    const pillBorderColor = Color(0xFFDFB76C);

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        height: _barHeight,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(36.0),
          border: Border.all(
            color: capsuleBorderColor,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: items[i].isPill
                      ? _buildPillItem(
                          context: context,
                          itemIndex: i,
                          isSelected: i == index,
                          pillBgColor: pillBgColor,
                          pillBorderColor: pillBorderColor,
                          activeColor: activeColor,
                        )
                      : _buildStandardNavItem(
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

  /// Membangun tombol aksi tengah berbentuk kapsul pil dengan outline emas (Hanger Hero)
  Widget _buildPillItem({
    required BuildContext context,
    required int itemIndex,
    required bool isSelected,
    required Color pillBgColor,
    required Color pillBorderColor,
    required Color activeColor,
  }) {
    final item = items[itemIndex];

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: activeColor.withAlpha(30),
          highlightColor: Colors.transparent,
          onTap: () {
            if (!isSelected) {
              HapticFeedback.selectionClick();
            }
            onChanged(itemIndex);
          },
          child: Center(
            child: Container(
              width: 62,
              height: 40,
              decoration: BoxDecoration(
                color: pillBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? activeColor : pillBorderColor,
                  width: isSelected ? 1.4 : 1.1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withAlpha(40),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Icon(
                item.activeIcon,
                size: 23,
                color: isSelected ? activeColor : const Color(0xFFE4C590),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Membangun item navigasi standar (Icon + Label + Indikator Titik Aktif)
  Widget _buildStandardNavItem({
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
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon Navigasi: Clean outline saat inaktif, filled solid saat aktif
                Icon(
                  isSelected ? item.activeIcon : item.inactiveIcon,
                  size: 21,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 2),

                // Label Teks: Inter 11sp, semi-bold saat aktif, terproteksi FittedBox
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      style: JText.sans(
                        11.0,
                        weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? activeColor : inactiveColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.5),

                // Dot Indikator: Titik emas 3.5px saat aktif (tetap memakan ruang saat inaktif agar anti-shift)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 3.5,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : Colors.transparent,
                    shape: BoxShape.circle,
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
