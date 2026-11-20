import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../widgets/motion.dart';
import '../auth/login_screen.dart';

/// Layar Selamat Datang JAVARA (Sesuai Desain Asli Page 2 - Android Compact - 5).
/// Latar naskah kuno hangat (warm parchment), tipografi anggun, dan tombol Mulai.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _start(BuildContext context) {
    Navigator.of(context).pushReplacement(fadeSlideRoute(const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: JColors.cream,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: JColors.cream,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    StaggerIn(
                      index: 0,
                      child: Text(
                        'Selamat Datang di',
                        style: JText.serif(22, color: JColors.ink),
                      ),
                    ),
                    const SizedBox(height: 4),
                    StaggerIn(
                      index: 1,
                      child: Text(
                        'JAVARA',
                        style: JText.serif(
                          44,
                          weight: FontWeight.w700,
                          color: JColors.ink,
                        ).copyWith(letterSpacing: 2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    StaggerIn(
                      index: 2,
                      child: Text(
                        'Jelajah budaya Jawa , Temukan rasa, karya , dan pengalaman terbaiknya',
                        style: JText.serif(
                          16,
                          color: JColors.ink,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Ilustrasi Candi / Lanskap Jawa (Persis Page 2)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/candi.png',
                          height: (h * 0.38).clamp(220.0, 360.0),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/home_hero.png',
                            height: (h * 0.38).clamp(220.0, 360.0),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Tombol Mulai (Persis Page 2)
                    StaggerIn(
                      index: 3,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFD4A343),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x20000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _start(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Mulai',
                            style: JText.serif(
                              16,
                              weight: FontWeight.w700,
                              color: const Color(0xFF261808),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
