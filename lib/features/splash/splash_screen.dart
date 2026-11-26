import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../services/auth_service.dart';
import '../../widgets/javara_widgets.dart';
import '../home/home_screen.dart';
import '../welcome/welcome_screen.dart';

/// Layar Pembuka (Splash Screen) Elegan JAVARA.
///
/// Mengusung identitas jenama busana adat Jawa Tengah:
/// - Pendaran kosmik Surya Mandala emas di balik lambang.
/// - Lambang resmi JAVARA dengan tipografi Aksara Jawa.
/// - Bilah pemuatan bertahap bernuansa budaya (cultural loading bar).
/// - Falsafah adiluhung busana Jawa ("Ajining Raga Saka Busana").
/// - Opsi lewati instan / ketuk layar untuk langsung masuk ke aplikasi.
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
    duration: const Duration(milliseconds: 2600),
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

  int _currentStepIndex = 0;
  static const List<String> _loadingSteps = [
    'Menyelaraskan Khasanah Busana Adat Jawa...',
    'Memuat Koleksi Busana & Ragam Kebaya...',
    'Menyiapkan Panduan Acara & Katalog Busana...',
    'Koleksi Busana Adat Siap Dijelajahi',
  ];

  static const List<String> _wisdomQuotes = [
    'Ajining Raga Saka Busana • Kehormatan Diri Tercermin dari Busana',
    'Memayu Hayuning Bawana • Menghadirkan Keindahan & Kebaikan',
    'Sura Dira Jayaningrat Lebur Dening Pangastuti',
  ];

  Timer? _bootTimer;
  Timer? _stepTimer;
  bool _isLoggedIn = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _progressController.forward();

    _stepTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (mounted && _currentStepIndex < _loadingSteps.length - 1) {
        setState(() => _currentStepIndex++);
      }
    });

    _boot();
  }

  void _boot() {
    AuthService.instance
        .isLoggedIn()
        .then((loggedIn) {
          if (mounted) {
            _isLoggedIn = loggedIn;
          }
        })
        .catchError((_) {});

    _bootTimer = Timer(const Duration(milliseconds: 2800), () {
      _navigateToNext();
    });
  }

  void _navigateToNext() {
    if (!mounted || _navigated) return;
    _navigated = true;
    _bootTimer?.cancel();
    _stepTimer?.cancel();
    HapticFeedback.selectionClick();

    Navigator.of(context).pushReplacement(
      fadeSlideRoute(
        _isLoggedIn
            ? const HomeScreen()
            : const WelcomeScreen(playGateOpen: true),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _bootTimer?.cancel();
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
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _navigateToNext,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _auraAnim,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _SplashMandalaPainter(_auraAnim.value),
                      );
                    },
                  ),
                ),
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoAnim,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.84,
                          end: 1.0,
                        ).animate(_logoAnim),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const RepaintBoundary(
                            child: JavaraLogo(size: 190),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

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
                            'WARISAN BUSANA JAWA TENGAH',
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
