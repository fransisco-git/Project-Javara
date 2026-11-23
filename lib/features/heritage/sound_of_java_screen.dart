import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../services/java_music_service.dart';

/// Halaman Pemutar Lagu Jawa & Swara Budaya (Anti-AI-Slop Edition).
///
/// Dirancang dengan estetika otentik Jawa (Sogan Keraton & Kayu Jati),
/// lirik berjalan interaktif (karaoke), visualisasi gelombang suara,
/// dan sinkronisasi volume dua arah dengan tombol fisik HP.
class SoundOfJavaScreen extends StatefulWidget {
  const SoundOfJavaScreen({super.key});

  @override
  State<SoundOfJavaScreen> createState() => _SoundOfJavaScreenState();
}

class _SoundOfJavaScreenState extends State<SoundOfJavaScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _vinylController;
  final ScrollController _lyricsScrollController = ScrollController();
  final JavaMusicService _musicService = JavaMusicService.instance;

  static const List<String> _categories = [
    'Semua',
    'DJ Jawa',
    'Pop Jawa',
    'Gamelan',
    'Soundscape',
  ];

  int _selectedViewTab = 0; // 0: Pemutar Utama, 1: Lirik Berjalan (Karaoke)
  double? _dragPosition;

  String _formatSeconds(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    if (_musicService.isPlaying) {
      _vinylController.repeat();
    }

    _musicService.addListener(_handleMusicStateChange);
  }

  void _handleMusicStateChange() {
    if (!mounted) return;
    if (_musicService.isPlaying) {
      if (!_vinylController.isAnimating) {
        _vinylController.repeat();
      }
    } else {
      if (_vinylController.isAnimating) {
        _vinylController.stop();
      }
    }

    // Auto-scroll lirik berjalan bila tab lirik aktif
    if (_selectedViewTab == 1 && _lyricsScrollController.hasClients) {
      final activeIdx = _musicService.currentLyricIndex;
      if (activeIdx > 1) {
        final targetOffset = (activeIdx - 1) * 58.0;
        _lyricsScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _musicService.removeListener(_handleMusicStateChange);
    _vinylController.dispose();
    _lyricsScrollController.dispose();
    super.dispose();
  }

  void _cyclePlaybackRate() {
    HapticFeedback.selectionClick();
    final rates = [0.75, 1.0, 1.25, 1.5];
    final currentIdx = rates.indexOf(_musicService.playbackRate);
    final nextRate = rates[(currentIdx + 1) % rates.length];
    _musicService.setPlaybackRate(nextRate);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kecepatan Tempo: ${nextRate}x'),
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF26150C),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _musicService,
      builder: (context, _) {
        final current = _musicService.currentTrack;
        final filteredList = _musicService.filteredTracks;
        final currentLyricIdx = _musicService.currentLyricIndex;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFF140D08), // Warna Kayu Jati Tua Sogan
            appBar: AppBar(
              backgroundColor: const Color(0xFF140D08),
              elevation: 0,
              leading: IconButton(
                tooltip: 'Tutup Pemutar',
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFDFC084),
                  size: 28,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Column(
                children: [
                  // Indikator geser ke bawah
                  Container(
                    width: 34,
                    height: 3.5,
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A3424),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Swara Jawa',
                    style: JText.serif(
                      17,
                      weight: FontWeight.w700,
                      color: const Color(0xFFDFC084),
                    ),
                  ),
                  const Text(
                    'Koleksi Musik & Tembang Jawa',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFFA89682),
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                // Tombol Alih Tampilan (Pemutar / Lirik Berjalan)
                IconButton(
                  tooltip: _selectedViewTab == 0
                      ? 'Buka Lirik Berjalan'
                      : 'Buka Pemutar Piringan',
                  icon: Icon(
                    _selectedViewTab == 0
                        ? Icons.lyrics_rounded
                        : Icons.album_rounded,
                    color: const Color(0xFFDFC084),
                    size: 21,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedViewTab = _selectedViewTab == 0 ? 1 : 0;
                    });
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _categories.map((cat) {
                          final isSel = _musicService.selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (cat == 'DJ Jawa')
                                    const Padding(
                                      padding: EdgeInsets.only(right: 4),
                                      child: Icon(
                                        Icons.bolt_rounded,
                                        size: 13,
                                        color: Color(0xFFDFB76C),
                                      ),
                                    ),
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isSel
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSel
                                          ? const Color(0xFF140D08)
                                          : const Color(0xFFDFC084),
                                    ),
                                  ),
                                ],
                              ),
                              selected: isSel,
                              onSelected: (_) {
                                HapticFeedback.selectionClick();
                                _musicService.setCategory(cat);
                              },
                              backgroundColor: const Color(0xFF22160F),
                              selectedColor: const Color(0xFFDFC084),
                              checkmarkColor: const Color(0xFF140D08),
                              showCheckmark: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isSel
                                      ? const Color(0xFFDFC084)
                                      : const Color(0xFF382419),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F130B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF8A5D2E).withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x38000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header Kategori & Sinkronisasi Volume HP
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F1D11),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFF4A301D),
                                  ),
                                ),
                                child: Text(
                                  '${current.category.toUpperCase()} · ${current.tempoBpm}',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFDFC084),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              // Indikator Sinkron Volume HP
                              Row(
                                children: [
                                  const Icon(
                                    Icons.volume_up_rounded,
                                    size: 13,
                                    color: Color(0xFFDFC084),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Volume HP: ${(_musicService.volume * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFC4B29E),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Beralih Antara Piringan Hitam & Lirik Berjalan
                          if (_selectedViewTab == 0) ...[
                            // Tampilan A: Piringan Hitam Keraton Megah (Alur Vinyl & Jarum Gramofon)
                            _RoyalJavaneseVinylPlayer(
                              turns: _vinylController,
                              isPlaying: _musicService.isPlaying,
                              icon: current.icon,
                            ),
                          ] else ...[
                            // Tampilan B: Lirik Berjalan (Karaoke Real-Time)
                            Container(
                              height: 175,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF160D07),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF382315),
                                ),
                              ),
                              child: ListView.builder(
                                controller: _lyricsScrollController,
                                itemCount: current.lyrics.length,
                                itemBuilder: (context, idx) {
                                  final line = current.lyrics[idx];
                                  final isLineActive = idx == currentLyricIdx;

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      _musicService.seek(Duration(seconds: line.second));
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 3,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isLineActive ? 12 : 8,
                                        vertical: isLineActive ? 6 : 4,
                                      ),
                                    decoration: BoxDecoration(
                                      color: isLineActive
                                          ? const Color(0xFF352013)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: isLineActive
                                          ? Border.all(
                                              color: const Color(0x66DFC084),
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      line.text,
                                      style: TextStyle(
                                        fontSize: isLineActive ? 14 : 12,
                                        fontWeight: isLineActive
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: isLineActive
                                            ? const Color(0xFFFFDF9E)
                                            : const Color(0xFF8A7768),
                                        height: 1.35,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Judul Lagu & Artis
                          Text(
                            current.title,
                            style: JText.serif(
                              18.5,
                              weight: FontWeight.w700,
                              color: const Color(0xFFF7F2EA),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            current.artist,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDFC084),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            current.origin,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF8C7B6C),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 14),

                          // Visualisasi Gelombang Audio
                          SizedBox(
                            height: 32,
                            child: _CraftedAudioWave(
                              isPlaying: _musicService.isPlaying,
                              isDj: current.category == 'DJ Jawa',
                            ),
                          ),

                          const SizedBox(height: 8),

                          // SCRUBBABLE POSITION SLIDER (SMOOTH & ANTI-JITTER)
                          Builder(
                            builder: (context) {
                              final double maxSec = math.max(
                                1.0,
                                _musicService.duration.inSeconds.toDouble(),
                              );
                              final double currentPosSec = _dragPosition ??
                                  _musicService.position.inSeconds.toDouble();
                              final double clampedValue =
                                  currentPosSec.clamp(0.0, maxSec);
                              final String currentPosFormatted =
                                  _dragPosition != null
                                      ? _formatSeconds(_dragPosition!.toInt())
                                      : _musicService.positionFormatted;

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: const Color(0xFFDFC084),
                                      inactiveTrackColor:
                                          const Color(0xFF382419),
                                      thumbColor: const Color(0xFFDFC084),
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6.0,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                        overlayRadius: 12,
                                      ),
                                      trackHeight: 3.0,
                                    ),
                                    child: Slider(
                                      value: clampedValue,
                                      min: 0.0,
                                      max: maxSec,
                                      onChangeStart: (val) {
                                        setState(() {
                                          _dragPosition = val;
                                        });
                                      },
                                      onChanged: (val) {
                                        setState(() {
                                          _dragPosition = val;
                                        });
                                      },
                                      onChangeEnd: (val) {
                                        _musicService.seek(
                                          Duration(seconds: val.toInt()),
                                        );
                                        setState(() {
                                          _dragPosition = null;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          currentPosFormatted,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFA89682),
                                          ),
                                        ),
                                        Text(
                                          _musicService.durationFormatted,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFA89682),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          // TOMBOL KONTROL UTAMA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Shuffle
                              IconButton(
                                icon: Icon(
                                  Icons.shuffle_rounded,
                                  size: 20,
                                  color: _musicService.isShuffle
                                      ? const Color(0xFFDFC084)
                                      : const Color(0xFF5E4B3E),
                                ),
                                tooltip: 'Acak',
                                onPressed: _musicService.toggleShuffle,
                              ),

                              const SizedBox(width: 8),

                              // Previous
                              IconButton(
                                icon: const Icon(
                                  Icons.skip_previous_rounded,
                                  size: 30,
                                  color: Color(0xFFDFC084),
                                ),
                                tooltip: 'Sebelumnya',
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  _musicService.previous();
                                },
                              ),

                              const SizedBox(width: 12),

                              // Play / Pause Utama (Kontras & Ramah Jari >= 48px)
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _musicService.togglePlay();
                                },
                                child: Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFDFC084),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _musicService.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 34,
                                    color: const Color(0xFF140D08),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Next
                              IconButton(
                                icon: const Icon(
                                  Icons.skip_next_rounded,
                                  size: 30,
                                  color: Color(0xFFDFC084),
                                ),
                                tooltip: 'Selanjutnya',
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  _musicService.next();
                                },
                              ),

                              const SizedBox(width: 8),

                              // Repeat
                              IconButton(
                                icon: Icon(
                                  Icons.repeat_rounded,
                                  size: 20,
                                  color: _musicService.isRepeat
                                      ? const Color(0xFFDFC084)
                                      : const Color(0xFF5E4B3E),
                                ),
                                tooltip: 'Ulangi',
                                onPressed: _musicService.toggleRepeat,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // SINKRONISASI VOLUME PERANGKAT KERAS (HARDWARE VOLUME SYNC)
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (_musicService.volume > 0) {
                                    _musicService.setVolume(0.0);
                                  } else {
                                    _musicService.setVolume(0.8);
                                  }
                                },
                                child: Icon(
                                  _musicService.volume == 0
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_down_rounded,
                                  size: 17,
                                  color: const Color(0xFFA89682),
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: const Color(0xFF8A5D2E),
                                    inactiveTrackColor:
                                        const Color(0xFF382419),
                                    thumbColor: const Color(0xFFDFC084),
                                    thumbShape:
                                        const RoundSliderThumbShape(
                                      enabledThumbRadius: 4.0,
                                    ),
                                    trackHeight: 2,
                                  ),
                                  child: Slider(
                                    value: _musicService.volume,
                                    onChanged: (val) =>
                                        _musicService.setVolume(val),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.volume_up_rounded,
                                size: 17,
                                color: Color(0xFFDFC084),
                              ),
                              const SizedBox(width: 8),
                              // Speed Rate Pill
                              InkWell(
                                onTap: _cyclePlaybackRate,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2B190F),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFF4A301D),
                                    ),
                                  ),
                                  child: Text(
                                    '${_musicService.playbackRate}x',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFDFC084),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.queue_music_rounded,
                            size: 18,
                            color: Color(0xFFDFC084),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Koleksi Lagu Jawa (${filteredList.length})',
                            style: JText.serif(
                              15,
                              weight: FontWeight.w700,
                              color: const Color(0xFFDFC084),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _musicService.selectedCategory,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFA89682),
                            ),
                          ),
                        ],
                      ),
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredList.length,
                      itemBuilder: (context, idx) {
                        final track = filteredList[idx];
                        final isCurrent = current.id == track.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0xFF26170E)
                                : const Color(0xFF19100A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCurrent
                                  ? const Color(0xFFDFC084)
                                  : const Color(0xFF2E1C12),
                              width: isCurrent ? 1.0 : 0.6,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 1,
                            ),
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCurrent
                                    ? const Color(0xFFDFC084)
                                    : const Color(0xFF26170E),
                              ),
                              child: isCurrent && _musicService.isPlaying
                                  ? const Icon(
                                      Icons.graphic_eq_rounded,
                                      color: Color(0xFF140D08),
                                      size: 19,
                                    )
                                  : Icon(
                                      track.icon,
                                      color: isCurrent
                                          ? const Color(0xFF140D08)
                                          : const Color(0xFFDFC084),
                                      size: 18,
                                    ),
                            ),
                            title: Text(
                              track.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isCurrent
                                    ? const Color(0xFFDFC084)
                                    : const Color(0xFFF7F2EA),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${track.category} · ${track.artist}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFFA89682),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  track.duration,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: isCurrent
                                        ? const Color(0xFFDFC084)
                                        : const Color(0xFF756151),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isCurrent && _musicService.isPlaying
                                      ? Icons.pause_circle_filled_rounded
                                      : Icons.play_circle_fill_rounded,
                                  color: isCurrent
                                      ? const Color(0xFFDFC084)
                                      : const Color(0xFF5E4B3E),
                                  size: 26,
                                ),
                              ],
                            ),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (isCurrent) {
                                _musicService.togglePlay();
                              } else {
                                _musicService.playTrack(track);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Visualisasi Gelombang Audio Tanpa AI-Slop (Elegan & Bertujuan)
class _CraftedAudioWave extends StatefulWidget {
  const _CraftedAudioWave({
    required this.isPlaying,
    required this.isDj,
  });

  final bool isPlaying;
  final bool isDj;

  @override
  State<_CraftedAudioWave> createState() => _CraftedAudioWaveState();
}

class _CraftedAudioWaveState extends State<_CraftedAudioWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isDj ? 700 : 1300),
    );
    if (widget.isPlaying) _anim.repeat();
  }

  @override
  void didUpdateWidget(covariant _CraftedAudioWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying) {
      if (!_anim.isAnimating) _anim.repeat();
    } else {
      _anim.stop();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(double.infinity, 32),
          painter: _CraftedWavePainter(
            progress: _anim.value,
            isPlaying: widget.isPlaying,
            isDj: widget.isDj,
          ),
        );
      },
    );
  }
}

