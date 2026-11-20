import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../home/home_screen.dart';
import '../splash/splash_screen.dart';

/// Layar Selamat Datang JAVARA (Refined Editorial & Candi Bentar Sunset Experience).
///
/// Disempurnakan sesuai panduan Prompt 2:
/// - Latar pemandangan gunung & senja Dataran Tinggi Dieng mendominasi visual secara alami.
/// - Gerbang Candi Bentar andesit Jawa Tengah tertutup di awal, lalu membuka perlahan
///   ke kiri dan kanan dengan kelembaman batu alami dan rotasi perspektif 3D.
/// - Suasana dingin berkabut dengan gradien senja bersahaja: muted amber, dusty pink,
///   blue-gray, dan violet-gray (menghindari oranye jenuh atau fantasi kartun).
/// - Tipografi editorial luhur tanpa kartu tebal yang menghalangi pemandangan:
///   * Headline: "Mengenal warisan. Memahami makna."
///   * Description: "Jelajahi busana adat Jawa Tengah, filosofi, sejarah, dan nilai budaya yang diwariskan lintas generasi."
///   * Primary Button: "Mulai Eksplorasi Budaya →"
///   * Secondary Action: "Masuk ke Akun Anda"
///   * Register Text: "Belum memiliki akun? Daftar di sini"
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    this.playGateOpen = true,
  });

  final bool playGateOpen;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _gateController;
  late final AnimationController _ambientController;
  Timer? _gateDelayTimer;

  @override
  void initState() {
    super.initState();

    // Animasi pembukaan gerbang candi: 2600ms dengan akselerasi & deselerasi alami
    _gateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
      value: widget.playGateOpen ? 0.0 : 1.0,
    );

    // Animasi ambien berkelanjutan (kabut merayap lembut & denyut pendar senja)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8500),
    )..repeat();

    if (widget.playGateOpen) {
      _gateDelayTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          HapticFeedback.lightImpact();
          _gateController.forward();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pra-muat aset gambar ke memori GPU untuk rendering instan tanpa jeda
    precacheImage(const AssetImage('assets/images/user_candi_landscape.jpg'), context);
    precacheImage(const AssetImage('assets/images/user_gate_left_cut.png'), context);
    precacheImage(const AssetImage('assets/images/user_gate_right_cut.png'), context);
  }

  @override
  void dispose() {
    _gateDelayTimer?.cancel();
    _gateController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  void _onPrimaryExplore() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pushReplacement(
      fadeSlideRoute(const HomeScreen()),
    );
  }

  void _onLoginAction() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      fadeSlideRoute(const LoginScreen()),
    );
  }

  void _onSignUpAction() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      fadeSlideRoute(const SignUpScreen()),
    );
  }

  void _onReplayBattleAction() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      cinematicFadeRoute(const SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Dimensi pilar gerbang terukur proporsional terhadap tinggi dan lebar layar ponsel
    final gateHeight = (h * 0.72).clamp(380.0, 720.0);
    final gateWidth = gateHeight * (275.0 / 1024.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF07040B),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF06040A),
        body: AnimatedBuilder(
          animation: Listenable.merge([_gateController, _ambientController]),
          builder: (context, _) {
            final gateT = _gateController.value;
            final ambientT = _ambientController.value;

            // Kurva pembukaan gerbang: kelembaman batu andesit alami (easeInOutCubic)
            final openProgress = Curves.easeInOutCubic.transform(gateT);

            // Jarak geser gerbang dari titik temu tengah ke arah luar
            final maxShift = w * 0.45;
            final gateShift = maxShift * openProgress;

            // Rotasi perspektif 3D halus saat gerbang membuka
            final gateRotateY = 0.11 * openProgress;

            // Transisi kemunculan UI editorial (mulai aktif saat gerbang terbuka 45%)
            double uiOpacity = 0.0;
            double uiSlideY = 20.0;
            if (gateT >= 0.45) {
              final sub = ((gateT - 0.45) / 0.55).clamp(0.0, 1.0);
              uiOpacity = Curves.easeOutCubic.transform(sub);
              uiSlideY = (1.0 - uiOpacity) * 20.0;
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                // ==========================================
                // 1. LAPISAN PEMANDANGAN: Panorama Gunung & Pantulan Air
                // ==========================================
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/user_candi_landscape.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),

                // Gradien Atmosfer Senja Dataran Tinggi Dieng (Muted Tones)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF161C2C).withValues(alpha: 0.28), // Slate blue
                          Colors.transparent,
                          const Color(0xFF261824).withValues(alpha: 0.38), // Muted violet-gray
                          const Color(0xFF09060E).withValues(alpha: 0.88), // Ground shadow
                        ],
                        stops: const [0.0, 0.32, 0.68, 1.0],
                      ),
                    ),
                  ),
                ),

                // Pendaran Surya Senja Hangat di Balik Puncak Gunung
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DiengSunsetGlowPainter(
                      ambientTime: ambientT,
                      openProgress: openProgress,
                    ),
                  ),
                ),

                // Kabut Pegunungan Dieng Merayap Lembut (Parallax Mist)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DiengParallaxMistPainter(
                      time: ambientT,
                      openProgress: openProgress,
                    ),
                  ),
                ),

                // ==========================================
                // 2. GERBANG CANDI BENTAR (Membuka ke Kiri & Kanan)
                // ==========================================
                // Pilar Sayap Kiri Candi Bentar (Membuka ke Kiri)
                Positioned(
                  left: (w * 0.50 - gateWidth) - gateShift,
                  top: h * 0.08,
                  width: gateWidth,
                  height: gateHeight,
                  child: Transform(
                    alignment: Alignment.centerRight,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(-gateRotateY),
                    child: Image.asset(
                      'assets/images/user_gate_left_cut.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ),

                // Pilar Sayap Kanan Candi Bentar (Membuka ke Kanan)
                Positioned(
                  left: (w * 0.50) + gateShift,
                  top: h * 0.08,
                  width: gateWidth,
                  height: gateHeight,
                  child: Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(gateRotateY),
                    child: Image.asset(
                      'assets/images/user_gate_right_cut.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),

                // ==========================================
                // 3. BILAH ATAS: Tombol Putar Ulang Sinematik
                // ==========================================
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tombol Putar Ulang Pertarungan Sinematik (Understated Pill)
                          GestureDetector(
                            onTap: _onReplayBattleAction,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0x55000000),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0x33DFB76C),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.replay_rounded,
                                    size: 14,
                                    color: Color(0xFFDFB76C),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Putar Ulang Sinematik',
                                    style: JText.sans(
                                      11.5,
                                      weight: FontWeight.w600,
                                      color: const Color(0xFFDFB76C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Indikator Aksara Jawa Halus
                          const Text(
                            'ꦗ ꦮ ꦫ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0x88DFB76C),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ==========================================
                // 4. KONTEN SELAMAT DATANG EDITORIAL (Restrained & Dominant Landscape)
                // ==========================================
                if (uiOpacity > 0.0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: uiOpacity,
                      child: Transform.translate(
                        offset: Offset(0, uiSlideY),
                        child: Container(
                          // Scrim gradien lembut tanpa kartu tebal yang menghalangi lanskap
                          padding: EdgeInsets.fromLTRB(
                            28,
                            h < 700 ? 20 : 36,
                            28,
                            math.max(MediaQuery.of(context).padding.bottom + 4, 20.0),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF07040C).withValues(alpha: 0.45),
                                const Color(0xFF050308).withValues(alpha: 0.90),
                                const Color(0xFF040206).withValues(alpha: 0.98),
                              ],
                              stops: const [0.0, 0.28, 0.65, 1.0],
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                              children: [
                                // Aksara Jawa & Garis Pembatas Halus
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 0.8,
                                      color: const Color(0x55DFB76C),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'ꦗ ꦮ ꦫ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFDFB76C),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 6,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 22,
                                      height: 0.8,
                                      color: const Color(0x55DFB76C),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                // Headline: "Mengenal warisan. Memahami makna."
                                Text(
                                  'Mengenal warisan.\nMemahami makna.',
                                  style: JText.serif(
                                    27,
                                    weight: FontWeight.w700,
                                    color: const Color(0xFFF7EFE4),
                                  ).copyWith(
                                    height: 1.22,
                                    letterSpacing: -0.3,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xAA000000),
                                        blurRadius: 14,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 10),

                                // Description: "Jelajahi busana adat Jawa Tengah..."
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    'Jelajahi busana adat Jawa Tengah, filosofi, sejarah, dan nilai budaya yang diwariskan lintas generasi.',
                                    style: JText.sans(
                                      13.5,
                                      color: const Color(0xFFC8BDB2),
                                      weight: FontWeight.w400,
                                    ).copyWith(
                                      height: 1.55,
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x99000000),
                                          blurRadius: 10,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                const SizedBox(height: 26),

                                // Primary CTA: "Mulai Eksplorasi Budaya →" (Understated Antique Gold Accent)
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _onPrimaryExplore,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E1712),
                                      foregroundColor: const Color(0xFFF7EFE4),
                                      elevation: 4,
                                      shadowColor: const Color(0x44000000),
                                      side: const BorderSide(
                                        color: Color(0x88DFB76C),
                                        width: 1.1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Mulai Eksplorasi Budaya',
                                          style: JText.sans(
                                            15.5,
                                            weight: FontWeight.w600,
                                            color: const Color(0xFFF7EFE4),
                                          ).copyWith(letterSpacing: 0.4),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 17,
                                          color: Color(0xFFDFB76C),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Secondary Action: "Masuk ke Akun Anda"
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: TextButton(
                                    onPressed: _onLoginAction,
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFFC8BDB2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Masuk ke Akun Anda',
                                      style: JText.sans(
                                        14,
                                        weight: FontWeight.w500,
                                        color: const Color(0xFFD6CBC0),
                                      ).copyWith(letterSpacing: 0.3),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // Register Text: "Belum memiliki akun? Daftar di sini"
                                GestureDetector(
                                  onTap: _onSignUpAction,
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text: 'Belum memiliki akun? ',
                                        style: JText.sans(
                                          12.5,
                                          color: const Color(0x99B8A996),
                                          weight: FontWeight.w400,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Daftar di sini',
                                            style: JText.sans(
                                              12.5,
                                              color: const Color(0xFFDFB76C),
                                              weight: FontWeight.w600,
                                            ).copyWith(
                                              decoration: TextDecoration.underline,
                                              decorationColor: const Color(0x66DFB76C),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM PAINTERS: Parallax Highland Mist & Restrained Sunset Glow
// ============================================================================

/// Melukis lapisan kabut Dataran Tinggi Dieng yang merayap di atas air
class _DiengParallaxMistPainter extends CustomPainter {
  _DiengParallaxMistPainter({
    required this.time,
    required this.openProgress,
  });

  final double time;
  final double openProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (openProgress <= 0.05) return;

    final w = size.width;
    final h = size.height;

    final mistPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 38)
      ..style = PaintingStyle.fill;

    // Lapisan 1: Halimun melayang di sekitar dasar gerbang candi (y: h * 0.58)
    final offset1 = math.sin(time * 2 * math.pi) * 30.0;
    mistPaint.color = Color.fromRGBO(190, 180, 195, 0.15 * openProgress);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.46 + offset1, h * 0.58),
        width: w * 1.15,
        height: 60,
      ),
      mistPaint,
    );

    // Lapisan 2: Kabut dingin tipis di atas permukaan pantulan air (y: h * 0.72)
    final offset2 = math.cos(time * 2 * math.pi * 0.75) * 26.0;
    mistPaint.color = Color.fromRGBO(155, 170, 190, 0.11 * openProgress);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.54 + offset2, h * 0.72),
        width: w * 1.25,
        height: 70,
      ),
      mistPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DiengParallaxMistPainter old) =>
      old.time != time || old.openProgress != openProgress;
}

/// Melukis pendar keemasan bersahaja surya senja di balik gunung (muted amber & dusty rose)
class _DiengSunsetGlowPainter extends CustomPainter {
  _DiengSunsetGlowPainter({
    required this.ambientTime,
    required this.openProgress,
  });

  final double ambientTime;
  final double openProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (openProgress <= 0.05) return;

    final w = size.width;
    final h = size.height;

    final sunCenter = Offset(w * 0.50, h * 0.38);
    final pulse = 1.0 + 0.06 * math.sin(ambientTime * 2 * math.pi);
    final glowRadius = (w * 0.62) * pulse;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.fromRGBO(235, 205, 160, 0.28 * openProgress), // Warm muted amber core
          Color.fromRGBO(160, 120, 140, 0.14 * openProgress), // Dusty rose transition
          Colors.transparent,
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: glowRadius));

    canvas.drawCircle(sunCenter, glowRadius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _DiengSunsetGlowPainter old) =>
      old.ambientTime != ambientTime || old.openProgress != openProgress;
}
