import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../services/auth_service.dart';
import '../../widgets/javara_widgets.dart';
import '../home/home_screen.dart';
import '../welcome/welcome_screen.dart';

/// Layar Pembuka (Splash Screen) Sinematik JAVARA.
/// Memadukan lambang kebesaran budaya Jawa Tengah, pendaran Surya Mandala emas,
/// bilah pemuatan bertahap (*realistic cultural loading bar*), dan peribahasa luhur Jawa.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  late final AnimationController _progressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  late final Animation<double> _logoAnim = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.1, 0.75, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _auraAnim = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.90, curve: Curves.easeInOut),
  );

  late final Animation<double> _textAnim = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.35, 0.95, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _loaderAnim = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
  );

  // Tahapan Pemuatan Realistis & Pepatah Luhur Jawa
  int _currentStepIndex = 0;
  static const List<String> _loadingSteps = [
    'Menyelaraskan Khasanah Budaya Jawa...',
    'Memuat Koleksi Busana & Candi 3D...',
    'Menyiapkan Studio & Pusaka Adat...',
    'Khasanah Jawa Siap Dijelajahi',
  ];

  static const List<String> _wisdomQuotes = [
    'Memayu Hayuning Bawana • Memperindah Keindahan Dunia',
    'Urip Iku Urup • Hidup Hendaknya Menyalakan Kebaikan',
    'Sura Dira Jayaningrat Lebur Dening Pangastuti',
  ];

  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _progressController.forward();

    _stepTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (mounted && _currentStepIndex < _loadingSteps.length - 1) {
        setState(() => _currentStepIndex++);
      }
    });

    _boot();
  }

  Future<void> _boot() async {
    final loggedInFuture = AuthService.instance.isLoggedIn();
    await Future.wait<void>([
      Future<void>.delayed(const Duration(milliseconds: 3100)),
    ]);
    final loggedIn = await loggedInFuture;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      fadeSlideRoute(
        loggedIn ? const HomeScreen() : const WelcomeScreen(),
        duration: const Duration(milliseconds: 750),
      ),
    );
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _progressController.dispose();
    _c.dispose();
    super.dispose();
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
        backgroundColor: const Color(0xFF07040B),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Pendaran Surya Mandala Emas Kosmik di Balik Logo
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _auraAnim,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _SplashMandalaPainter(_auraAnim.value),
                  );
                },
              ),
            ),

            // 2. Konten Tengah: Logo JAVARA & Tipografi Adiluhung
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _logoAnim,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.82,
                        end: 1.0,
                      ).animate(_logoAnim),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const JavaraLogo(size: 190),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Aksara Jawa & Subjudul Emas
                  FadeTransition(
                    opacity: _textAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ꦗ ꦮ ꦫ',
                          style: TextStyle(
                            fontSize: 22,
                            color: Color(0xCCDFB76C),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'WARISAN BUDAYA JAWA TENGAH',
                          style: JText.serif(
                            11,
                            weight: FontWeight.w700,
                            color: const Color(0xFFEADBCA),
                          ).copyWith(letterSpacing: 3.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Bilah Pemuatan Realistis Budaya (Realistic Cultural Loading Bar)
            Positioned(
              bottom: 40,
              left: 36,
              right: 36,
              child: FadeTransition(
                opacity: _loaderAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Teks Status Pemuatan Berubah Dinamis
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _loadingSteps[_currentStepIndex],
                        key: ValueKey(_currentStepIndex),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDFB76C),
                          letterSpacing: 0.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Garis Progres Emas dengan Efek Shimmer
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        final progress = _progressController.value;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            height: 3.5,
                            width: double.infinity,
                            color: const Color(0x33DFB76C),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress.clamp(0.05, 1.0),
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF8C5D17),
                                      Color(0xFFDFB76C),
                                      Color(0xFFFFF3D1),
                                      Color(0xFFDFB76C),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x88DFB76C),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Falsafah Luhur Jawa
                    Text(
                      _wisdomQuotes[_currentStepIndex % _wisdomQuotes.length],
                      style: JText.serif(
                        9.5,
                        color: const Color(0x99A89989),
                      ).copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Melukis cincin mandala suci dan pendaran aura emas di belakang lambang.
class _SplashMandalaPainter extends CustomPainter {
  _SplashMandalaPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width * 0.48;

    // 1. Pendaran Radial Inti
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFDF9E48).withValues(alpha: 0.25 * progress),
          const Color(0xFF8C5D17).withValues(alpha: 0.12 * progress),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxR));
    canvas.drawCircle(center, maxR, glowPaint);

    // 2. Cincin Geometri Suci (Concentric Sacred Rings)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFFFDF9E).withValues(alpha: 0.14 * progress)
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, 120 * progress, ringPaint);
    canvas.drawCircle(center, 155 * progress, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _SplashMandalaPainter old) =>
      old.progress != progress;
}
