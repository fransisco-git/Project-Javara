import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../fashion/screens/clothing_catalog_screen.dart';
import '../fashion/screens/sinau_busana_screen.dart';
import '../fashion/screens/wardrobe_tab.dart';
import 'home_tab.dart';
import 'javara_bottom_nav.dart';
import 'profile_tab.dart';

/// Kerangka utama setelah login: 5 tab fokus busana Jawa Tengah + bar navigasi.
/// Tab: Beranda · Katalog · Studio (kapsul pusat) · Pustaka · Profil
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
      label: 'Katalog',
      activeIcon: Icons.storefront_rounded,
      inactiveIcon: Icons.storefront_outlined,
    ),
    NavItemData(
      label: 'Studio',
      activeIcon: Icons.checkroom_rounded,
      inactiveIcon: Icons.checkroom_outlined,
      isPill: true,
    ),
    NavItemData(
      label: 'Pustaka',
      activeIcon: Icons.menu_book_rounded,
      inactiveIcon: Icons.menu_book_outlined,
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
          systemNavigationBarColor: const Color(0xFFFAF6EE),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _index,
            children: [
              HomeTab(onOpenTab: (i) => setState(() => _index = i)),
              const ClothingCatalogScreen(isTab: true),
              const JBackground(
                variant: HeritageBackgroundVariant.wardrobe,
                child: WardrobeTab(),
              ),
              const JBackground(
                variant: HeritageBackgroundVariant.kuis,
                child: SinauBusanaScreen(isTab: true),
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
