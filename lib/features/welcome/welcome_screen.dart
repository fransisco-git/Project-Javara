import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../home/home_screen.dart';
import '../splash/splash_screen.dart';

/// Layar Selamat Datang JAVARA (Candi Bentar Gate & Dieng Sunset Experience).
///
/// Mengimplementasikan gerbang Candi Bentar khas Jawa Tengah (sesuai foto referensi pengguna):
/// - Kondisi awal: Gerbang tertutup rapat di tengah menutupi siluet gunung.
/// - Animasi pembukaan: Kedua pilar gerbang terbelah dan membuka perlahan ke kiri dan kanan
///   dengan kelembaman batu andesit alami dan rotasi perspektif 3D.
/// - Latar belakang: Pemandangan megah gunung berkabut senja keemasan dengan pantulan
///   air jernih (*mirror reflection*) dan lapisan kabut Dataran Tinggi Dieng yang merayap.
/// - Antarmuka pengguna: Tombol Masuk, Daftar, Jelajahi, dan tombol Putar Ulang Pertarungan Sinematik.
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

  @override
  void initState() {
    super.initState();

    // Kontroler animasi pembukaan gerbang candi (durasi 2600ms dengan akselerasi halus)
    _gateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
      value: widget.playGateOpen ? 0.0 : 1.0,
    );

    // Kontroler animasi ambien berkelanjutan (kabut merayap & denyut pendar senja)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    if (widget.playGateOpen) {
      // Jeda sejenak sebelum gerbang mulai membuka untuk memberi kesan megah
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          HapticFeedback.mediumImpact();
          _gateController.forward();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pra-muat aset gambar ke GPU memori
    precacheImage(const AssetImage('assets/images/user_candi_landscape.jpg'), context);
    precacheImage(const AssetImage('assets/images/user_gate_left_cut.png'), context);
    precacheImage(const AssetImage('assets/images/user_gate_right_cut.png'), context);
  }

  @override
  void dispose() {
    _gateController.dispose();
    _ambientController.dispose();
    super.dispose();
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

  void _onExploreAction() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pushReplacement(
      fadeSlideRoute(const HomeScreen()),
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

    // Lebar pilar gerbang terukur proporsional layar ponsel
    final gateWidth = (w * 0.48).clamp(160.0, 240.0);
    final gateHeight = gateWidth * (1024.0 / 275.0);

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

            // Progres terbukanya gerbang (kurva easeInOutCubic untuk kelembaman batu andesit)
            final openProgress = Curves.easeInOutCubic.transform(gateT);

            // Jarak geser gerbang dari tengah layar ke sisi kiri dan kanan
            final maxShift = w * 0.46;
            final gateShift = maxShift * openProgress;

            // Sudut rotasi perspektif 3D gerbang saat terbuka
            final gateRotateY = 0.12 * openProgress;

            // Opasitas dan pergeseran UI selamat datang
            double uiOpacity = 0.0;
            double uiSlideY = 24.0;
            if (gateT >= 0.50) {
              final sub = ((gateT - 0.50) / 0.50).clamp(0.0, 1.0);
              uiOpacity = Curves.easeOutQuad.transform(sub);
              uiSlideY = (1.0 - uiOpacity) * 24.0;
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                // ==========================================
                // 1. LAPISAN LATAR: Pemandangan Gunung & Pantulan Air
                // ==========================================
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/user_candi_landscape.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),

                // Gradien Atmosfer Senja Dieng
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0B1426).withValues(alpha: 0.35),
                          Colors.transparent,
                          const Color(0xFF1B0E14).withValues(alpha: 0.45),
                          const Color(0xFF08040C).withValues(alpha: 0.88),
                        ],
                        stops: const [0.0, 0.35, 0.70, 1.0],
                      ),
                    ),
                  ),
                ),

                // Pendar Cahaya Surya Senja di Balik Gunung
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DiengSunsetGlowPainter(
                      ambientTime: ambientT,
                      openProgress: openProgress,
                    ),
                  ),
                ),

                // Kabut Pegunungan Dieng Merayap (Parallax Mist Layers)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DiengParallaxMistPainter(
                      time: ambientT,
                      openProgress: openProgress,
                    ),
                  ),
                ),

                // ==========================================
                // 2. LAPISAN GERBANG CANDI BENTAR (Terbuka ke Kiri & Kanan)
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
                // 3. TOMBOL PUTAR ULANG PERTARUNGAN (Top Bar)
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
                          // Tombol Putar Ulang Pertarungan Sinematik
                          GestureDetector(
                            onTap: _onReplayBattleAction,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0x66000000),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0x33DFB76C),
                                  width: 0.9,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.replay_rounded,
                                    size: 15,
                                    color: Color(0xFFDFB76C),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Putar Ulang Pertarungan',
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

                          // Tombol Lewati / Jelajahi Tamu
                          GestureDetector(
                            onTap: _onExploreAction,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0x44000000),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0x22FFFFFF),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'Jelajahi',
                                style: JText.sans(
                                  11.5,
                                  weight: FontWeight.w500,
                                  color: const Color(0xCCFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ==========================================
                // 4. KONTEN SELAMAT DATANG EDITORIAL (Bottom Sheet UI)
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
                          padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF09050F).withValues(alpha: 0.85),
                                const Color(0xFF06030A),
                              ],
                              stops: const [0.0, 0.35, 1.0],
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Lambang Aksara Jawa dengan Pendaran Surya Emas
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0x22DFB76C),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: const Color(0x44DFB76C),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Text(
                                    'ꦗ ꦮ ꦫ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFFDFB76C),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 6,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Judul Utama Editorial
                                Text(
                                  'Sugeng Rawuh ing JAVARA',
                                  style: JText.serif(
                                    25,
                                    weight: FontWeight.w700,
                                    color: const Color(0xFFF7EFE4),
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 8),

                                // Subjudul Filosofis
                                Text(
                                  'Gerbang Khasanah Adat, Busana, & Budaya Luhur Jawa',
                                  style: JText.sans(
                                    13,
                                    color: const Color(0xFFB8A996),
                                    weight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 28),

                                // Tombol Masuk Akun (Primary Gold)
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _onLoginAction,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFDFB76C),
                                      foregroundColor: const Color(0xFF1E1408),
                                      elevation: 6,
                                      shadowColor: const Color(0x66DFB76C),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Masuk Akun',
                                          style: JText.sans(
                                            15.5,
                                            weight: FontWeight.w700,
                                            color: const Color(0xFF1E1408),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                          color: Color(0xFF1E1408),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Tombol Daftar Akun Baru (Outlined Subtle)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: _onSignUpAction,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFDFB76C),
                                      side: const BorderSide(
                                        color: Color(0x55DFB76C),
                                        width: 1.1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      'Daftar Akun Baru',
                                      style: JText.sans(
                                        14.5,
                                        weight: FontWeight.w600,
                                        color: const Color(0xFFDFB76C),
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
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM PAINTERS: Parallax Mountain Mist & Sunset Golden Glow
// ============================================================================

/// Melukis lapisan kabut Dataran Tinggi Dieng yang merayap di atas pantulan air
class _DiengParallaxMistPainter extends CustomPainter {
  _DiengParallaxMistPainter({
    required this.time,
    required this.openProgress,
  });

  final double time;
  final double openProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final mistPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36)
      ..style = PaintingStyle.fill;

    // Lapisan 1: Halimun melayang di sekitar dasar candi (y: h * 0.60)
    final offset1 = math.sin(time * 2 * math.pi) * 32.0;
    mistPaint.color = Color.fromRGBO(240, 225, 205, 0.16 * openProgress);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.45 + offset1, h * 0.58),
        width: w * 1.1,
        height: 65,
      ),
      mistPaint,
    );

    // Lapisan 2: Kabut dingin tipis di atas permukaan pantulan air (y: h * 0.72)
    final offset2 = math.cos(time * 2 * math.pi * 0.8) * 28.0;
    mistPaint.color = Color.fromRGBO(210, 220, 235, 0.12 * openProgress);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.55 + offset2, h * 0.72),
        width: w * 1.25,
        height: 75,
      ),
      mistPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DiengParallaxMistPainter old) =>
      old.time != time || old.openProgress != openProgress;
}

/// Melukis pendar keemasan lembut surya senja di balik gunung
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
    final pulse = 1.0 + 0.08 * math.sin(ambientTime * 2 * math.pi);
    final glowRadius = (w * 0.65) * pulse;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.fromRGBO(255, 240, 200, 0.32 * openProgress),
          Color.fromRGBO(223, 183, 108, 0.18 * openProgress),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: glowRadius));

    canvas.drawCircle(sunCenter, glowRadius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _DiengSunsetGlowPainter old) =>
      old.ambientTime != ambientTime || old.openProgress != openProgress;
}
