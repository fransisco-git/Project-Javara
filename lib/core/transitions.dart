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

/// Transisi modal khusus Pemutar Musik (Swara Jawa):
/// Meluncur halus dari bawah ke atas (seperti Spotify & Apple Music) dengan latar
/// solid 100% tanpa efek tembus pandang atau rendering ganda.
Route<T> musicPlayerRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    opaque: true,
    fullscreenDialog: true,
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}
