import 'package:flutter/cupertino.dart';

/// Transisi sinematik halus peleburan atmosfer (Crossfade Dissolve).
/// Digunakan untuk perpindahan dari Badai Sinematik Pembuka menuju Gerbang Candi Bentar Dieng.
Route<T> cinematicFadeRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 320),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    opaque: true,
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
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
  Duration duration = const Duration(milliseconds: 300),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 280),
    opaque: true,
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}
