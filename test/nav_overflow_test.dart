import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/features/home/javara_bottom_nav.dart';

void main() {
  const items = [
    NavItemData(
      label: 'Beranda',
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
    ),
    NavItemData(
      label: 'Jelajah',
      activeIcon: Icons.explore_rounded,
      inactiveIcon: Icons.explore_outlined,
    ),
    NavItemData(
      label: 'Wardrobe',
      activeIcon: Icons.checkroom_rounded,
      inactiveIcon: Icons.checkroom_outlined,
      isPill: true,
    ),
    NavItemData(
      label: 'Katalog',
      activeIcon: Icons.storefront_rounded,
      inactiveIcon: Icons.storefront_outlined,
    ),
    NavItemData(
      label: 'Profil',
      activeIcon: Icons.person_rounded,
      inactiveIcon: Icons.person_outline_rounded,
    ),
  ];

  testWidgets('Detect overflow errors on various widths and text scales', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
    };

    try {
      final widths = [300.0, 320.0, 340.0, 360.0, 375.0, 390.0, 412.0];
      final textScales = [0.8, 1.0, 1.2, 1.5, 2.0];

      for (final width in widths) {
        for (final scale in textScales) {
          tester.view.physicalSize = Size(width * 2, 800 * 2);
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 800),
                  textScaler: TextScaler.linear(scale),
                ),
                child: Scaffold(
                  bottomNavigationBar: JavaraBottomNav(
                    index: 0,
                    items: items,
                    onChanged: (_) {},
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
        }
      }

      final overflowErrors = errors.where((e) => e.toString().contains('overflowed')).toList();
      expect(overflowErrors, isEmpty, reason: 'Found overflows: ${overflowErrors.map((e) => e.summary).toList()}');
    } finally {
      FlutterError.onError = originalOnError;
    }
  });
}
