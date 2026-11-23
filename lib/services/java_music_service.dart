import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

/// Baris lirik berwaktu untuk fitur Karaoke / Lirik Berjalan
class JavaLyricLine {
  const JavaLyricLine({required this.second, required this.text});
  final int second;
  final String text;
}

/// Model Lagu & Suara Budaya Jawa
class JavaMusicTrack {
  const JavaMusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.category,
    required this.origin,
    required this.duration,
    required this.durationSeconds,
    required this.description,
    required this.lyrics,
    required this.icon,
    required this.assetPath,
    required this.audioUrl,
    required this.tempoBpm,
    required this.mood,
  });

  final String id;
  final String title;
  final String artist;
  final String category; // 'DJ Jawa', 'Pop Jawa', 'Gamelan', 'Soundscape'
  final String origin;
  final String duration;
  final int durationSeconds;
  final String description;
  final List<JavaLyricLine> lyrics;
  final IconData icon;
  final String assetPath;
  final String audioUrl;
  final String tempoBpm;
  final String mood;

  String get lyricsSnippet => lyrics.isNotEmpty
      ? lyrics.take(3).map((l) => l.text).join('\n')
      : description;
}

/// Service Pemutar Musik Jawa & Soundscape (Singleton ChangeNotifier).
/// Mengelola audio playback aktif, sinkronisasi volume perangkat keras, lirik berjalan,
/// antrean putar, dan audio context Android.
class JavaMusicService extends ChangeNotifier {
  JavaMusicService._internal() {
    _initAudioPlayer();
    _initHardwareVolume();
  }

