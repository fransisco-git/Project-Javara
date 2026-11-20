import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/transitions.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../splash/cinematic_intro.dart';

/// Layar Selamat Datang JAVARA (Redesigned Editorial & Cinematic Landscape).
/// Mengusung pemandangan senja berkabut Dataran Tinggi Dieng Jawa Tengah,
/// bingkai gerbang Candi Bentar adiluhung, dan tipografi editorial minimalis.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    this.playCinematicOnInit = false,
  });

  final bool playCinematicOnInit;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<JavaraCinematicIntroState> _introKey =
      GlobalKey<JavaraCinematicIntroState>();

  void _onPrimaryAction() {
    Navigator.of(context).pushReplacement(
      fadeSlideRoute(const LoginScreen()),
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
          key: _introKey,
          initialProgress: widget.playCinematicOnInit ? 0.0 : 1.0,
          autoPlay: widget.playCinematicOnInit,
          onComplete: () {},
          onPrimaryAction: _onPrimaryAction,
          onSecondaryAction: _onSecondaryAction,
          onRegisterAction: _onRegisterAction,
        ),
      ),
    );
  }
}
