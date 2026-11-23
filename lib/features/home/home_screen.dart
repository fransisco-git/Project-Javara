import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../fashion/screens/clothing_catalog_screen.dart';
import '../fashion/screens/tersimpan_tab.dart';
import '../fashion/screens/wardrobe_tab.dart';
import 'home_tab.dart';
import 'javara_bottom_nav.dart';
import 'profile_tab.dart';

/// Kerangka utama setelah login: 5 tab fokus busana Jawa Tengah + floating capsule navigation bar.
/// Tab: Beranda · Koleksi · Wardrobe (Center Hero Pill) · Tersimpan · Profil
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _items = [
    NavItemData(
      label: 'Beranda',
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
    ),
    NavItemData(
      label: 'Koleksi',
      activeIcon: Icons.grid_view_rounded,
      inactiveIcon: Icons.grid_view_outlined,
    ),
    NavItemData(
      label: 'Wardrobe',
      activeIcon: Icons.checkroom_outlined,
      inactiveIcon: Icons.checkroom_outlined,
      isPill: true,
    ),
    NavItemData(
      label: 'Tersimpan',
      activeIcon: Icons.bookmark_rounded,
      inactiveIcon: Icons.bookmark_outline_rounded,
    ),
    NavItemData(
      label: 'Profil',
      activeIcon: Icons.person_rounded,
      inactiveIcon: Icons.person_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_index != 0) {
          setState(() => _index = 0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: const Color(0xFF14100D),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _index,
            children: [
              HomeTab(onOpenTab: (i) => setState(() => _index = i)),
              const ClothingCatalogScreen(isTab: true),
              WardrobeTab(
                onOpenCatalog: () => setState(() => _index = 1),
                initialSegment: 0,
              ),
              TersimpanTab(
                onOpenCatalog: () => setState(() => _index = 1),
                onOpenWardrobe: () => setState(() => _index = 2),
              ),
              JBackground(
                variant: HeritageBackgroundVariant.profile,
                child: SafeArea(
                  bottom: false,
                  child: ProfileTab(
                    onOpenTab: (i) => setState(() => _index = i),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: JavaraBottomNav(
            index: _index,
            items: _items,
            onChanged: (i) => setState(() => _index = i),
          ),
        ),
      ),
    );
  }
}
