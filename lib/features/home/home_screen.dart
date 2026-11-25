import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../widgets/navigation/nav_icon_hanger.dart';
import '../../widgets/navigation/nav_icon_home.dart';
import '../fashion/screens/clothing_catalog_screen.dart';
import '../fashion/screens/tersimpan_tab.dart';
import 'home_tab.dart';
import 'javara_bottom_nav.dart';
import 'profile_tab.dart';

/// Kerangka utama setelah login: 4 tab fokus busana Jawa Tengah + floating capsule navigation bar.
/// Tab: Beranda · Koleksi · Tersimpan · Profil
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static Widget _buildBerandaIcon(BuildContext context, bool isSelected) {
    return NavIconHome(
      isActive: isSelected,
      activeColor: JavaraBottomNav.activeColor,
      inactiveColor: JavaraBottomNav.inactiveColor,
      cutoutColor: JavaraBottomNav.surfaceColor,
    );
  }

  static Widget _buildKoleksiIcon(BuildContext context, bool isSelected) {
    return NavIconHanger(
      isActive: isSelected,
      activeColor: JavaraBottomNav.activeColor,
      inactiveColor: JavaraBottomNav.inactiveColor,
    );
  }

  static const _items = [
    NavItemData(
      label: 'Beranda',
      activeIcon: Icons.home,
      inactiveIcon: Icons.home_outlined,
      iconBuilder: _buildBerandaIcon,
    ),
    NavItemData(
      label: 'Koleksi',
      activeIcon: Icons.grid_view_rounded,
      inactiveIcon: Icons.grid_view_outlined,
      iconBuilder: _buildKoleksiIcon,
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
              HomeTab(
                onOpenTab: (i) =>
                    setState(() => _index = i.clamp(0, _items.length - 1)),
              ),
              const ClothingCatalogScreen(isTab: true),
              TersimpanTab(
                onOpenCatalog: () => setState(() => _index = 1),
              ),
              JBackground(
                variant: HeritageBackgroundVariant.profile,
                child: SafeArea(
                  bottom: false,
                  child: ProfileTab(
                    onOpenTab: (i) =>
                        setState(() => _index = i.clamp(0, _items.length - 1)),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: RepaintBoundary(
            child: JavaraBottomNav(
              index: _index,
              items: _items,
              onChanged: (i) => setState(() => _index = i),
            ),
          ),
        ),
      ),
    );
  }
}
