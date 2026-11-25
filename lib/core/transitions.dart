import 'package:flutter/cupertino.dart';

/// Transisi sinematik halus peleburan atmosfer (Crossfade Dissolve).
/// Digunakan untuk perpindahan dari Badai Sinematik Pembuka menuju Gerbang Candi Bentar Dieng.
Route<T> cinematicFadeRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 650),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    opaque: true,
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: child,
      );
    },
  );
}

/// Transisi halaman standar aplikasi: geser halus dari kanan (Native iOS & Android).
/// Opaque 100%, bebas dari efek ghosting / tumpang tindih transparansi layar.
Route<T> fadeSlideRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 320),
}) {
  return CupertinoPageRoute<T>(
    builder: (_) => page,
  );
}
