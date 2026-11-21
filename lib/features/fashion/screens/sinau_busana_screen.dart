import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../data/javanese_clothing_data.dart';

/// Layar Pembelajaran & Tantangan Kuis Kebudayaan Busana Jawa ("Sinau Busana Adat")
class SinauBusanaScreen extends StatefulWidget {
  const SinauBusanaScreen({super.key, this.isTab = false});

  final bool isTab;

  @override
  State<SinauBusanaScreen> createState() => _SinauBusanaScreenState();
}

class _SinauBusanaScreenState extends State<SinauBusanaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Status Kuis Interaktif
  int _currentQuizIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswerSubmitted = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _submitAnswer(int index) {
    if (_isAnswerSubmitted) return;
    final quiz = JavaneseClothingData.fashionQuizzes[_currentQuizIndex];
    setState(() {
      _selectedAnswerIndex = index;
      _isAnswerSubmitted = true;
      if (index == quiz.correctOptionIndex) {
        _score += 20;
      }
    });
  }

  void _nextQuiz() {
    setState(() {
      if (_currentQuizIndex < JavaneseClothingData.fashionQuizzes.length - 1) {
        _currentQuizIndex++;
        _selectedAnswerIndex = null;
        _isAnswerSubmitted = false;
      }
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentQuizIndex = 0;
      _selectedAnswerIndex = null;
      _isAnswerSubmitted = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: !widget.isTab,
        leading: widget.isTab
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF382315),
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Column(
          children: [
            const Text(
              'Sinau Busana Jawa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF382315),
              ),
            ),
            Text(
              'ꦱꦶꦤꦲꦸꦧꦸꦱꦤꦗꦮ',
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFFB08D57),
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFB08D57),
          indicatorWeight: 2.5,
          labelColor: const Color(0xFF382315),
          unselectedLabelColor: const Color(0xFF7D6C5D),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Khasanah Pengetahuan'),
            Tab(text: 'Tantangan & Kuis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKnowledgeTab(),
          _buildQuizTab(),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: KHASANAH PENGETAHUAN & KOMPARASI HISTORIS
  // ===========================================================================
  Widget _buildKnowledgeTab() {
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, widget.isTab ? 96 : 16),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. Beskap vs Surjan
        _buildArticleCard(
          title: 'Beskap vs. Surjan: Anatomi, Kancing & Filosofi',
          javaneseScript: 'ꦧꦼꦱ꧀ꦏꦥ꧀ꦭꦤ꧀ꦱꦸꦂꦗꦤ꧀',
          tag: 'STUDI BANDING HISTORIS',
          summary:
              'Meskipun keduanya adalah busana pria Jawa, Beskap memiliki kerah tegak kancing asimetris menyamping dengan potongan krowok di belakang untuk keris, sedangkan Surjan memiliki potongan lurus di depan dengan 6 kancing dada melambangkan Rukun Iman dan 2 di leher melambangkan Kalimah Syahadat.',
          points: [
            'Beskap: Busana resmi pasowanan agung di Keraton Kasunanan Surakarta.',
            'Surjan: Warisan Mataram Islam yang dirancang oleh Sunan Kalijaga/Sultan Agung.',
            'Surjan Ontrokusumo bermotif bunga hanya untuk kaum bangsawan.',
            'Surjan Lurik garis vertikal dipakai oleh rakyat dan abdi dalem.',
          ],
        ),
        const SizedBox(height: 16),

        // 2. Struktur Busana Jawi Jangkep
        _buildArticleCard(
          title: 'Struktur Busana Jawi Jangkep Kasunanan Surakarta',
          javaneseScript: 'ꦗꦮꦶꦗꦁꦏꦼꦥ꧀ꦱꦸꦫꦏꦂꦠ',
          tag: 'TATA BUSANA ADILUHUNG',
          summary:
              'Busana Jawi Jangkep tersusun dari 7 elemen sakral: Blangkon trepes, Rasukan Beskap, Bebet jarik wiru, Sabuk cinde pengekang hawa nafsu, Epek timang sepuh emas, Keris ladrang pusaka, dan Selop beludru payet.',
          points: [
            'Makna "Jawi Jangkep": Kelengkapan lahir batin seorang pria berjiwa ksatria.',
            'Keris diselipkan di belakang sebagai lambang senjata bukan untuk dipamerkan.',
            'Wiru jarik menghadap ke kiri dengan ujung menyudut rapi khas gaya Solo.',
          ],
        ),
        const SizedBox(height: 16),

        // 3. Paes Ageng vs Kanigaran
        _buildArticleCard(
          title: 'Paes Ageng vs. Kanigaran: Mahakarya Tata Rias Pengantin',
          javaneseScript: 'ꦥꦲꦺꦱ꧀ꦲꦒꦼꦁꦏꦤꦶꦒꦫꦤ꧀',
          tag: 'BUSANA PERNIKAHAN AGUNG',
          summary:
              'Paes Ageng mengusung lekukan paes bertepi prada emas di dahi dengan dodot kampuh, sedangkan Kanigaran mengenakan beskap dan kebaya beludru sutra hitam berhias sulaman kawat emas prada nan megah bersanding dengan kuluk tinggi.',
          points: [
            'Paes cengkorongan melambangkan kesucian batin pengantin wanita.',
            'Pengantin diposisikan laksana raja dan ratu sadina (sehari di pelaminan).',
            'Motif jarik Sidomukti mengiringi doa kelanggengan jodoh dunia akhirat.',
          ],
        ),
        const SizedBox(height: 16),

        // 4. Batik Larangan vs Batik Umum
        _buildArticleCard(
          title: 'Batik Awisan Dalem: Mengenal Ragam Motif Larangan',
          javaneseScript: 'ꦧꦠꦶꦏ꧀ꦭꦫꦔꦤ꧀ꦏꦫꦠꦺꦴꦤ꧀',
          tag: 'KOSMOLOGI BATIK KERATON',
          summary:
              'Keraton Surakarta dan Yogyakarta menetapkan aturan motif larangan seperti Parang Barong, Udan Liris, Semen Rama, dan Cemukiran yang hanya boleh dikenakan raja dan pangeran pati untuk menjaga ketertiban kosmologis istana.',
          points: [
            'Parang Barong ukuran di atas 8 cm: Simbol kedaulatan Sunan/Sultan.',
            'Rakyat umum mengenakan motif Kawung, Truntum, Ceplok, dan Sidoasih.',
            'Batik Pesisir Pekalongan menghadirkan motif buketan bunga yang bebas merdeka.',
          ],
        ),
      ],
    );
  }

  Widget _buildArticleCard({
    required String title,
    required String javaneseScript,
    required String tag,
    required String summary,
    required List<String> points,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x33B08D57), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10382315),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0x20B08D57),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0x44B08D57), width: 0.8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF382315),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                javaneseScript,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB08D57),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: JText.serif(
              16,
              weight: FontWeight.w700,
              color: const Color(0xFF382315),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(fontSize: 12, color: Color(0xFF4A3828), height: 1.45),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EADA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x22B08D57), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: points.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✦ ', style: TextStyle(color: Color(0xFFB08D57), fontSize: 10)),
                      Expanded(
                        child: Text(
                          p,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF382315)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: TANTANGAN & KUIS BUSANA INTERAKTIF
  // ===========================================================================
  Widget _buildQuizTab() {
    final quizzes = JavaneseClothingData.fashionQuizzes;
    final isFinished = _currentQuizIndex >= quizzes.length - 1 && _isAnswerSubmitted;
    final currentQuiz = quizzes[_currentQuizIndex];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, widget.isTab ? 100 : 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bar Skor & Kemajuan Kuis
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pertanyaan ${_currentQuizIndex + 1} dari ${quizzes.length}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF382315)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF382315),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB08D57), width: 0.8),
                ),
                child: Text(
                  'Skor: $_score Poin',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFFFDF9E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentQuizIndex + 1) / quizzes.length,
              backgroundColor: const Color(0xFFE8DED0),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFB08D57)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 20),

          // Kartu Pertanyaan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x33B08D57)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10382315),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentQuiz.category.toUpperCase(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFB08D57)),
                    ),
                    Text(
                      currentQuiz.javaneseScript,
                      style: const TextStyle(fontSize: 11, color: Color(0xFFB08D57)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  currentQuiz.question,
                  style: JText.serif(15.5, weight: FontWeight.w700, color: const Color(0xFF382315)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Opsi Pilihan Jawaban
          ...List.generate(currentQuiz.options.length, (i) {
            final optionText = currentQuiz.options[i];
            Color btnColor = const Color(0xFFFFFDF9);
            Color borderColor = const Color(0x33B08D57);
            Color textColor = const Color(0xFF382315);

            if (_isAnswerSubmitted) {
              if (i == currentQuiz.correctOptionIndex) {
                btnColor = const Color(0x223F6B3A);
                borderColor = const Color(0xFF3F6B3A);
                textColor = const Color(0xFF22551E);
              } else if (i == _selectedAnswerIndex) {
                btnColor = const Color(0x22B3261E);
                borderColor = const Color(0xFFB3261E);
                textColor = const Color(0xFF8A1E17);
              }
            } else if (i == _selectedAnswerIndex) {
              borderColor = const Color(0xFFB08D57);
              btnColor = const Color(0x1FB08D57);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _submitAnswer(i),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          String.fromCharCode(65 + i),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Kotak Ulasan Pembahasan Sejarah Setelah Menjawab
          if (_isAnswerSubmitted) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x44B08D57), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedAnswerIndex == currentQuiz.correctOptionIndex
                            ? Icons.check_circle_rounded
                            : Icons.info_rounded,
                        color: _selectedAnswerIndex == currentQuiz.correctOptionIndex
                            ? const Color(0xFF3F6B3A)
                            : const Color(0xFFB08D57),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedAnswerIndex == currentQuiz.correctOptionIndex
                            ? 'Benar Sekali!'
                            : 'Pembahasan Historis:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _selectedAnswerIndex == currentQuiz.correctOptionIndex
                              ? const Color(0xFF22551E)
                              : const Color(0xFF382315),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQuiz.historicalExplanation,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF4A3828), height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Lanjut atau Selesai
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF382315),
                  foregroundColor: const Color(0xFFFFDF9E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isFinished ? _resetQuiz : _nextQuiz,
                child: Text(
                  isFinished ? 'Ulangi Tantangan Kuis' : 'Pertanyaan Selanjutnya',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
