import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import 'explore_data.dart';
import 'explore_models.dart';

/// Halaman Kuis Budaya Interaktif 10 Soal - Langsung dari Figma Page 2 ('fitur_belajar.png').
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<QuizQuestion> _questions = cultureQuizQuestions;
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _score = 0;
  bool _quizFinished = false;

  void _onSelectOption(int index) {
    if (_answered) return;
    HapticFeedback.selectionClick();

    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    HapticFeedback.lightImpact();
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      setState(() {
        _quizFinished = true;
      });
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOption = null;
      _answered = false;
      _score = 0;
      _quizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: JColors.cream,
        body: JBackground(
          child: SafeArea(
            child: _quizFinished ? _buildResultView() : _buildQuestionView(),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    final q = _questions[_currentIndex];
    final total = _questions.length;

    return Column(
      children: [
        // Top App Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: JColors.ink,
                tooltip: 'Keluar Kuis',
              ),
              Expanded(
                child: Text(
                  'Kuis Budaya',
                  textAlign: TextAlign.center,
                  style: JText.serif(
                    17,
                    weight: FontWeight.w600,
                    color: JColors.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9DAC7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1}/$total',
                  style: JText.serif(
                    13,
                    weight: FontWeight.w700,
                    color: JColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Linear Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / total,
              minHeight: 5,
              backgroundColor: const Color(0xFFE4D3BD),
              valueColor: const AlwaysStoppedAnimation<Color>(JColors.button),
            ),
          ),
        ),

        // Scrollable Question Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori Soal
                Text(
                  q.category,
                  style: JText.serif(
                    11.5,
                    weight: FontWeight.w700,
                    color: JColors.terracotta,
                  ),
                ),

                const SizedBox(height: 10),

                // Teks Pertanyaan (Besar & Tegas)
                Text(
                  q.question,
                  style: JText.serif(
                    21,
                    weight: FontWeight.w700,
                    color: JColors.ink,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 24),

                // 4 Opsi Pilihan Jawaban
                ...List.generate(q.options.length, (i) {
                  final optText = q.options[i];
                  final isSelected = _selectedOption == i;
                  final isCorrect = i == q.correctIndex;

                  Color bg = const Color(0xFFFFFDF9);
                  Color border = const Color(0xFFE5D5BF);
                  Color textColor = JColors.ink;
                  Widget? statusBadge;

                  if (_answered) {
                    if (isCorrect) {
                      bg = const Color(0xFFE8F5E9);
                      border = const Color(0xFF3F6B3A);
                      textColor = const Color(0xFF1E4620);
                      statusBadge = Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Benar',
                          style: JText.serif(
                            10.5,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      );
                    } else if (isSelected) {
                      bg = const Color(0xFFFFEBEE);
                      border = const Color(0xFFD32F2F);
                      textColor = const Color(0xFF7F1D1D);
                      statusBadge = Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC62828),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Kurang tepat',
                          style: JText.serif(
                            10.5,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _onSelectOption(i),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: border,
                            width: isSelected || (_answered && isCorrect)
                                ? 1.8
                                : 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A3A261D),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                optText,
                                style: JText.serif(
                                  15,
                                  weight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ),
                            ?statusBadge,
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 8),

                // Kotak "Tahukah kamu?" persis seperti di Figma Page 2
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _answered
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE3D2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDFCDAF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_rounded,
                              size: 16,
                              color: JColors.terracotta,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tahukah kamu?',
                              style: JText.serif(
                                13.5,
                                weight: FontWeight.w700,
                                color: JColors.ink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          q.explanation,
                          style: JText.serif(
                            13,
                            color: const Color(0xFF433023),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),

        // Bottom CTA Button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _answered ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: JColors.button,
                disabledBackgroundColor: const Color(0xFFCBB89F),
                foregroundColor: JColors.cream,
                disabledForegroundColor: const Color(0xFF7E6F5B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentIndex < total - 1
                    ? 'Pertanyaan berikutnya'
                    : 'Lihat Hasil',
                style: JText.serif(15, weight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    final total = _questions.length;
    final percentage = (_score / total * 100).round();
    final isGood = percentage >= 70;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Circle Skor persis di Figma
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFFDF9),
              border: Border.all(color: JColors.gold, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x183A261D),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$_score/$total',
                style: JText.serif(
                  34,
                  weight: FontWeight.w800,
                  color: JColors.button,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            isGood
                ? 'Penjelajah Budaya yang sigap!'
                : 'Tetap Semangat Belajar!',
            textAlign: TextAlign.center,
            style: JText.serif(23, weight: FontWeight.w700, color: JColors.ink),
          ),

          const SizedBox(height: 8),

          Text(
            'Kamu menjawab $_score dari $total soal dengan benar.',
            textAlign: TextAlign.center,
            style: JText.serif(14, color: JColors.muted),
          ),

          const SizedBox(height: 32),

          // Lencana Baru yang dibuka
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE6D6BF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C3A261D),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'LENCANA BARU TERBUKA',
                  style: JText.serif(
                    11.5,
                    weight: FontWeight.w700,
                    color: JColors.terracotta,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: JColors.gold.withValues(alpha: 0.18),
                  ),
                  child: const Icon(
                    Icons.military_tech_rounded,
                    size: 42,
                    color: JColors.gold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isGood ? 'Sahabat Dalang' : 'Pelajar Budaya Muda',
                  style: JText.serif(
                    17,
                    weight: FontWeight.w700,
                    color: JColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${_score * 15} XP Budaya ditambahkan ke akun Anda',
                  style: JText.serif(
                    12.5,
                    color: JColors.success,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Tombol Tindakan
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _resetQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: JColors.button,
                foregroundColor: JColors.cream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Ulangi Kuis',
                style: JText.serif(14.5, weight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: JColors.button, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Kembali Belajar',
                style: JText.serif(
                  14.5,
                  weight: FontWeight.w600,
                  color: JColors.button,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