class _CraftedWavePainter extends CustomPainter {
  _CraftedWavePainter({
    required this.progress,
    required this.isPlaying,
    required this.isDj,
  });

  final double progress;
  final bool isPlaying;
  final bool isDj;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.6;

    const barCount = 26;
    final spacing = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      final x = (i * spacing) + (spacing / 2);
      final phase = (i * (isDj ? 0.55 : 0.35)) + (progress * 2 * math.pi);
      final factor = isPlaying
          ? (math.sin(phase).abs() * (isDj ? 0.8 : 0.6) + 0.15)
          : 0.15;

      final barH = size.height * factor;
      final yTop = (size.height - barH) / 2;
      final yBottom = yTop + barH;

      paint.color = isPlaying
          ? Color.lerp(
              const Color(0xFF8A5D2E),
              const Color(0xFFDFC084),
              factor,
            )!
          : const Color(0xFF382419);

      canvas.drawLine(Offset(x, yTop), Offset(x, yBottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CraftedWavePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.isPlaying != isPlaying ||
      oldDelegate.isDj != isDj;
}

/// Piringan Hitam Klasik Keraton Jawa (High-End Royal Vinyl Turntable)
class _RoyalJavaneseVinylPlayer extends StatelessWidget {
  const _RoyalJavaneseVinylPlayer({
    required this.turns,
    required this.isPlaying,
    required this.icon,
  });

  final Animation<double> turns;
  final bool isPlaying;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 170,
        height: 170,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Aura Emas Denyut saat Memutar
            if (isPlaying)
              Container(
                width: 162,
                height: 162,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDFC084).withValues(alpha: 0.15),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

            // 2. Piringan Hitam Berputar dengan Alur Vinyl Realistis
            RotationTransition(
              turns: turns,
              child: CustomPaint(
                size: const Size(155, 155),
                painter: _VinylRecordPainter(),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFF8A5D2E),
                          Color(0xFF3D2312),
                          Color(0xFF1F1208),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFDFC084),
                        width: 2.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ornamen Surya Majapahit Emas
                          Transform.rotate(
                            angle: math.pi / 4,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0x55DFC084),
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            icon,
                            size: 24,
                            color: const Color(0xFFDFC084),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Jarum Gramofon Klasik (Tonearm)
            Positioned(
              top: 2,
              right: 6,
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                turns: isPlaying ? 0.04 : -0.06,
                alignment: Alignment.topRight,
                child: CustomPaint(
                  size: const Size(36, 64),
                  painter: _TonearmPainter(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VinylRecordPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Body piringan hitam
    final bodyPaint = Paint()
      ..color = const Color(0xFF100C09)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bodyPaint);

    // Alur Vinyl Konsentris (Micro-grooves)
    final groovePaint = Paint()
      ..color = const Color(0x22DFC084)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (double r = radius * 0.44; r < radius - 3; r += 4.5) {
      canvas.drawCircle(center, r, groovePaint);
    }

    // Pinggiran Emas Halus
    final rimPaint = Paint()
      ..color = const Color(0x88DFC084)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 1, rimPaint);

    // Kilau Anisotropik Refleksi Cahaya Piringan Hitam
    final sheenPaint = Paint()
      ..shader = SweepGradient(
        colors: const [
          Colors.transparent,
          Color(0x28DFC084),
          Colors.transparent,
          Color(0x28DFC084),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 2, sheenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TonearmPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = const Color(0xFFC89B3C)
      ..style = PaintingStyle.fill;
    // Pivot base
    canvas.drawCircle(Offset(size.width - 6, 6), 5.5, basePaint);

    final armPaint = Paint()
      ..color = const Color(0xFFDFC084)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width - 6, 6)
      ..lineTo(size.width - 12, 38)
      ..lineTo(8, size.height - 4);
    canvas.drawPath(path, armPaint);

    // Cartridge / headshell
    final headPaint = Paint()
      ..color = const Color(0xFF8A5D2E)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(7, size.height - 4), width: 9, height: 6),
      headPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
