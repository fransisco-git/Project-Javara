import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';

/// Model Karakter Aksara Jawa Hanacaraka.
class JavaneseGlyph {
  const JavaneseGlyph({
    required this.latin,
    required this.javanese,
    required this.meaning,
    required this.philosophy,
    required this.pronunciation,
  });

  final String latin;
  final String javanese;
  final String meaning;
  final String philosophy;
  final String pronunciation;
}

/// Sanggar Aksara Jawa (Interactive Hanacaraka Studio).
/// Fitur interaktif untuk mempelajari, mentransliterasi, dan meresapi filosofi
/// luhur 20 Aksara Jawa Hanacaraka warisan Ajisaka.
class AksaraJawaScreen extends StatefulWidget {
  const AksaraJawaScreen({super.key});

  @override
  State<AksaraJawaScreen> createState() => _AksaraJawaScreenState();
}

class _AksaraJawaScreenState extends State<AksaraJawaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _inputController = TextEditingController(
    text: 'Javara Jawa Tengah',
  );
  String _translatedText = 'ꦗꦮ꦳ꦫ ꦗꦮ ꦠꦼꦔꦃ';
  JavaneseGlyph? _selectedGlyph;

  static const List<JavaneseGlyph> _glyphs = [
    // Baris 1: Hana caraka
    JavaneseGlyph(
      latin: 'Ha',
      javanese: 'ꦲ',
      meaning: 'Urip / Nafas',
      philosophy: 'Hana caraka: Wujud utusan Sang Maha Pencipta, napas kehidupan manusia yang suci.',
      pronunciation: '[ha] seperti pada "hati"',
    ),
    JavaneseGlyph(
      latin: 'Na',
      javanese: 'ꦤ',
      meaning: 'Karep / Niat',
      philosophy: 'Kemauan dan tekad batin yang tulus untuk mengabdi pada kebaikan semesta.',
      pronunciation: '[na] seperti pada "nyata"',
    ),
    JavaneseGlyph(
      latin: 'Ca',
      javanese: 'ꦕ',
      meaning: 'Cipta / Nurani',
      philosophy: 'Daya cipta budi pekerti yang membedakan manusia mulia dari kebodohan.',
      pronunciation: '[tʃa] seperti pada "cahaya"',
    ),
    JavaneseGlyph(
      latin: 'Ra',
      javanese: 'ꦫ',
      meaning: 'Rasa / Jiwa',
      philosophy: 'Kepekaan kalbu dalam merasakan keselarasan mikrokosmos dan makrokosmos.',
      pronunciation: '[ra] seperti pada "rasa"',
    ),
    JavaneseGlyph(
      latin: 'Ka',
      javanese: 'ꦏ',
      meaning: 'Karsa / Rohani',
      philosophy: 'Kekuatan batin untuk mewujudkan karya adiluhung bagi sesama umat manusia.',
      pronunciation: '[ka] seperti pada "karsa"',
    ),

    // Baris 2: Data sawala
    JavaneseGlyph(
      latin: 'Da',
      javanese: 'ꦢ',
      meaning: 'Dhat / Dzat',
      philosophy: 'Data sawala: Mengingatkan pertentangan abadi antara hawa nafsu dan nurani.',
      pronunciation: '[da] lembut dental',
    ),
    JavaneseGlyph(
      latin: 'Ta',
      javanese: 'ꦠ',
      meaning: 'Tetes / Asal',
      philosophy: 'Asal mula penciptaan manusia dari sari pati tanah dan berkah Illahi.',
      pronunciation: '[ta] lembut dental',
    ),
    JavaneseGlyph(
      latin: 'Sa',
      javanese: 'ꦱ',
      meaning: 'Sifat / Karakter',
      philosophy: 'Perangai luhur yang memancarkan kejujuran, tepa slira, dan keadilan.',
      pronunciation: '[sa] seperti pada "sabar"',
    ),
    JavaneseGlyph(
      latin: 'Wa',
      javanese: 'ꦮ',
      meaning: 'Wujud / Wadah',
      philosophy:
          'Jasad jasmani fana yang menjadi istana bagi jiwa yang abadi.',
      pronunciation: '[wa] seperti pada "waskitha"',
    ),
    JavaneseGlyph(
      latin: 'La',
      javanese: 'ꦭ',
      meaning: 'Lelampahan',
      philosophy: 'Perjalanan hidup manusia yang penuh cobaan menuju sangkan paraning dumadi.',
      pronunciation: '[la] seperti pada "lakon"',
    ),

    // Baris 3: Padha jayanya
    JavaneseGlyph(
      latin: 'Pa',
      javanese: 'ꦥ',
      meaning: 'Papan / Kedudukan',
      philosophy: 'Padha jayanya: Kekuatan yang berimbang antara akal budi dan kekuatan lahir.',
      pronunciation: '[pa] bilabial tegas',
    ),
    JavaneseGlyph(
      latin: 'Dha',
      javanese: 'ꦝ',
      meaning: 'Dhuhur / Luhur',
      philosophy: 'Keluhuran budi pekerti yang harus dijunjung di atas segala kedudukan.',
      pronunciation: '[ɖa] retrofleks tebal',
    ),
    JavaneseGlyph(
      latin: 'Ja',
      javanese: 'ꦗ',
      meaning: 'Jantung / Sukma',
      philosophy: 'Detak kesadaran batin yang senantiasa berdzikir memuji keagungan alam.',
      pronunciation: '[dʒa] seperti pada "jagat"',
    ),
    JavaneseGlyph(
      latin: 'Ya',
      javanese: 'ꦪ',
      meaning: 'Yakin / Mantap',
      philosophy: 'Keyakinan tanpa ragu pada kebenaran hukum karma dan keadilan Illahi.',
      pronunciation: '[ja] seperti pada "yakin"',
    ),
    JavaneseGlyph(
      latin: 'Nya',
      javanese: 'ꦚ',
      meaning: 'Nyata / Pasrah',
      philosophy: 'Keikhlasan menerima kenyataan takdir (narima ing pandum).',
      pronunciation: '[ɲa] palatal nasal',
    ),

    // Baris 4: Maga bathanga
    JavaneseGlyph(
      latin: 'Ma',
      javanese: 'ꦩ',
      meaning: 'Madhep / Kiblat',
      philosophy: 'Maga bathanga: Menjadi mayat bersama bila angkara murka dibiarkan merajalela.',
      pronunciation: '[ma] bilabial hangat',
    ),
    JavaneseGlyph(
      latin: 'Ga',
      javanese: 'ꦒ',
      meaning: 'Gusti / Hyang Agung',
      philosophy:
          'Kepasrahan total kepada Sang Sangkan Paraning Dumadi (Tuhan YME).',
      pronunciation: '[ga] velar berat',
    ),
    JavaneseGlyph(
      latin: 'Ba',
      javanese: 'ꦧ',
      meaning: 'Budi / Luhur',
      philosophy: 'Kebajikan tanpa pamrih yang menjadi bekal abadi menghadap Sang Pencipta.',
      pronunciation: '[ba] bilabial mantap',
    ),
    JavaneseGlyph(
      latin: 'Tha',
      javanese: 'ꦛ',
      meaning: 'Tuhu / Setia',
      philosophy:
          'Kesetiaan pada janji dan komitmen moral menjaga kelestarian budaya.',
      pronunciation: '[ʈa] retrofleks tegas',
    ),
    JavaneseGlyph(
      latin: 'Nga',
      javanese: 'ꦔ',
      meaning: 'Ngungun / Takjub',
      philosophy: 'Rasa takjub dan rendah hati menyaksikan kebesaran alam semesta Jawa.',
      pronunciation: '[ŋa] velar nasal',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedGlyph = _glyphs.first;
    _transliterate(_inputController.text);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _transliterate(String input) {
    if (input.trim().isEmpty) {
      setState(() => _translatedText = 'ꦲꦤꦕꦫꦏ');
      return;
    }

    // Algoritma transliterasi fonetis cerdas Aksara Jawa
    final buffer = StringBuffer();
    final lower = input.toLowerCase();

    int i = 0;
    while (i < lower.length) {
      if (lower[i] == ' ') {
        buffer.write(' ');
        i++;
        continue;
      }

      // Cek digraf 2-3 huruf
      bool matched = false;
      final remaining = lower.substring(i);

      final multiMap = <String, String>{
        'dha': 'ꦝ',
        'tha': 'ꦛ',
        'nya': 'ꦚ',
        'nga': 'ꦔ',
        'kh': 'ꦏ꦳',
        'dz': 'ꦢ꦳',
        'sy': 'ꦱ꦳',
      };

      for (final entry in multiMap.entries) {
        if (remaining.startsWith(entry.key)) {
          buffer.write(entry.value);
          i += entry.key.length;
          matched = true;
          break;
        }
      }
      if (matched) continue;

      // Cek pasangan huruf vokal & konsonan
      final char = lower[i];
      final singleMap = <String, String>{
        'h': 'ꦲ',
        'n': 'ꦤ',
        'c': 'ꦕ',
        'r': 'ꦫ',
        'k': 'ꦏ',
        'd': 'ꦢ',
        't': 'ꦠ',
        's': 'ꦱ',
        'w': 'ꦮ',
        'l': 'ꦭ',
        'p': 'ꦥ',
        'j': 'ꦗ',
        'y': 'ꦪ',
        'm': 'ꦩ',
        'g': 'ꦒ',
        'b': 'ꦧ',
        'a': 'ꦲ',
        'i': 'ꦲꦶ',
        'u': 'ꦲꦸ',
        'e': 'ꦲꦼ',
        'o': 'ꦲꦺꦴ',
      };

      if (singleMap.containsKey(char)) {
        buffer.write(singleMap[char]);
      } else {
        buffer.write(char);
      }
      i++;
    }

    setState(() {
      _translatedText = buffer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A3A25),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              'Sanggar Aksara Jawa',
              style: JText.serif(
                17,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'ꦲꦤꦕꦫꦏ · Khasanah Karuhun Adiluhung',
              style: JText.serif(10.5, color: const Color(0xFFFFDF9E)),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: JColors.gold,
          indicatorWeight: 3,
          labelColor: JColors.gold,
          unselectedLabelColor: const Color(0xFFDCC8B0),
          labelStyle: JText.serif(13, weight: FontWeight.w700),
          tabs: const [
            Tab(text: '20 Aksara Pokok'),
            Tab(text: 'Penerjemah Latin'),
            Tab(text: 'Filosofi Ajisaka'),
          ],
        ),
      ),
      body: JBackground(
        variant: HeritageBackgroundVariant.warmParchment,
        child: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: 20 AKSARA POKOK
            _buildGlyphsTab(),

            // TAB 2: PENERJEMAH LATIN
            _buildTransliteratorTab(),

            // TAB 3: FILOSOFI AJISAKA
            _buildPhilosophyTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlyphsTab() {
    return ListView(
      padding: const EdgeInsets.all(18),
      physics: const BouncingScrollPhysics(),
      children: [
        // Kartu Sorotan Aksara Terpilih
        if (_selectedGlyph != null) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF382315), Color(0xFF563622)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: JColors.gold.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x223A261D),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: const Color(0x33000000),
                    shape: BoxShape.circle,
                    border: Border.all(color: JColors.gold, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _selectedGlyph!.javanese,
                    style: const TextStyle(
                      fontSize: 44,
                      color: JColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _selectedGlyph!.latin,
                            style: JText.serif(
                              22,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: JColors.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _selectedGlyph!.meaning,
                              style: JText.serif(
                                11,
                                weight: FontWeight.w700,
                                color: JColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedGlyph!.pronunciation,
                        style: JText.serif(12, color: const Color(0xFFFFE0A0)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedGlyph!.philosophy,
                        style: JText.serif(
                          12.5,
                          color: const Color(0xFFEADBCE),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        Text(
          'Sentuh aksara untuk mendalami maknanya:',
          style: JText.serif(13.5, weight: FontWeight.w600, color: JColors.ink),
        ),
        const SizedBox(height: 12),

        // Grid 20 Aksara
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.95,
          ),
          itemCount: _glyphs.length,
          itemBuilder: (context, idx) {
            final glyph = _glyphs[idx];
            final isSel = _selectedGlyph == glyph;

            return InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedGlyph = glyph);
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSel
                      ? const Color(0xFF5A3A25)
                      : const Color(0xFFFFFDF9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? JColors.gold : const Color(0xFFE2D4BE),
                    width: isSel ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSel
                          ? const Color(0x22C79B3A)
                          : const Color(0x0C000000),
                      blurRadius: isSel ? 10 : 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      glyph.javanese,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isSel ? JColors.gold : JColors.button,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      glyph.latin,
                      style: JText.serif(
                        12,
                        weight: FontWeight.w700,
                        color: isSel ? Colors.white : JColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransliteratorTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2D4BE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.edit_note_rounded,
                    color: JColors.button,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ketik Teks Huruf Latin:',
                    style: JText.serif(
                      14,
                      weight: FontWeight.w700,
                      color: JColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _inputController,
                onChanged: _transliterate,
                style: JText.serif(15, color: JColors.ink),
                decoration: InputDecoration(
                  hintText: 'Contoh: Borobudur, Semarang, Surakarta...',
                  hintStyle: JText.serif(14, color: JColors.muted),
                  filled: true,
                  fillColor: const Color(0xFFF7F1E6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Hasil Transliterasi Aksara Jawa
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF382315), Color(0xFF563622)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: JColors.gold.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x223A261D),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'HASIL AKSARA JAWA',
                style: JText.serif(
                  11,
                  weight: FontWeight.w700,
                  color: JColors.gold,
                ).copyWith(letterSpacing: 1.4),
              ),
              const SizedBox(height: 14),
              SelectableText(
                _translatedText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 34,
                  height: 1.4,
                  color: Color(0xFFFFDF9E),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(ClipboardData(text: _translatedText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '✓ Aksara Jawa berhasil disalin ke papan klip.',
                          ),
                          backgroundColor: JColors.button,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JColors.gold,
                      foregroundColor: JColors.night,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: JColors.night,
                    ),
                    label: Text(
                      'Salin Aksara',
                      style: JText.serif(
                        12.5,
                        weight: FontWeight.w700,
                        color: JColors.night,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Contoh Aksara Populer
        Text(
          'Contoh Istilah Budaya Jawa Populer:',
          style: JText.serif(14, weight: FontWeight.w700, color: JColors.ink),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSampleChip('Javara'),
            _buildSampleChip('Borobudur'),
            _buildSampleChip('Surakarta'),
            _buildSampleChip('Semarang'),
            _buildSampleChip('Batik'),
            _buildSampleChip('Gamelan'),
            _buildSampleChip('Wayang'),
            _buildSampleChip('Mataram'),
          ],
        ),
      ],
    );
  }

  Widget _buildSampleChip(String text) {
    return ActionChip(
      label: Text(
        text,
        style: JText.serif(12, weight: FontWeight.w600, color: JColors.button),
      ),
      backgroundColor: const Color(0xFFF3E7D5),
      side: const BorderSide(color: Color(0xFFDEC5A4)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        HapticFeedback.selectionClick();
        _inputController.text = text;
        _transliterate(text);
      },
    );
  }

  Widget _buildPhilosophyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2D4BE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hikayat Ajisaka & Sumpah Dua Abdi',
                style: JText.serif(
                  18,
                  weight: FontWeight.w700,
                  color: JColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Aksara Jawa Hanacaraka diciptakan oleh Prabu Ajisaka dari Kerajaan Medang Kamulan untuk mengabadikan kesetiaan dua abdinya yang teguh memegang amanah: Dora dan Sembada.',
                style: JText.serif(
                  13.5,
                  color: const Color(0xFF4A3828),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              _buildStanza(
                'ꦲꦤꦕꦫꦏ',
                'Hana Caraka',
                'Ada dua utusan yang setia menjaga titah amanah.',
              ),
              const SizedBox(height: 10),
              _buildStanza(
                'ꦢꦠꦱꦮꦭ',
                'Data Sawala',
                'Keduanya berselisih paham karena sama-sama menjunjung perintah sang raja.',
              ),
              const SizedBox(height: 10),
              _buildStanza(
                'ꦥꦝꦗꦪꦚ',
                'Padha Jayanya',
                'Keduanya sama-sama sakti mandraguna dan tangguh tak tertandingi.',
              ),
              const SizedBox(height: 10),
              _buildStanza(
                'ꦩꦒꦧꦛꦔ',
                'Maga Bathanga',
                'Keduanya sama-sama gugur menjadi jasad demi kehormatan janji suci.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStanza(String aksara, String latin, String meaning) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDEC5A4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF5A3A25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              aksara,
              style: const TextStyle(
                fontSize: 18,
                color: JColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  latin,
                  style: JText.serif(
                    13.5,
                    weight: FontWeight.w700,
                    color: JColors.ink,
                  ),
                ),
                Text(
                  meaning,
                  style: JText.serif(
                    11.5,
                    color: const Color(0xFF6E5946),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
