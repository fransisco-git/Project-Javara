import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../explore/quiz_screen.dart';
import '../heritage/aksara_jawa_screen.dart';
import '../heritage/culture_passport_screen.dart';
import '../heritage/sound_of_java_screen.dart';
import '../heritage/time_travel_screen.dart';
import '../fashion/screens/batik_motif_gallery_screen.dart';
import '../fashion/screens/javanese_fashion_map_screen.dart';
import '../fashion/screens/sinau_busana_screen.dart';

/// Tab Profil JAVARA - Pengalaman Profil Budaya Lengkap Sesuai Master Prompt JAVARA.
/// Memuat data diri pengguna, statistik eksplorasi 35 wilayah Jawa Tengah,
/// koleksi lencana kehormatan budaya, riwayat kuis, preferensi aksara Jawa, dan pengaturan.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, this.onOpenTab});

  final ValueChanged<int>? onOpenTab;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _showJavaneseScript = true;
  bool _ambientGamelan = true;
  bool _dailyHeritageNotice = true;

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1528),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0x66DFB76C), width: 1.0),
        ),
        title: Text(
          'Keluar dari JAVARA?',
          style: JText.serif(
            18,
            weight: FontWeight.w700,
            color: const Color(0xFFFFDF9E),
          ),
        ),
        content: Text(
          'Seluruh progres lencana budaya dan riwayat kuis tetap aman tersimpan di akunmu.',
          style: JText.serif(13.5, color: const Color(0xFFD6C8B8), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Batal',
              style: JText.serif(13, color: const Color(0xFFB5A493)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB5603A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Ya, Keluar',
              style: JText.serif(
                13,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await AuthService.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context)
        .pushAndRemoveUntil(fadeSlideRoute(const LoginScreen()), (_) => false);
  }

  void _showSnack(String msg) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: JText.serif(13, color: Colors.white)),
        backgroundColor: const Color(0xFF2E2019),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openJavaneseDictionary(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1528),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0xFFDFB76C), width: 1.2),
              left: BorderSide(color: Color(0x55DFB76C), width: 0.8),
              right: BorderSide(color: Color(0x55DFB76C), width: 0.8),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x66DFB76C),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kamus Istilah Pepak Jawa',
                          style: JText.serif(
                            20,
                            weight: FontWeight.w700,
                            color: const Color(0xFFFFDF9E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'ꦏꦩꦸꦱ꧀ꦥꦼꦥꦏ꧀ꦗꦮ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFDFB76C),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFFFDF9E),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0x33DFB76C), height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: const [
                    _DictionaryCard(
                      term: 'Adiluhung',
                      script: 'ꦲꦢꦶꦭꦸꦲꦸꦁ',
                      meaning: 'Nilai seni dan budaya yang bermutu tinggi, mulia, luhur, serta patut dilestarikan turun-temurun.',
                    ),
                    _DictionaryCard(
                      term: 'Beskap',
                      script: 'ꦧꦼꦱ꧀ꦏꦥ꧀',
                      meaning: 'Jas tradisional pria Jawa berkerah tegak tanpa lipatan dengan kancing asimetris dan lengkungan belakang untuk keris.',
                    ),
                    _DictionaryCard(
                      term: 'Jarik',
                      script: 'ꦗꦫꦶꦏ꧀',
                      meaning: 'Kain batik panjang yang dililitkan rapi di pinggang hingga mata kaki, mencerminkan ketelitian dan kesopanan budi pekerti.',
                    ),
                    _DictionaryCard(
                      term: 'Blangkon',
                      script: 'ꦧ꧀ꦭꦁꦏꦺꦴꦤ꧀',
                      meaning: 'Penutup kepala pria Jawa dari kain batik berpola, melambangkan pengendalian pikiran dan ketenangan batin.',
                    ),
                    _DictionaryCard(
                      term: 'Pamor',
                      script: 'ꦥꦩꦺꦴꦂ',
                      meaning: 'Pola atau berkas guratan logam meteorit dan nikel yang ditempa bersusun pada bilah tosan aji keris.',
                    ),
                    _DictionaryCard(
                      term: 'Canting',
                      script: 'ꦕꦤ꧀ꦛꦶꦁ',
                      meaning: 'Alat tembaga kecil bercorong halus untuk menorehkan cairan lilin/malam panas saat membatik tulis.',
                    ),
                    _DictionaryCard(
                      term: 'Sembah',
                      script: 'ꦱꦼꦩ꧀ꦧꦃ',
                      meaning: 'Sikap merapatkan kedua telapak tangan di depan dada atau hidung sebagai wujud rasa hormat dan tawadhu.',
                    ),
                    _DictionaryCard(
                      term: 'Gamelan',
                      script: 'ꦒꦩꦼꦭꦤ꧀',
                      meaning: 'Ansambel musik tradisional Jawa berlaras Pelog dan Slendro yang mencerminkan keselarasan batin.',
                    ),
                    _DictionaryCard(
                      term: 'Kuncoro',
                      script: 'ꦏꦸꦚ꧀ꦕꦫ',
                      meaning: 'Masyhur, tersohor, atau harum namanya di tengah masyarakat karena keluhuran budi pekerti.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeDialog(
    BuildContext context,
    String title,
    String icon,
    String desc,
    bool unlocked,
  ) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1528),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x66DFB76C), width: 1.0),
        ),
        title: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: JText.serif(
                  18,
                  weight: FontWeight.w700,
                  color: const Color(0xFFFFDF9E),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: unlocked
                    ? const Color(0x336A7B5B)
                    : const Color(0x33DFB76C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                unlocked ? 'STATUS: TERBUKA' : 'STATUS: TERKUNCI',
                style: JText.serif(
                  10,
                  weight: FontWeight.w700,
                  color: unlocked
                      ? const Color(0xFFA8D5A2)
                      : const Color(0xFFFFDF9E),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              style: JText.serif(
                13.5,
                color: const Color(0xFFD6C8B8),
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC79835),
              foregroundColor: const Color(0xFF1A1208),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Tutup',
              style: JText.serif(13, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _openAboutModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFF9F5EE),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFCCB2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: JColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: JColors.button,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JAVARA — Warisane Jowo',
                        style: JText.serif(
                          18,
                          weight: FontWeight.w800,
                          color: JColors.ink,
                        ),
                      ),
                      Text(
                        'Edisi Mahakarya v1.2.0 • Jawa Tengah',
                        style: JText.serif(12, color: JColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'JAVARA adalah platform digital interaktif yang didedikasikan untuk merawat, melestarikan, dan mempopulerkan khasanah budaya adiluhung Jawa Tengah: arsitektur candi 3D, 35 paspor wilayah, gamelan Jawa, dan kearifan lokal.',
              style: JText.serif(
                13.5,
                color: const Color(0xFF4A382A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: JColors.button,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Tutup',
                  style: JText.serif(
                    14,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: FutureBuilder<AuthUser?>(
          future: AuthService.instance.currentUser(),
          builder: (context, snap) {
            final name = snap.data?.name ?? 'Penjelajah Budaya';
            final email = snap.data?.email ?? 'tamu@javara.id';
            final initial = name.isEmpty
                ? 'J'
                : name.substring(0, 1).toUpperCase();

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              children: [
                // =============================================================
                // 1. HEADER PROFILE DENGAN AKSARA JAWA & EMBLEM
                // =============================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil Pewaris',
                          style: JText.serif(
                            28,
                            weight: FontWeight.w800,
                            color: JColors.ink,
                          ),
                        ),
                        if (_showJavaneseScript)
                          const Text(
                            'ꦥꦿꦺꦴꦥ꦳ꦶꦭ꧀ꦥꦼꦮꦫꦶꦱ꧀ꦧꦸꦢꦪ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9E7E50),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: JColors.ink,
                      ),
                      onPressed: () =>
                          _showSnack('Pengaturan akun disinkronkan otomatis.'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =============================================================
                // 2. KARTU IDENTITAS PEWARIS BUDAYA
                // =============================================================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C1D17), Color(0xFF191011)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0x66DFB76C),
                      width: 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x24000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar Lingkaran dengan Mahkota Emas
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFDFB76C), Color(0xFF8C5D17)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x24000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              initial,
                              style: JText.serif(
                                30,
                                weight: FontWeight.w800,
                                color: const Color(0xFF191011),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD700),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                size: 14,
                                color: Color(0xFF2C1D17),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 18),

                      // Nama & Tingkat Kebudayaan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: JText.serif(
                                19,
                                weight: FontWeight.w700,
                                color: const Color(0xFFFFDF9E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: JText.serif(
                                12,
                                color: const Color(0xFFB5A493),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x33DFB76C),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0x55DFB76C),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.military_tech_rounded,
                                    size: 13,
                                    color: Color(0xFFFFD700),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Pewaris Luhur · Tingkat III',
                                    style: JText.serif(
                                      10.5,
                                      weight: FontWeight.w700,
                                      color: const Color(0xFFFFDF9E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // =============================================================
                // 3. STATISTIK PENGEMBARAAN BUDAYA (GRID 4 ELEMEN)
                // =============================================================
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: '1.850',
                        label: 'Skor Budaya',
                        icon: Icons.auto_awesome,
                        color: const Color(0xFFFFD700),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showSnack(
                            'Tingkat III: Pewaris Luhur. Capai 2.500 poin untuk gelar Mahapatih Budaya!',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        value: '18 / 35',
                        label: 'Wilayah Dijelajahi',
                        icon: Icons.map_rounded,
                        color: const Color(0xFFE4BC6C),
                        onTap: () => Navigator.of(
                          context,
                        ).push(fadeSlideRoute(const CulturePassportScreen())),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: '12 Kuis',
                        label: 'Tantangan Tuntas',
                        icon: Icons.school_rounded,
                        color: const Color(0xFF6A7B5B),
                        onTap: () =>
                            Navigator.of(context)
                                .push(fadeSlideRoute(const QuizScreen())),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        value: '14 Warisan',
                        label: 'Koleksi Tersimpan',
                        icon: Icons.bookmark_added_rounded,
                        color: const Color(0xFFB5603A),
                        onTap: () =>
                            widget.onOpenTab?.call(3), // Buka Tab Favorit
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // =============================================================
                // 4. LENCANA KEHORMATAN BUDAYA (ACHIEVEMENTS)
                // =============================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lencana Kehormatan',
                      style: JText.serif(
                        18,
                        weight: FontWeight.w700,
                        color: JColors.ink,
                      ),
                    ),
                    Text(
                      '4 dari 6 Terbuka',
                      style: JText.serif(
                        12,
                        color: JColors.muted,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _BadgeCard(
                        icon: '🏛️',
                        title: 'Penjelajah Candi',
                        level: 'Tingkat Emas',
                        unlocked: true,
                        onTap: () => _showBadgeDialog(
                          context,
                          'Penjelajah Candi (Tingkat Emas)',
                          '🏛️',
                          'Diberikan kepada penjelajah yang telah mengunjungi dan mempelajari relief Candi Borobudur, Prambanan, Mendut, dan Sukuh.',
                          true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _BadgeCard(
                        icon: '👘',
                        title: 'Pewaris Batik',
                        level: 'Tingkat Emas',
                        unlocked: true,
                        onTap: () => _showBadgeDialog(
                          context,
                          'Pewaris Batik (Tingkat Emas)',
                          '👘',
                          'Telah menguasai filosofi motif Parang, Kawung, Truntum, dan Sido Asih dari Keraton Surakarta Hadiningrat.',
                          true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _BadgeCard(
                        icon: '⚔️',
                        title: 'Pamor Tosan Aji',
                        level: 'Tingkat Perak',
                        unlocked: true,
                        onTap: () => _showBadgeDialog(
                          context,
                          'Pamor Tosan Aji (Tingkat Perak)',
                          '⚔️',
                          'Mengenali 5 pamor keris pusaka Jawa Tengah dan nilai luhur filosofi kepemimpinan ksatria.',
                          true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _BadgeCard(
                        icon: '👘',
                        title: 'Pusaka Busana Jawa',
                        level: 'Tingkat Perak',
                        unlocked: true,
                        onTap: () => _showBadgeDialog(
                          context,
                          'Pusaka Busana Jawa (Tingkat Perak)',
                          '👘',
                          'Mengenal dan menjelajahi kelengkapan busana adat Jawi Jangkep, Kebaya, Beskap, dan Surjan Jawa Tengah.',
                          true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _BadgeCard(
                        icon: '🎵',
                        title: 'Laras Slendro',
                        level: 'Terkunci',
                        unlocked: false,
                        onTap: () => _showBadgeDialog(
                          context,
                          'Laras Slendro (Terkunci)',
                          '🎵',
                          'Buka lencana ini dengan mendengarkan 4 tembang adiluhung di museum audio Swara Jawa.',
                          false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _BadgeCard(
                        icon: '📜',
                        title: 'Pujangga Kawi',
                        level: 'Terkunci',
                        unlocked: false,
                        onTap: () => _showBadgeDialog(
                          context,
                          'Pujangga Kawi (Terkunci)',
                          '📜',
                          'Selesaikan 5 tantangan kuis budaya Jawa Tengah dengan skor sempurna untuk membuka gelar Pujangga.',
                          false,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // =============================================================
                // 5. PREFERENSI & PERSONALISASI BUDAYA
                // =============================================================
                Text(
                  'Preferensi Pelestarian Budaya',
                  style: JText.serif(
                    18,
                    weight: FontWeight.w700,
                    color: JColors.ink,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEADBCA)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _showJavaneseScript,
                        activeThumbColor: JColors.gold,
                        title: Text(
                          'Tampilkan Aksara Jawa (ꦲꦤꦕꦫꦏ)',
                          style: JText.serif(
                            14,
                            weight: FontWeight.w600,
                            color: JColors.ink,
                          ),
                        ),
                        subtitle: Text(
                          'Menghadirkan penulisan tradisional pada judul dan lencana budaya.',
                          style: JText.serif(12, color: JColors.muted),
                        ),
                        onChanged: (v) {
                          setState(() => _showJavaneseScript = v);
                          _showSnack(
                            v
                                ? 'Aksara Jawa diaktifkan.'
                                : 'Aksara Jawa dinonaktifkan.',
                          );
                        },
                      ),
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFEADBCA),
                      ),
                      SwitchListTile(
                        value: _ambientGamelan,
                        activeThumbColor: JColors.gold,
                        title: Text(
                          'Musik Tradisional Pengiring (Gamelan)',
                          style: JText.serif(
                            14,
                            weight: FontWeight.w600,
                            color: JColors.ink,
                          ),
                        ),
                        subtitle: Text(
                          'Instrumen lembut saat menelusuri artikel dan galeri 3D.',
                          style: JText.serif(12, color: JColors.muted),
                        ),
                        onChanged: (v) {
                          setState(() => _ambientGamelan = v);
                          _showSnack(
                            v
                                ? 'Audio gamelan diaktifkan.'
                                : 'Audio gamelan dinonaktifkan.',
                          );
                        },
                      ),
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFEADBCA),
                      ),
                      SwitchListTile(
                        value: _dailyHeritageNotice,
                        activeThumbColor: JColors.gold,
                        title: Text(
                          'Kabar Warisan Harian',
                          style: JText.serif(
                            14,
                            weight: FontWeight.w600,
                            color: JColors.ink,
                          ),
                        ),
                        subtitle: Text(
                          'Pesan singkat kearifan lokal setiap pukul 08.00 pagi.',
                          style: JText.serif(12, color: JColors.muted),
                        ),
                        onChanged: (v) {
                          setState(() => _dailyHeritageNotice = v);
                          _showSnack(
                            v
                                ? 'Notifikasi harian aktif.'
                                : 'Notifikasi harian nonaktif.',
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =============================================================
                // 6. MENU PUSAT INFORMASI & TENTANG JAVARA
                // =============================================================
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEADBCA)),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.edit_note_rounded,
                          color: JColors.terracotta,
                        ),
                        title: Text(
                          'Sanggar Aksara Jawa (ꦲꦤꦕꦫꦏ)',
                          style: JText.serif(14, weight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '20 Aksara Hanacaraka & Penerjemah Otomatis',
                          style: JText.serif(12, color: JColors.muted),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: JColors.muted,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context)
                              .push(fadeSlideRoute(const AksaraJawaScreen()));
                        },
                      ),
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFEADBCA),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.graphic_eq_rounded,
                          color: JColors.gold,
                        ),
                        title: Text(
                          'Pemutar Lagu Jawa (Swara Jawa)',
                          style: JText.serif(14, weight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'DJ Negoro Angin, Rungkad, Pop Jawa & Gamelan',
                          style: JText.serif(12, color: JColors.muted),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: JColors.muted,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context)
                              .push(musicPlayerRoute(const SoundOfJavaScreen()));
                        },
                      ),
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFEADBCA),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.history_edu_rounded,
                          color: JColors.button,
                        ),
                        title: Text(
                          'Penjelajah Waktu Sejarah Jawa',
                          style: JText.serif(14, weight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Linimasa 6 Era Kejayaan Peradaban Jawa Tengah',
                          style: JText.serif(12, color: JColors.muted),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: JColors.muted,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context)
                              .push(fadeSlideRoute(const TimeTravelScreen()));
                        },
                      ),
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFEADBCA),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.menu_book_rounded,
                          color: JColors.ink,
                        ),
                        title: Text(
                          'Kamus Istilah Pepak Jawa',
                          style: JText.serif(14, weight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '8 istilah filosofis & bahasa adiluhung',
                          style: JText.serif(12, color: JColors.muted),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: JColors.muted,
                        ),
                        onTap: () => _openJavaneseDictionary(context),
                      ),
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFEADBCA),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.palette_outlined,
                          color: JColors.ink,
                        ),
                        title: Text(
                          'Galeri Wastra & Motif Batik',
                          style: JText.serif(14, weight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Eksplorasi wastra klasik, filosofi & kanvas motif',
                          style: JText.serif(12, color: JColors.muted),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: JColors.muted,
                        ),
                        onTap: () => Navigator.of(context).push(
                          fadeSlideRoute(const BatikMotifGalleryScreen()),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFEADBCA),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.map_outlined,
                          color: JColors.ink,
                        ),
                        title: Text(
                          'Peta Persebaran Busana Daerah',
                          style: JText.serif(14, weight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '7 pusat tradisi busana Jawa Tengah',
                          style: JText.serif(12, color: JColors.muted),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: JColors.muted,
                        ),
                        onTap: () => Navigator.of(context).push(
                          fadeSlideRoute(const JavaneseFashionMapScreen()),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFEADBCA),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.school_outlined,
                          color: JColors.ink,
                        ),
                        title: Text(
                          'Sinau Busana & Tantangan Kuis',
                          style: JText.serif(14, weight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Uji pemahaman busana adat & filosofi',
                          style: JText.serif(12, color: JColors.muted),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: JColors.muted,
                        ),
                        onTap: () => Navigator.of(context).push(
                          fadeSlideRoute(const SinauBusanaScreen()),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFEADBCA),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline_rounded,
                          color: JColors.ink,
                        ),
                        title: Text(
                          'Tentang Kurasi JAVARA',
                          style: JText.serif(14, weight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Pelestarian digital khasanah Jawa Tengah v1.2',
                          style: JText.serif(12, color: JColors.muted),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: JColors.muted,
                        ),
                        onTap: () => _openAboutModal(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // =============================================================
                // 7. TOMBOL KELUAR AKUN
                // =============================================================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFB5603A),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _logout(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFB5603A),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Keluar dari Akun',
                          style: JText.serif(
                            14,
                            weight: FontWeight.w700,
                            color: const Color(0xFFB5603A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: Text(
                    'JAVARA · Warisane Jowo © 2026',
                    style: JText.serif(11.5, color: JColors.muted),
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

/// Kartu Ringkasan Metrik Angka
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEADBCA)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: JText.serif(
                        15,
                        weight: FontWeight.w800,
                        color: JColors.ink,
                      ),
                    ),
                    Text(
                      label,
                      style: JText.serif(11, color: JColors.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: JColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu Lencana Budaya (Badge)
class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.icon,
    required this.title,
    required this.level,
    required this.unlocked,
    this.onTap,
  });

  final String icon;
  final String title;
  final String level;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: unlocked ? const Color(0xFFFFFBF4) : const Color(0xFFEDE5DA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: unlocked
                  ? const Color(0xFFDFB76C)
                  : const Color(0xFFD4C8B8),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                icon,
                style: TextStyle(
                  fontSize: 28,
                  color: unlocked ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: JText.serif(
                  11,
                  weight: FontWeight.w700,
                  color: unlocked ? JColors.ink : Colors.black45,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                level,
                style: JText.serif(
                  9.5,
                  weight: FontWeight.w600,
                  color: unlocked ? const Color(0xFFB5603A) : Colors.black38,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu Entri Kamus Pepak Jawa
class _DictionaryCard extends StatelessWidget {
  const _DictionaryCard({
    required this.term,
    required this.script,
    required this.meaning,
  });

  final String term;
  final String script;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF261B30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x44DFB76C), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                term,
                style: JText.serif(
                  16,
                  weight: FontWeight.w700,
                  color: const Color(0xFFFFDF9E),
                ),
              ),
              Text(
                script,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFDFB76C),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            meaning,
            style: JText.serif(13, color: const Color(0xFFD6C8B8), height: 1.4),
          ),
        ],
      ),
    );
  }
}
