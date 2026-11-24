import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../home/home_screen.dart';

/// Layar Selamat Datang JAVARA — Heritage Sunrise Borobudur & Budaya Luhur Jawa Tengah.
///
/// Pengalaman pembuka yang tenang, otentik, dan megah:
/// - Pelataran suci Candi Borobudur dengan Arca Buddha di sisi kiri menghadap fajar Merapi.
/// - Halimun dan kabut lembah sawah merayap lembut dengan pendaran surya fajar.
/// - Kartu editorial budaya JAVARA langsung menyambut penjelajah budaya tanpa jeda gerbang.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    this.playGateOpen = false,
  });

  final bool playGateOpen;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;
  AudioPlayer? _ambientPlayer;
  bool _isAudioPlaying = false;
  double _pointerX = 0.0;
  double _pointerY = 0.0;

  @override
  void initState() {
    super.initState();

    // Kontroler ambien fajar berkelanjutan (pendar surya, kabut lembah, & partikel)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _startAmbientFoley();
  }

  void _startAmbientFoley() async {
    try {
      _ambientPlayer = AudioPlayer();
      await _ambientPlayer?.setSource(
        AssetSource('audio/candi_bentar_ambient_10s.wav'),
      );
      await _ambientPlayer?.setVolume(0.70);
      await _ambientPlayer?.resume();
      if (mounted) {
        setState(() => _isAudioPlaying = true);
      }
    } catch (_) {
      // Graceful fallback jika audio service sedang tidak aktif atau di mode test
    }
  }

  void _toggleAudio() async {
    try {
      HapticFeedback.lightImpact();
      if (_isAudioPlaying) {
        await _ambientPlayer?.pause();
        if (mounted) setState(() => _isAudioPlaying = false);
      } else {
        await _ambientPlayer?.resume();
        if (mounted) setState(() => _isAudioPlaying = true);
      }
    } catch (_) {}
  }

  void _stopAmbientFoley() {
    try {
      _ambientPlayer?.stop();
      _ambientPlayer?.dispose();
      _ambientPlayer = null;
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pra-muat panorama megah Borobudur Buddha & Merapi
    precacheImage(
      const AssetImage('assets/images/borobudur_buddha_merapi_dawn.jpg'),
      context,
    );
  }

  void _updatePointer(Offset localPosition, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final px = ((localPosition.dx / size.width) * 2.0 - 1.0).clamp(-1.0, 1.0);
    final py = ((localPosition.dy / size.height) * 2.0 - 1.0).clamp(-1.0, 1.0);
    if ((px - _pointerX).abs() > 0.01 || (py - _pointerY).abs() > 0.01) {
      setState(() {
        _pointerX = px;
        _pointerY = py;
      });
    }
  }

  @override
  void dispose() {
    _stopAmbientFoley();
    _ambientController.dispose();
    super.dispose();
  }

  void _onPrimaryExplore() {
    _stopAmbientFoley();
    HapticFeedback.selectionClick();
    Navigator.of(context).pushReplacement(
      fadeSlideRoute(const HomeScreen()),
    );
  }

  void _onLoginAction() {
    _stopAmbientFoley();
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      fadeSlideRoute(const LoginScreen()),
    );
  }

  void _onSignUpAction() {
    _stopAmbientFoley();
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      fadeSlideRoute(const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF07040B),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF040206),
        body: AnimatedBuilder(
          animation: _ambientController,
          builder: (context, _) {
            final ambientT = _ambientController.value;

            // Panorama tunggal otentik: Pelataran Candi Borobudur dengan Patung Buddha & Fajar Merapi
            const String panoramaAsset =
                'assets/images/borobudur_buddha_merapi_dawn.jpg';

            return Listener(
              onPointerMove: (e) => _updatePointer(e.localPosition, size),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Panorama Megah Candi Borobudur & Fajar Merapi dengan Patung Buddha di Kiri
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(_pointerX * -10.0, _pointerY * -6.0),
                      child: Transform.scale(
                        scale: 1.05,
                        alignment: Alignment.center,
                        child: Image.asset(
                          panoramaAsset,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),

                  // 2. Pendaran Surya Fajar di Balik Puncak Gunung Merapi
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MerapiSunriseGlowPainter(
                        ambientTime: ambientT,
                        openProgress: 1.0,
                      ),
                    ),
                  ),

                  // 3. Kabut Lembah & Sawah Berundak Merayap Lembut (Valley Mist)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ValleyMistPainter(
                        time: ambientT,
                        openProgress: 1.0,
                      ),
                    ),
                  ),

                  // 4. Partikel Keemasan Surya Mengapung Lembut di Udara
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SunlightMotesPainter(
                        time: ambientT,
                        progress: 1.0,
                      ),
                    ),
                  ),

                  // 5. Bilah Navigasi Atas Bersih & Elegan
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Kiri: Logo Teks Luxury JAVARA
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x55000000),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0x44DFB76C),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Text(
                                    'J A V A R A',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 3.5,
                                      color: Color(0xFFFFFDF8),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Tengah: Aksara Jawa "Javara"
                            const Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'ꦗ ꦮ ꦫ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xCCDFB76C),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Kanan: Foley Ambien Candi Audio Badge / Toggle
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: _toggleAudio,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0x55000000),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0x44DFB76C),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _isAudioPlaying
                                              ? Icons.graphic_eq_rounded
                                              : Icons.volume_off_rounded,
                                          size: 13,
                                          color: const Color(0xFFDFB76C),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          _isAudioPlaying ? 'Foley Candi' : 'Suara Mati',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFFFDF9E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 6. Kartu Editorial Sambutan Budaya (Langsung Muncul Secara Utuh)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        h < 700 ? 16 : 28,
                        20,
                        math.max(
                          MediaQuery.of(context).padding.bottom + 6,
                          20.0,
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF07040C).withValues(alpha: 0.50),
                            const Color(0xFF050308).withValues(alpha: 0.92),
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

                              const SizedBox(height: 12),

                              // Headline: "Mengenal warisan.\nMemahami makna."
                              Text(
                                'Mengenal warisan.\nMemahami makna.',
                                style: JText.serif(
                                  26,
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

                              // Deskripsi Khasanah Busana Adat
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
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

                              const SizedBox(height: 22),

                              // Tombol Utama: "Mulai Eksplorasi Budaya →"
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _onPrimaryExplore,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E1712),
                                    foregroundColor: const Color(0xFFF7EFE4),
                                    elevation: 4,
                                    shadowColor: const Color(0x44000000),
                                    side: const BorderSide(
                                      color: Color(0xFFDFB76C),
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Mulai Eksplorasi Budaya',
                                          style: JText.sans(
                                            15,
                                            weight: FontWeight.w700,
                                            color: const Color(0xFFFFDF9E),
                                          ).copyWith(
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 17,
                                          color: Color(0xFFFFDF9E),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Tombol Masuk ke Akun Anda (Tonal Terang Kontras)
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _onLoginAction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDFB76C),
                                    foregroundColor: const Color(0xFF140C06),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Masuk ke Akun Anda',
                                      style: JText.sans(
                                        14,
                                        weight: FontWeight.w700,
                                        color: const Color(0xFF140C06),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Tombol Daftar Akun Baru (Outlined Halus)
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: OutlinedButton(
                                  onPressed: _onSignUpAction,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFD4C8B8),
                                    side: const BorderSide(
                                      color: Color(0x44DFB76C),
                                      width: 0.8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Daftar Akun Baru',
                                      style: JText.sans(
                                        13.5,
                                        weight: FontWeight.w600,
                                        color: const Color(0xFFD4C8B8),
                                      ),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Melukis partikel keemasan melayang di udara (Sunlight Motes)
class _SunlightMotesPainter extends CustomPainter {
  _SunlightMotesPainter({
    required this.time,
    required this.progress,
  });

  final double time;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const int moteCount = 22;
    final motePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < moteCount; i++) {
      final speed = 0.25 + (i * 0.12 % 0.65);
      final baseY = (i * 40.0) % h;
      final driftY = (baseY - (time * 110.0 * speed)) % h;
      final driftX =
          ((i * 35.0) % w) + math.sin(time * 2 * math.pi + i) * 14.0;

      final alpha =
          ((math.sin(time * 3 * math.pi + i).abs() * 0.40 + 0.20) * progress)
              .clamp(0.0, 1.0);
      final radius = 1.2 + (i % 3) * 0.7;

      motePaint.color = Color.fromRGBO(255, 235, 175, alpha);
      canvas.drawCircle(Offset(driftX, driftY), radius, motePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunlightMotesPainter old) =>
      old.time != time || old.progress != progress;
}

/// Melukis pendar surya fajar lembut di balik puncak Gunung Merapi
class _MerapiSunriseGlowPainter extends CustomPainter {
  _MerapiSunriseGlowPainter({
    required this.ambientTime,
    required this.openProgress,
  });

  final double ambientTime;
  final double openProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Posisi puncak kerucut Merapi di sepertiga tengah
    final sunCenter = Offset(w * 0.50, h * 0.38);
    final pulse = 1.0 + 0.05 * math.sin(ambientTime * 2 * math.pi);
    final glowRadius = (w * 0.72) * pulse;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.fromRGBO(255, 220, 150, 0.42 * openProgress),
          Color.fromRGBO(220, 150, 160, 0.20 * openProgress),
          Colors.transparent,
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: glowRadius));

    canvas.drawCircle(sunCenter, glowRadius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _MerapiSunriseGlowPainter old) =>
      old.ambientTime != ambientTime || old.openProgress != openProgress;
}

/// Melukis lapisan kabut lembah dan sawah berundak yang merayap tenang
class _ValleyMistPainter extends CustomPainter {
  _ValleyMistPainter({
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

    // Lapisan 1: Kabut fajar di lembah sawah berundak
    final offset1 = math.sin(time * 2 * math.pi) * 28.0;
    mistPaint.color = Color.fromRGBO(215, 210, 225, 0.18 * openProgress);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.48 + offset1, h * 0.56),
        width: w * 1.20,
        height: 65,
      ),
      mistPaint,
    );

    // Lapisan 2: Halimun tipis di atas pepohonan hutan
    final offset2 = math.cos(time * 2 * math.pi * 0.75) * 24.0;
    mistPaint.color = Color.fromRGBO(175, 195, 210, 0.14 * openProgress);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.52 + offset2, h * 0.70),
        width: w * 1.30,
        height: 75,
      ),
      mistPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ValleyMistPainter old) =>
      old.time != time || old.openProgress != openProgress;
}
