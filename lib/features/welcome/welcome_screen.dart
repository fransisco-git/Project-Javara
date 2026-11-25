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

/// Konstanta path aset latar foto pasangan berbusana adat Jawa di Pendopo.
const String kWelcomeHeroAsset = 'assets/images/welcome_pendopo_busana.jpg';

/// Warna aksen emas hangat dan gelap khas layar selamat datang JAVARA.
const Color _kCtaGold = Color(0xFFDFB76C);
const Color _kDarkBrown = Color(0xFF140C06);
const Color _kDarkBrownBg = Color(0xFF0B0704);
const Color _kScrimDarkBrown = Color(0xFF0E0905);

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
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  late final Animation<double> _headlineAnim;
  late final Animation<double> _subtitleAnim;
  late final Animation<double> _primaryCtaAnim;
  late final Animation<double> _secondaryCtaAnim;

  AudioPlayer? _ambientPlayer;

  @override
  void initState() {
    super.initState();

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
    } catch (_) {
      // Graceful fallback jika audio service sedang tidak aktif atau di mode test
    }
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
    // Pra-muat foto latar welcome screen
    precacheImage(
      const AssetImage(kWelcomeHeroAsset),
      context,
    );
  }

  @override
  void dispose() {
    _stopAmbientFoley();
    _entranceController.dispose();
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
        backgroundColor: const Color(0xFF080503),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Foto Latar Pasangan Berbusana Adat Jawa di Pendopo (HD, tanpa zoom)
            Positioned.fill(
              child: Image.asset(
                kWelcomeHeroAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),

            // 2. Scrim gradasi gelap halus di bagian bawah untuk keterbacaan tipografi & CTA
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.50, 0.72, 0.88, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        _kScrimDarkBrown.withValues(alpha: 0.72),
                        _kDarkBrownBg.withValues(alpha: 0.94),
                        const Color(0xFF080503),
                      ],
                    ),
                  ),
                ),
              ),
            ),

                  // 6. Blok Konten Bawah: Headline, Subtitle, Tombol Utama & Masuk/Daftar
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

                              // 1. Headline (Font Serif, 34sp atau 28sp jika h < 700, line height 1.15, putih penuh)
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

                              // 2. Subtitle (14.5sp, w400, putih opacity 0.80, line height 1.5, maks 3 baris)
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
                                      14.5,
                                      weight: FontWeight.w400,
                                      color: Colors.white.withValues(alpha: 0.80),
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

                              // 3. Tombol Utama: "Mulai Eksplorasi Budaya →" (Solid emas hangat, teks cokelat gelap w600, tinggi 54, radius 12)
                              _buildStaggeredItem(
                                animation: _primaryCtaAnim,
                                disableAnimations: disableAnimations,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 54,
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
                                              letterSpacing: 0.2,
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

                              SizedBox(height: h < 700 ? 6 : 10),

                              // 4. Baris Masuk · Daftar (tap >= 48x48dp)
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
                                          tapTargetSize: MaterialTapTargetSize.padded,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
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
                                      ExcludeSemantics(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 2),
                                          child: Text(
                                            '·',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.50),
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
                                          tapTargetSize: MaterialTapTargetSize.padded,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: Text(
                                          'Daftar',
                                          style: JText.sans(
                                            14,
                                            weight: FontWeight.w400,
                                            color: Colors.white.withValues(alpha: 0.72),
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
      ),
    );
  }
}
