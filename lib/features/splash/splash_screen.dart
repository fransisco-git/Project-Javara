import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/transitions.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../home/home_screen.dart';
import '../welcome/welcome_screen.dart';
import 'cinematic_intro.dart';

/// Layar Pembuka (Splash Screen) Sinematik JAVARA.
/// Memadukan narasi duel ksatria Gatotkaca vs Aswatama, benturan tinju sakti,
/// penyingkapan lambang asli JAVARA, hingga terbukanya gerbang Candi Bentar
/// dengan latar senja berkabut Dataran Tinggi Dieng Jawa Tengah.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  bool _hasSeenCinematic = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkStatusAndInit();
  }

  Future<void> _checkStatusAndInit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool('has_seen_cinematic') ?? false;
      final loggedIn = await AuthService.instance.isLoggedIn();

      if (!mounted) return;

      setState(() {
        _hasSeenCinematic = hasSeen;
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });

      // Jika sudah pernah melihat sinematik sebelumnya:
      if (hasSeen) {
        // Tampilkan jeda anggun 1.8 detik untuk pemuatan status sebelum routing
        await Future.delayed(const Duration(milliseconds: 1800));
        if (!mounted) return;

        if (loggedIn) {
          Navigator.of(context).pushReplacement(
            fadeSlideRoute(const HomeScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const WelcomeScreen(playCinematicOnInit: false),
              transitionDuration: const Duration(milliseconds: 650),
              transitionsBuilder: (_, animation, _, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasSeenCinematic = false;
        });
      }
    }
  }

  Future<void> _markCinematicAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_cinematic', true);
    } catch (_) {}
  }

  void _onPrimaryAction() {
    _markCinematicAsSeen();
    Navigator.of(context).pushReplacement(
      fadeSlideRoute(_isLoggedIn ? const HomeScreen() : const LoginScreen()),
    );
  }

  void _onSecondaryAction() {
    _markCinematicAsSeen();
    Navigator.of(context).push(
      fadeSlideRoute(const LoginScreen()),
    );
  }

  void _onRegisterAction() {
    _markCinematicAsSeen();
    Navigator.of(context).push(
      fadeSlideRoute(const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF07040B),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF06040A),
        body: _isLoading
            // Tampilan inisial gelap cepat sebelum preferensi terbaca
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDFB76C)),
                  ),
                ),
              )
            : _hasSeenCinematic
                // Tampilan Pemuatan Cepat Elegan untuk Pengguna Berulang (Subsequent Launch)
                ? JavaraCinematicIntro(
                    initialProgress: 0.54, // Langsung ke Scene 6: Lambang Asli JAVARA & Loader
                    autoPlay: false,
                    onComplete: () {},
                    onPrimaryAction: _onPrimaryAction,
                    onSecondaryAction: _onSecondaryAction,
                    onRegisterAction: _onRegisterAction,
                  )
                // Sinematik Lengkap 9 Adegan untuk Peluncuran Pertama (First Launch)
                : JavaraCinematicIntro(
                    initialProgress: 0.0,
                    autoPlay: true,
                    onComplete: _markCinematicAsSeen,
                    onPrimaryAction: _onPrimaryAction,
                    onSecondaryAction: _onSecondaryAction,
                    onRegisterAction: _onRegisterAction,
                  ),
      ),
    );
  }
}
