import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../home/home_screen.dart';

/// Konstanta path aset latar panorama Candi Borobudur & Merapi fajar.
const String kWelcomeHeroAsset =
    'assets/images/borobudur_buddha_merapi_dawn.jpg';

/// Warna aksen emas prada dan cokelat gelap khas layar selamat datang JAVARA
/// (diturunkan dari token desain dan palet layar yang ada, ~#E0B865 & ~#1A120B).
const Color _kCtaGold = Color(0xFFDFB76C);
const Color _kDarkBrown = Color(0xFF140C06);
const Color _kDarkBrownBg = Color(0xFF100905);
const Color _kScrimDarkBrown = Color(0xFF140D07);

/// Layar Selamat Datang JAVARA — Heritage Sunrise Borobudur & Budaya Luhur Jawa Tengah.
///
/// Pengalaman pembuka yang tenang, otentik, dan megah:
/// - Pelataran suci Candi Borobudur dengan Arca Buddha di sisi kiri menghadap fajar Merapi.
/// - Halimun dan kabut lembah sawah merayap lembut dengan pendaran surya fajar.
/// - Scrim gradasi pekat memastikan keterbacaan tipografi budaya dengan kontras tinggi.
/// - Hierarki CTA tunggal "Mulai Eksplorasi Budaya →" disertai akses cepat Masuk & Daftar.
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
    with TickerProviderStateMixin {
  late final AnimationController _ambientController;
  late final AnimationController _entranceController;

  late final Animation<double> _headlineAnim;
  late final Animation<double> _subtitleAnim;
  late final Animation<double> _primaryCtaAnim;
  late final Animation<double> _secondaryCtaAnim;

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

    // Kontroler animasi masuk bertahap (fade + slide ke atas ~16px)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _headlineAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.00, 0.65, curve: Curves.easeOutCubic),
    );
    _subtitleAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.12, 0.77, curve: Curves.easeOutCubic),
    );
    _primaryCtaAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.24, 0.89, curve: Curves.easeOutCubic),
    );
    _secondaryCtaAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 1.00, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();

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
    // Pra-muat panorama megah Borobudur Buddha & Merapi fajar
    precacheImage(
      const AssetImage(kWelcomeHeroAsset),
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
    _entranceController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  Future<void> _onPrimaryExplore() async {
    _stopAmbientFoley();
    HapticFeedback.selectionClick();
    // Otomatis masuk menggunakan Akun Tamu (Guest User)
    await AuthService.instance.signInAsGuest();
    if (!mounted) return;
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

  Widget _buildStaggeredItem({
    required Animation<double> animation,
    required bool disableAnimations,
    required Widget child,
  }) {
    if (disableAnimations) {
      return child;
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (context, c) {
        final progress = animation.value;
        return Opacity(
          opacity: math.max(0.001, progress.clamp(0.0, 1.0)),
          child: Transform.translate(
            offset: Offset(0, 16.0 * (1.0 - progress)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

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
                          kWelcomeHeroAsset,
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

                  // 5. Scrim gradasi pekat bawah: transparan di sekitar 40% tinggi layar menuju cokelat-hitam opak (>=0.92)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.40, 0.65, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              _kScrimDarkBrown.withValues(alpha: 0.85),
                              _kDarkBrownBg.withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 6. Bilah Navigasi Atas: Wordmark JAVARA kiri atas & Tombol Audio kanan atas
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Wordmark JAVARA kiri atas (teks polos sans-serif bold & spaced sesuai foto referensi)
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Semantics(
                                  header: true,
                                  label: 'JAVARA',
                                  child: Text(
                                    'J A V A R A',
                                    style: JText.sans(
                                      20,
                                      weight: FontWeight.w800,
                                      color: const Color(0xFFFFFDF8),
                                      letterSpacing: 4.8,
                                    ).copyWith(
                                      shadows: const [
                                        Shadow(
                                          color: Color(0xAA000000),
                                          blurRadius: 6,
                                          offset: Offset(0, 1.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Tombol audio kanan atas (lingkaran 44x44, ikon volume_up / volume_off)
                            Semantics(
                              button: true,
                              label: _isAudioPlaying
                                  ? 'Suara ambient: aktif'
                                  : 'Suara ambient: nonaktif',
                              child: Tooltip(
                                message: _isAudioPlaying
                                    ? 'Matikan suara ambient'
                                    : 'Nyalakan suara ambient',
                                child: Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: _toggleAudio,
                                    child: Ink(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0x38000000),
                                        border: Border.all(
                                          color: _kCtaGold.withValues(alpha: 0.20),
                                          width: 0.8,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x22000000),
                                            blurRadius: 6,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _isAudioPlaying
                                              ? Icons.volume_up_rounded
                                              : Icons.volume_off_rounded,
                                          size: 22,
                                          color: _isAudioPlaying
                                              ? _kCtaGold
                                              : const Color(0xFFA69584),
                                        ),
                                      ),
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

                  // 7. Blok Konten Bawah: Headline, Subtitle, Tombol Utama & Masuk/Daftar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: math.max(
                          200.0,
                          h - (MediaQuery.of(context).padding.top + 76.0),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          h < 700 ? 14 : 24,
                          24,
                          math.max(
                            24.0 + MediaQuery.of(context).viewPadding.bottom,
                            24.0,
                          ),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.30, 1.0],
                            colors: [
                              Colors.transparent,
                              _kDarkBrownBg.withValues(alpha: 0.82),
                              const Color(0xFF0C0704).withValues(alpha: 0.96),
                            ],
                          ),
                        ),
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Elemen aksara Jawa di atas headline — disembunyikan sesuai arahan (teks kode: 'ꦗ ꦮ ꦫ')
                              // Row(
                              //   mainAxisSize: MainAxisSize.min,
                              //   children: [
                              //     Container(
                              //       width: 22,
                              //       height: 0.8,
                              //       color: const Color(0x55DFB76C),
                              //     ),
                              //     const SizedBox(width: 10),
                              //     const Text(
                              //       'ꦗ ꦮ ꦫ',
                              //       style: TextStyle(
                              //         fontSize: 14,
                              //         color: Color(0xFFDFB76C),
                              //         fontWeight: FontWeight.w700,
                              //         letterSpacing: 6,
                              //       ),
                              //     ),
                              //     const SizedBox(width: 10),
                              //     Container(
                              //       width: 22,
                              //       height: 0.8,
                              //       color: const Color(0x55DFB76C),
                              //     ),
                              //   ],
                              // ),

                              // 1. Headline (Font Serif, 32-34sp atau 28sp jika h < 700, line height 1.15, putih penuh)
                              _buildStaggeredItem(
                                animation: _headlineAnim,
                                disableAnimations: disableAnimations,
                                child: Text(
                                  'Mengenal warisan.\nMemahami makna.',
                                  style: JText.serif(
                                    h < 700 ? 28 : 34,
                                    weight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.15,
                                  ).copyWith(
                                    letterSpacing: -0.3,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xAA000000),
                                        blurRadius: 12,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: h < 700 ? 8 : 12),

                              // 2. Subtitle (15sp, w400, putih opacity 0.88, line height 1.5, maks 3 baris)
                              _buildStaggeredItem(
                                animation: _subtitleAnim,
                                disableAnimations: disableAnimations,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'Jelajahi busana adat Jawa Tengah, filosofi, sejarah, dan nilai budaya yang diwariskan lintas generasi.',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: JText.sans(
                                      15,
                                      weight: FontWeight.w400,
                                      color: Colors.white.withValues(alpha: 0.88),
                                      height: 1.5,
                                    ).copyWith(
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x99000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: h < 700 ? 14 : 20),

                              // 3. Tombol Utama Satu-satunya: "Mulai Eksplorasi Budaya →" (Solid emas, teks cokelat gelap w600, tinggi 56, radius 12)
                              _buildStaggeredItem(
                                animation: _primaryCtaAnim,
                                disableAnimations: disableAnimations,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _onPrimaryExplore,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _kCtaGold,
                                      foregroundColor: _kDarkBrown,
                                      elevation: 2,
                                      shadowColor: const Color(0x33000000),
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
                                              weight: FontWeight.w600,
                                              color: _kDarkBrown,
                                            ).copyWith(
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                            color: _kDarkBrown,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: h < 700 ? 4 : 8),

                              // 4. Baris Masuk / Daftar (TextButton Masuk w600 emas & TextButton Daftar putih opacity 0.75 dipisah titik tengah, tap >= 48dp)
                              _buildStaggeredItem(
                                animation: _secondaryCtaAnim,
                                disableAnimations: disableAnimations,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: _onLoginAction,
                                        style: TextButton.styleFrom(
                                          minimumSize: const Size(48, 48),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: Text(
                                          'Masuk',
                                          style: JText.sans(
                                            14,
                                            weight: FontWeight.w600,
                                            color: _kCtaGold,
                                          ),
                                        ),
                                      ),
                                      const ExcludeSemantics(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 2),
                                          child: Text(
                                            '·',
                                            style: TextStyle(
                                              color: Color(0x80FFFFFF),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _onSignUpAction,
                                        style: TextButton.styleFrom(
                                          minimumSize: const Size(48, 48),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: Text(
                                          'Daftar',
                                          style: JText.sans(
                                            14,
                                            weight: FontWeight.w400,
                                            color: Colors.white.withValues(alpha: 0.75),
                                          ),
                                        ),
                                      ),
                                    ],
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