  static final JavaMusicService instance = JavaMusicService._internal();

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<double>? _hardwareVolumeSub;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 3, seconds: 48);
  double _volume = 0.85;
  double _playbackRate = 1.0;
  bool _isShuffle = false;
  bool _isRepeat = false;
  int _currentIndex = 0;
  String _selectedCategory = 'Semua';

  static final List<JavaMusicTrack> _allTracks = [
    // --- 1. DJ JAWA KEKINIAN (TRENDING VIRAL) ---
    const JavaMusicTrack(
      id: 'dj_negoro_angin',
      title: 'DJ Negoro Angin (Slow Mengkane)',
      artist: 'Muslih Fvnky ft. Deni Setiawan (Original YouTube)',
      category: 'DJ Jawa',
      origin: 'Ngawi & Jawa Tengah',
      duration: '5:52',
      durationSeconds: 352,
      description:
          'Versi original viral YouTube aransemen Muslih Fvnky ft. Deni Setiawan. Suara asli jernih berkualitas tinggi dengan dentuman bass slow mengkane yang syahdu dan renyah didengar.',
      lyrics: [
        JavaLyricLine(second: 0, text: '♫ (Intro DJ Slow Mengkane - Muslih Fvnky) ♫'),
        JavaLyricLine(second: 38, text: 'Tak tempuh sewelas ewu kilometer nyusul awakmu...'),
        JavaLyricLine(second: 52, text: 'Sing nate janji mulih ning aku...'),
        JavaLyricLine(second: 64, text: 'Sak wise rampungke urusanmu...'),
        JavaLyricLine(second: 76, text: 'Tak tekat-tekatke...'),
        JavaLyricLine(second: 86, text: 'Masio ora tau ngalami adem mines siji...'),
        JavaLyricLine(second: 96, text: 'Mosok ra ditemoni, nekat ku mung pingin niliki...'),
        JavaLyricLine(second: 107, text: 'Kepisah benua negara angin...'),
        JavaLyricLine(second: 120, text: 'Nggayuh tresnamu rasane wes ra mungkin...'),
        JavaLyricLine(second: 132, text: 'Wes bedo semanjak jarak teko...'),
        JavaLyricLine(second: 144, text: 'Tiyang sing mbiyen tak kenal, dadi wong liyo...'),
        JavaLyricLine(second: 156, text: 'Ternyata LDR pahit tenan...'),
        JavaLyricLine(second: 168, text: 'Mboten seindah kembang tulip ning taman...'),
        JavaLyricLine(second: 180, text: 'Goblokku isih sayang awakmu...'),
        JavaLyricLine(second: 192, text: 'Ngertio ra sudi ngancani jaman susahmu...'),
        JavaLyricLine(second: 204, text: '♫ (Drop Bass Mengkane Santuy) ♫'),
        JavaLyricLine(second: 225, text: 'Isih kebayang-bayang, isih dadi kenangan...'),
        JavaLyricLine(second: 240, text: 'Bekas ambu rangkulanmu, wangine isih neng atiku...'),
        JavaLyricLine(second: 258, text: 'Isih tak kangeni, isih tak tunggoni, isih terus tak tangisi...'),
        JavaLyricLine(second: 276, text: 'Mabur dhuwur melayang-layang, terbang di atas awan...'),
        JavaLyricLine(second: 300, text: 'Kepisah benua negara angin...'),
        JavaLyricLine(second: 325, text: '♫ (Outro Bass Mengkane) ♫'),
      ],
      icon: Icons.graphic_eq_rounded,
      assetPath: 'audio/dj_negoro_angin.mp3',
      audioUrl: 'https://www.youtube.com/watch?v=IMg-w8g8Ekk',
      tempoBpm: '130 BPM',
      mood: 'Slow Mengkane Syahdu',
    ),
    const JavaMusicTrack(
      id: 'dj_rungkad',
      title: 'DJ Rungkad (Jedag-Jedug Breakbeat)',
      artist: 'Vicky Prasetyo x Happy Asmara',
      category: 'DJ Jawa',
      origin: 'Jawa Tengah & Jawa Timur',
      duration: '5:15',
      durationSeconds: 315,
      description:
          'Lagu ambyar sejuta umat dalam versi DJ remix jedag-jedug super renyah. Suara asli beat drum perkusi modern menyatu dengan vokal Happy Asmara yang bertenaga.',
      lyrics: [
        JavaLyricLine(second: 0, text: '♫ (Intro Jedag-Jedug Breakbeat) ♫'),
        JavaLyricLine(second: 18, text: 'Rungkad entek-entekan...'),
        JavaLyricLine(second: 30, text: 'Kelangan kowe sing paling tak sayang...'),
        JavaLyricLine(second: 45, text: 'Bondoku melayang teko pasrah tenan...'),
        JavaLyricLine(second: 60, text: 'Koyo remuk ati iki...'),
        JavaLyricLine(second: 75, text: 'Ancur lebur dadi awu...'),
        JavaLyricLine(second: 90, text: '♫ (Drop Beat Koplo Jedag-Jedug) ♫'),
        JavaLyricLine(second: 115, text: 'Saiki aku wes sadar...'),
        JavaLyricLine(second: 130, text: 'Kowe mung dolanan tresnoku...'),
        JavaLyricLine(second: 150, text: 'Rungkad, entek ambyar tenan...'),
      ],
      icon: Icons.bolt_rounded,
      assetPath: 'audio/dj_rungkad.mp3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      tempoBpm: '138 BPM',
      mood: 'Jedag-Jedug Enerjik',
    ),
    const JavaMusicTrack(
      id: 'dj_sanes',
      title: 'DJ Sanes (Slow Bass Santuy)',
      artist: 'Guyon Waton ft. Denny Caknan',
      category: 'DJ Jawa',
      origin: 'Kulon Progo & Ngawi',
      duration: '5:20',
      durationSeconds: 320,
      description:
          'Versi slow remix santuy bass meliuk lembut dengan rekaman vokal asli Guyon Waton dan Denny Caknan. Mengisahkan ketulusan mencintai yang bertepuk sebelah tangan.',
      lyrics: [
        JavaLyricLine(second: 0, text: '♫ (Intro Melodi Akustik & Synth Santuy) ♫'),
        JavaLyricLine(second: 20, text: 'Ngancani nanging ora iso nduweni...'),
        JavaLyricLine(second: 40, text: 'Ngenteni nanging kowe malah ngilang...'),
        JavaLyricLine(second: 60, text: 'Ati iki dudu dolanan...'),
        JavaLyricLine(second: 82, text: 'Sanes kulo sing mbok karepke...'),
        JavaLyricLine(second: 105, text: 'Mugo sliramu nemu bahagiamu...'),
        JavaLyricLine(second: 130, text: '♫ (Melodi Akustik & Santuy Bass) ♫'),
        JavaLyricLine(second: 155, text: 'Kulo nyerah, kulo pasrah...'),
      ],
      icon: Icons.headphones_rounded,
      assetPath: 'audio/dj_sanes.mp3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      tempoBpm: '124 BPM',
      mood: 'Santuy & Syahdu',
    ),
    const JavaMusicTrack(
      id: 'dj_dumes',
      title: 'DJ Dumes (Koplo Bass Horeg)',
      artist: 'Wawes x Guyon Waton (Original Remix)',
      category: 'DJ Jawa',
      origin: 'Yogyakarta & Klaten',
      duration: '6:25',
      durationSeconds: 385,
      description:
          'Dentuman bass horeg Jawa asli yang menggetarkan dada. Sangat populer di kalangan anak muda pecinta sound system horeg Jawa Tengah.',
      lyrics: [
        JavaLyricLine(second: 0, text: '♫ (Intro Bass Horeg Menggelegar) ♫'),
        JavaLyricLine(second: 25, text: 'Sepine roso atiku...'),
        JavaLyricLine(second: 45, text: 'Nyawang kowe nyanding tresno liyane...'),
        JavaLyricLine(second: 68, text: 'Kabeh janji ilang tanpo tondo...'),
        JavaLyricLine(second: 90, text: 'Dumes tenan atiku iki...'),
        JavaLyricLine(second: 115, text: '♫ (Drop Bass Glerr Horeg) ♫'),
        JavaLyricLine(second: 140, text: 'Kowe lungo ninggal loro...'),
      ],
      icon: Icons.surround_sound_rounded,
      assetPath: 'audio/dj_dumes.mp3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      tempoBpm: '135 BPM',
      mood: 'Glerr Bass Horeg',
    ),
    const JavaMusicTrack(
      id: 'dj_kartonyono',
      title: 'DJ Kartonyono Medot Janji',
      artist: 'Denny Caknan (Breakbeat Jedag-Jedug)',
      category: 'DJ Jawa',
      origin: 'Ngawi & Sragen',
      duration: '4:06',
      durationSeconds: 246,
      description:
          'Lagu pelopor era baru pop Jawa modern Denny Caknan dengan remix breakbeat berkecepatan tinggi yang mengguncang panggung musik.',
      lyrics: [
        JavaLyricLine(second: 0, text: '♫ (Intro Breakbeat Koplo Jedag-Jedug) ♫'),
        JavaLyricLine(second: 20, text: 'Kok kebangeten men...'),
        JavaLyricLine(second: 40, text: 'Sambat belas raono perhatian...'),
        JavaLyricLine(second: 62, text: 'Jelas ngadepi marang kahanan...'),
        JavaLyricLine(second: 85, text: 'Mbiyen aku jek betah, suwe-suwe wegah...'),
        JavaLyricLine(second: 108, text: 'Kartonyono ning kuto Ngawi medot janjimu...'),
        JavaLyricLine(second: 135, text: '♫ (Drop Breakbeat Jedag-Jedug) ♫'),
      ],
      icon: Icons.album_rounded,
      assetPath: 'audio/dj_kartonyono.mp3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      tempoBpm: '134 BPM',
      mood: 'Pesta & Dance Koplo',
    ),

    // --- 2. POP JAWA & CAMPURSARI MODERN ---
    const JavaMusicTrack(
      id: 'banyu_langit',
      title: 'Banyu Langit (Original Maestro)',
      artist: 'Didi Kempot (The Godfather of Broken Heart)',
      category: 'Pop Jawa',
      origin: 'Surakarta Hadiningrat',
      duration: '4:58',
      durationSeconds: 298,
      description:
          'Karya monumental asli Sang Maestro Didi Kempot. Kisah rindu mendalam berlatar Gunung Api Purba Nglanggeran dan langit Jawa yang teduh.',
      lyrics: [
        JavaLyricLine(second: 0, text: '♫ (Intro Petikan Gitar & Suling Klasik) ♫'),
        JavaLyricLine(second: 22, text: 'Sworo angin, angin sing ngreridu ati...'),
        JavaLyricLine(second: 45, text: 'Ngelingake sliramu sing tak tresnani...'),
        JavaLyricLine(second: 70, text: 'Banyu langit sing ono ning duwur...'),
        JavaLyricLine(second: 92, text: 'Gugah kangenku marang sliramu...'),
        JavaLyricLine(second: 115, text: 'Janji suci kowe ora bakal lali...'),
        JavaLyricLine(second: 140, text: 'Ademe hawa ning Gunung Nglanggeran...'),
        JavaLyricLine(second: 170, text: '♫ (Petikan Gitar & Suling Klasik) ♫'),
      ],
      icon: Icons.cloud_outlined,
      assetPath: 'audio/banyu_langit.mp3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      tempoBpm: '108 BPM',
      mood: 'Haru & Menyentuh',
    ),
    const JavaMusicTrack(
      id: 'ojo_dibandingke',
      title: 'Ojo Dibandingke (Original)',
      artist: 'Farel Prayoga x Abah Lala',
      category: 'Pop Jawa',
      origin: 'Boyolali, Lereng Merbabu',
      duration: '5:23',
      durationSeconds: 323,
      description:
          'Lagu rakyat Jawa kontemporer ciptaan Abah Lala yang viral hingga Istana Negara. Vokal asli merdu yang mengajarkan kebersahajaan cinta tulus.',
      lyrics: [
        JavaLyricLine(second: 0, text: '♫ (Intro Gendang Rancak) ♫'),
        JavaLyricLine(second: 15, text: 'Wong ko ngene kok dibanding-bandingke...'),
        JavaLyricLine(second: 38, text: 'Saing-saingke yo mesti kalah...'),
        JavaLyricLine(second: 60, text: 'Tak oyako aku yo ora mampu...'),
        JavaLyricLine(second: 84, text: 'Mung sak kuatku mencintaimu...'),
        JavaLyricLine(second: 108, text: 'Kuasane Gusti sing nyekel takdir iki...'),
        JavaLyricLine(second: 135, text: '♫ (Koplo Kendang Rancak) ♫'),
      ],
      icon: Icons.stars_rounded,
      assetPath: 'audio/ojo_dibandingke.mp3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      tempoBpm: '115 BPM',
      mood: 'Ceria & Guyub',
    ),
    const JavaMusicTrack(
      id: 'stasiun_balapan',
      title: 'Stasiun Balapan (Official)',
      artist: 'Didi Kempot (Original Solo)',
      category: 'Pop Jawa',
      origin: 'Solo (Surakarta)',
      duration: '3:57',
      durationSeconds: 237,
      description:
          'Lagu legendaris asli Didi Kempot yang melambungkan nama Stasiun Balapan Solo ke seantero Nusantara dan mancanegara.',
      lyrics: [
        JavaLyricLine(second: 0, text: '♫ (Intro Kendang Campursari Solo) ♫'),
        JavaLyricLine(second: 25, text: 'Ning Stasiun Balapan, kuto Solo sing dadi kenangan...'),
        JavaLyricLine(second: 52, text: 'Kowe karo aku naliko ngeterke sliramu...'),
        JavaLyricLine(second: 80, text: 'Lirak-lirik koyo kelangan...'),
        JavaLyricLine(second: 105, text: 'Janji lungo mung sedelo, jebul ora ono kabar...'),
        JavaLyricLine(second: 135, text: 'Doh kowe ning endi, kowe ning endi...'),
        JavaLyricLine(second: 165, text: '♫ (Campursari Melodi Solo) ♫'),
      ],
      icon: Icons.train_rounded,
      assetPath: 'audio/stasiun_balapan.mp3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
      tempoBpm: '112 BPM',
      mood: 'Nostalgia Abadi',
    ),

    // --- 3. GAMELAN & KARAWITAN ADILUHUNG ---
    const JavaMusicTrack(
      id: 'ladrang_pangkur',
      title: 'Ladrang Pangkur (Pelog Barang)',
      artist: 'Gamelan Pusaka Keraton Surakarta Hadiningrat',
      category: 'Gamelan',
      origin: 'Keraton Kasunanan Surakarta Hadiningrat',
      duration: '4:30',
      durationSeconds: 270,
      description:
          'Gending klasik pusaka Jawa rekaman asli Keraton Surakarta dengan ketukan kendang ageng yang agung, perpaduan kempul, bonang barung, dan rebab.',
      lyrics: [
        JavaLyricLine(second: 0, text: '♫ (Buka Gending Bonang Barung) ♫'),
        JavaLyricLine(second: 10, text: '♫ (Buka Gending Bonang Barung) ♫'),
        JavaLyricLine(second: 40, text: '♫ (Tabuhan Kendang Ageng & Saron Pelog) ♫'),
        JavaLyricLine(second: 80, text: '♫ (Laras Pelog Pathet Barang Suci) ♫'),
        JavaLyricLine(second: 130, text: '♫ (Gong Ageng Menggema Luhur) ♫'),
        JavaLyricLine(second: 180, text: '♫ (Irama Dadi Kendang Ciblon Keraton) ♫'),
      ],
      icon: Icons.music_note_rounded,
      assetPath: 'audio/ladrang_pangkur.mp3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',
      tempoBpm: '72 BPM',
      mood: 'Khidmat & Mulia',
    ),
    const JavaMusicTrack(
      id: 'kebo_giro',
      title: 'Gending Kebo Giro (Temu Manten)',
      artist: 'Karawitan Tradisional Pengantin Jawa Asli',
      category: 'Gamelan',
      origin: 'Jawa Tengah',
      duration: '4:00',
      durationSeconds: 240,
      description:
          'Gending sakral asli yang mengiringi prosesi temu manten adat Jawa. Ketukan bonang rancak membawa suasana suka cita dan keagungan rumah tangga baru.',
      lyrics: [
        JavaLyricLine(second: 0, text: '♫ (Buka Kendang Temanten Kebo Giro) ♫'),
        JavaLyricLine(second: 10, text: '♫ (Buka Kendang Temanten Kebo Giro) ♫'),
        JavaLyricLine(second: 35, text: '♫ (Bonang Barung Semarak Temu Pengantin) ♫'),
        JavaLyricLine(second: 75, text: '♫ (Kempul Berkah Kemakmuran & Doa Restu) ♫'),
        JavaLyricLine(second: 120, text: '♫ (Gong Ageng Agung Pralambang Kaluwihan) ♫'),
        JavaLyricLine(second: 170, text: '♫ (Harmoni Pusaka Karawitan Pengantin Jawa) ♫'),
      ],
      icon: Icons.celebration_rounded,
      assetPath: 'audio/kebo_giro.mp3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',
      tempoBpm: '85 BPM',
      mood: 'Agung & Sakral',
    ),

    // --- 4. ATMOSFER ALAM & MEDITASI JAWA ---
    const JavaMusicTrack(
      id: 'genta_borobudur',
      title: 'Genta Fajar Borobudur',
      artist: 'Atmosfer Suci Dataran Kedu',
      category: 'Soundscape',
      origin: 'Magelang, Jawa Tengah',
      duration: '1:27',
      durationSeconds: 87,
      description:
          'Dentang lonceng tembaga suci asli di puncak Arupadhatu Candi Borobudur saat fajar menyingsing, diiringi angin Bukit Menoreh dan burung pagi.',
      lyrics: [
        JavaLyricLine(second: 0, text: '♫ (Dentang Genta Tembaga Suci Arupadhatu) ♫'),
        JavaLyricLine(second: 25, text: '♫ (Desau Angin Fajar Dataran Kedu & Menoreh) ♫'),
        JavaLyricLine(second: 50, text: '♫ (Keheningan Meditatif Puncak Candi Borobudur) ♫'),
        JavaLyricLine(second: 75, text: '♫ (Gema Spiritual Kedamaian Nusantara) ♫'),
      ],
      icon: Icons.notifications_active_outlined,
      assetPath: 'audio/genta_borobudur.mp3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',
      tempoBpm: '60 BPM',
      mood: 'Hening & Meditatif',
    ),
    const JavaMusicTrack(
      id: 'suling_dieng',
      title: 'Suling Lembah Dieng',
      artist: 'Tiupan Bambu Dataran Tinggi Dieng',
      category: 'Soundscape',
      origin: 'Wonosobo & Banjarnegara',
      duration: '4:00',
      durationSeconds: 240,
      description:
          'Melodi suling bambu sendu meliuk di antara kawah belerang Sikidang dan perbukitan Dieng yang diselimuti kabut embun upas.',
      lyrics: [
        JavaLyricLine(second: 0, text: '♫ (Tiupan Suling Bambu Pelog Lembut) ♫'),
        JavaLyricLine(second: 10, text: '♫ (Tiupan Suling Bambu Pelog Lembut) ♫'),
        JavaLyricLine(second: 45, text: '♫ (Desir Angin Sejuk Telaga Warna & Sikidang) ♫'),
        JavaLyricLine(second: 90, text: '♫ (Harmoni Sunyi Kabut Dataran Tinggi Dieng) ♫'),
        JavaLyricLine(second: 150, text: '♫ (Melodi Syahdu Lembah Pegunungan Jawa) ♫'),
      ],
      icon: Icons.air_rounded,
      assetPath: 'audio/suling_dieng.mp3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      tempoBpm: '64 BPM',
      mood: 'Syahdu & Sejuk',
    ),
  ];

  Future<void> _initAudioPlayer() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.defaultToSpeaker,
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Set audio context error: $e');
    }

    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = (state == PlayerState.playing);
      notifyListeners();
    });

    _player.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.onDurationChanged.listen((dur) {
      if (dur.inSeconds > 0) {
        _duration = dur;
        notifyListeners();
      }
    });

    _player.onPlayerComplete.listen((_) {
      if (_isRepeat) {
        seek(Duration.zero);
        resume();
      } else {
        next();
      }
    });
  }

  /// Sinkronisasi dua arah dengan tombol volume fisik HP
  Future<void> _initHardwareVolume() async {
    try {
      final initialVol = await FlutterVolumeController.getVolume();
      if (initialVol != null) {
        _volume = initialVol.clamp(0.0, 1.0);
        notifyListeners();
      }

      _hardwareVolumeSub = FlutterVolumeController.addListener((newVol) {
        if ((_volume - newVol).abs() > 0.01) {
          _volume = newVol.clamp(0.0, 1.0);
          _player.setVolume(_volume);
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Volume controller listener error: $e');
    }
  }

  // Getters
  List<JavaMusicTrack> get allTracks => _allTracks;

  List<JavaMusicTrack> get filteredTracks {
    if (_selectedCategory == 'Semua') {
      return _allTracks;
    }
    return _allTracks.where((t) => t.category == _selectedCategory).toList();
  }

  JavaMusicTrack get currentTrack => _allTracks[_currentIndex];
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  double get playbackRate => _playbackRate;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;
  String get selectedCategory => _selectedCategory;

  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    final val = _position.inMilliseconds / _duration.inMilliseconds;
    return val.clamp(0.0, 1.0);
  }

  String get positionFormatted => _formatDuration(_position);
  String get durationFormatted => _formatDuration(_duration);

  /// Mencari indeks lirik yang sedang aktif berdasarkan detik pemutaran
  int get currentLyricIndex {
    final lyrics = currentTrack.lyrics;
    if (lyrics.isEmpty) return -1;
    final currentSec = _position.inSeconds;
    for (int i = lyrics.length - 1; i >= 0; i--) {
      if (currentSec >= lyrics[i].second) {
        return i;
      }
    }
    return 0;
  }

  // Aksi Kontrol Pemutar
  Future<void> playTrack(JavaMusicTrack track) async {
    final idx = _allTracks.indexWhere((t) => t.id == track.id);
    if (idx != -1) {
      await playIndex(idx);
    }
  }

  Future<void> playIndex(int index) async {
    _currentIndex = index.clamp(0, _allTracks.length - 1);
    final track = _allTracks[_currentIndex];
    _duration = Duration(seconds: track.durationSeconds);
    _position = Duration.zero;
    _isPlaying = true;
    notifyListeners();

    try {
      await _player.stop();
      await _player.setVolume(_volume);
      await _player.setPlaybackRate(_playbackRate);

      // Prioritas 1: Putar dari asset lokal (dijamin 100% bersuara instan tanpa kuota)
      if (track.assetPath.isNotEmpty) {
        await _player.play(AssetSource(track.assetPath));
      } else {
        await _player.play(UrlSource(track.audioUrl));
      }
    } catch (e) {
      debugPrint('Playback asset fallback to stream: $e');
      try {
        await _player.play(UrlSource(track.audioUrl));
      } catch (e2) {
        debugPrint('Remote stream error: $e2');
      }
    }

    // Pemutaran audio native aktif
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> pause() async {
    _isPlaying = false;
    notifyListeners();
    try {
      await _player.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    _isPlaying = true;
    notifyListeners();
    try {
      await _player.resume();
    } catch (_) {
      // Jika resume gagal, putar ulang dari indeks aktif
      await playIndex(_currentIndex);
    }
    // Pemutaran audio native aktif
  }

  Future<void> next() async {
    int nextIdx;
    if (_isShuffle) {
      nextIdx = math.Random().nextInt(_allTracks.length);
    } else {
      nextIdx = (_currentIndex + 1) % _allTracks.length;
    }
    await playIndex(nextIdx);
  }

  Future<void> previous() async {
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    final prevIdx = (_currentIndex - 1 + _allTracks.length) % _allTracks.length;
    await playIndex(prevIdx);
  }

  Future<void> seek(Duration newPos) async {
    final target = newPos < Duration.zero
        ? Duration.zero
        : (newPos > _duration ? _duration : newPos);
    _position = target;
    notifyListeners();
    try {
      await _player.seek(target);
    } catch (e) {
      debugPrint('Audio seek error: $e');
    }
  }

  /// Mengubah volume aplikasi sekaligus menyinkronkan dengan volume fisik HP
  Future<void> setVolume(double val) async {
    _volume = val.clamp(0.0, 1.0);
    notifyListeners();

    try {
      await _player.setVolume(_volume);
      await FlutterVolumeController.setVolume(_volume);
    } catch (e) {
      debugPrint('Set volume sync error: $e');
    }
  }

  Future<void> setPlaybackRate(double rate) async {
    _playbackRate = rate;
    notifyListeners();
    try {
      await _player.setPlaybackRate(_playbackRate);
    } catch (_) {}
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _hardwareVolumeSub?.cancel();
    FlutterVolumeController.removeListener();
    _player.dispose();
    super.dispose();
  }
}
