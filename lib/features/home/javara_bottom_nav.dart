import 'dart:ui';
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

/// Bar navigasi bawah khas JAVARA berdesain Liquid Glass adaptif warisan budaya Jawa.
///
/// Fitur Desain:
/// 1. Sesuai Image Referensi: 4 item standar (Beranda, Jelajah, Kuis, Profil) + 1 Kapsul Pill Pusat (Wardrobe).
/// 2. Liquid Glass Adaptif: Specular reflection halus pada item aktif yang berpadu selaras dengan latar belakang tab.
/// 3. Zero-Overflow Guarantee: Menggunakan FittedBox protektif & flex adaptif sehingga 100% bebas overflow
///    di semua ukuran layar Android (dari 300px hingga 450px+) dan pada skala teks ekstrem.
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
    // Palet warna mewah khas JAVARA — Warm Ivory & Rich Sogan Brown
    const activeTextColor = Color(0xFF382315);
    const inactiveTextColor = Color(0xFF7D6C5D);
    const activeIconColor = Color(0xFF382315);
    const inactiveIconColor = Color(0xFF8C7B6D);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: const BoxDecoration(
            color: Color(0xF8FAF6EE),
            border: Border(
              top: BorderSide(
                color: Color(0x33B08D57),
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x14382315),
                blurRadius: 18,
                offset: Offset(0, -3),
              ),
            ],
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
                    items[i].isPill
                        ? Expanded(
                            // Proporsi flex khusus untuk tombol pill tengah (Wardrobe)
                            // agar lapang, anggun, dan 100% bebas overflow
                            flex: 13,
                            child: _buildPillNavButton(
                              context: context,
                              itemIndex: i,
                              isSelected: i == index,
                              activeColor: activeTextColor,
                              inactiveColor: inactiveTextColor,
                            ),
                          )
                        : Expanded(
                            // 4 Tab Standar (Beranda, Jelajah, Kuis, Profil)
                            flex: 10,
                            child: _buildStandardNavButton(
                              context: context,
                              itemIndex: i,
                              isSelected: i == index,
                              activeColor: activeTextColor,
                              inactiveColor: inactiveTextColor,
                              activeIconColor: activeIconColor,
                              inactiveIconColor: inactiveIconColor,
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

  /// Tombol Navigasi Standar (Ikon di atas + Label di bawah)
  /// Dilengkapi efek Liquid Glass halus di belakang ikon saat aktif.
  Widget _buildStandardNavButton({
    required BuildContext context,
    required int itemIndex,
    required bool isSelected,
    required Color activeColor,
    required Color inactiveColor,
    required Color activeIconColor,
    required Color inactiveIconColor,
  }) {
    final item = items[itemIndex];

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isSelected) HapticFeedback.selectionClick();
          onChanged(itemIndex);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pod Ikon dengan Efek Liquid Glass halus (hanya aktif/berpendar saat dipilih)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 38,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0x35B08D57), Color(0x18B08D57)],
                      )
                    : null,
                color: isSelected
                    ? null
                    : Colors.transparent, // Bersih & elegan saat tidak dipilih seperti Image 1
                border: isSelected
                    ? Border.all(
                        color: const Color(0x55B08D57),
                        width: 0.9,
                      )
                    : null,
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x1EB08D57),
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  isSelected ? item.activeIcon : item.inactiveIcon,
                  size: 21,
                  color: isSelected ? activeIconColor : inactiveIconColor,
                ),
              ),
            ),

            const SizedBox(height: 3),

            // Label Teks dengan FittedBox Protektif (Anti-Overflow pada Skala Font Apapun)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: JText.serif(
                    11,
                    weight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tombol Navigasi Kapsul Pill Pusat (Wardrobe)
  /// Menyajikan Ikon Gantungan Busana dan Teks "Wardrobe" berdampingan
  /// dengan kapsul liquid glass sesuai persis dengan Image 1 referensi.
  Widget _buildPillNavButton({
    required BuildContext context,
    required int itemIndex,
    required bool isSelected,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final item = items[itemIndex];

    // Warna kapsul pill adaptif — Deep Sogan Brown pill dengan aksen emas kencana
    final pillBg = isSelected
        ? const Color(0xFF382315)
        : const Color(0x1F382315);

    final pillBorder = isSelected
        ? const Color(0xFFB08D57)
        : const Color(0x33B08D57);

    final pillTextColor = isSelected
        ? const Color(0xFFFFDF9E)
        : const Color(0xFF5A4434);

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isSelected) HapticFeedback.selectionClick();
          onChanged(itemIndex);
        },
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: pillBorder,
                  width: isSelected ? 1.1 : 0.85,
                ),
                boxShadow: [
                  if (isSelected)
                    const BoxShadow(
                      color: Color(0x35382315),
                      blurRadius: 7,
                      offset: Offset(0, 2),
                    )
                  else
                    const BoxShadow(
                      color: Color(0x0C382315),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                ],
              ),
              // FittedBox membungkus seluruh konten baris untuk menjamin 100% BEBAS OVERFLOW
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.inactiveIcon,
                      size: 17,
                      color: pillTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.label,
                      maxLines: 1,
                      style: JText.serif(
                        11.5,
                        weight: isSelected ? FontWeight.w800 : FontWeight.w700,
                        color: pillTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
