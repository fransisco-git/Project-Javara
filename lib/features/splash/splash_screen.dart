import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/transitions.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../home/home_screen.dart';
import '../welcome/welcome_screen.dart';
import 'cinematic_intro.dart';

/// Layar Pembuka (Splash Screen) Sinematik JAVARA.
///
/// Memutar pertarungan sinematik pembuka Gatotkaca vs Aswatama
/// yang saling beradu tinju saat terbang dengan VFX film blockbuster,
/// ledakan petir fraktal, membuka lambang asli JAVARA,
/// lalu bertransisi mulus ke halaman Welcome dengan animasi terbukanya
/// gerbang Candi Bentar di Dataran Tinggi Dieng.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final loggedIn = await AuthService.instance.isLoggedIn();
      if (mounted) {
        setState(() => _isLoggedIn = loggedIn);
      }
    } catch (_) {}
  }

  void _onCinematicComplete() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      cinematicFadeRoute(
        _isLoggedIn ? const HomeScreen() : const WelcomeScreen(playGateOpen: true),
      ),
    );
  }

  void _onPrimaryAction() {
    Navigator.of(context).pushReplacement(
      fadeSlideRoute(_isLoggedIn ? const HomeScreen() : const LoginScreen()),
    );
  }

  void _onSecondaryAction() {
    Navigator.of(context).push(
      fadeSlideRoute(const LoginScreen()),
    );
  }

  void _onRegisterAction() {
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
        body: JavaraCinematicIntro(
          initialProgress: 0.0,
          autoPlay: true,
          onComplete: _onCinematicComplete,
          onPrimaryAction: _onPrimaryAction,
          onSecondaryAction: _onSecondaryAction,
          onRegisterAction: _onRegisterAction,
        ),
      ),
    );
  }
}
