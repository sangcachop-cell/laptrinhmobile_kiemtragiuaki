import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../data/models/quiz_model.dart';
import '../data/models/submit_result_model.dart';
import '../data/services/exam_api_service.dart';
import 'exam_result_screen.dart';

class ExamRoomScreen extends StatefulWidget {
  final int examId;
  final String examTitle;

  const ExamRoomScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<ExamRoomScreen> createState() => _ExamRoomScreenState();
}

class _ExamRoomScreenState extends State<ExamRoomScreen> {
  final ExamApiService _apiService = ExamApiService();

  bool _isLoading = true;
  String? _errorMessage;
  QuizExam? _quizExam;

  // Flattened question list for linear navigation
  List<QuizQuestion> _allQuestions = [];
  // Map questionId -> passage (if Part 6 or Part 7)
  final Map<int, QuizPassageGroup> _questionPassageMap = {};

  int _currentIndex = 0;
  // Map questionId -> selectedOptionId
  final Map<int, int?> _selectedAnswers = {};

  // Countdown timer
  Timer? _countdownTimer;
  int _remainingSeconds = 75 * 60;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExamQuiz();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadExamQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final quiz = await _apiService.getQuizExam(widget.examId);
      _quizExam = quiz;
      _allQuestions = quiz.allQuestions;

      // Populate passage map
      for (final p in quiz.part6Groups) {
        for (final q in p.questions) {
          _questionPassageMap[q.id] = p;
        }
      }
      for (final p in quiz.part7Groups) {
        for (final q in p.questions) {
          _questionPassageMap[q.id] = p;
        }
      }

      _remainingSeconds = quiz.durationMinutes * 60;
      _startTimer();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _handleTimeUp();
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  Color _getTimerColor() {
    if (_remainingSeconds <= 60) {
      // Blinking red effect (every second)
      return (_remainingSeconds % 2 == 0) ? Colors.red : Colors.white;
    } else if (_remainingSeconds <= 300) {
      return Colors.orangeAccent;
    }
    return Colors.white;
  }

  void _handleTimeUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.alarm_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Hết giờ làm bài!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Thời gian thi 75 phút đã kết thúc. Hệ thống đang tự động thu bài và chấm điểm...',
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // close dialog
        _performSubmit();
      }
    });
  }

  int get _answeredCount {
    return _selectedAnswers.values.where((id) => id != null).length;
  }

  void _onOptionSelected(int questionId, int optionId) {
    setState(() {
      if (_selectedAnswers[questionId] == optionId) {
        // Tap again on the selected option -> unselect (toggle off)
        _selectedAnswers[questionId] = null;
      } else {
        _selectedAnswers[questionId] = optionId;
      }
    });
  }

  void _confirmSubmit() {
    final answered = _answeredCount;
    final total = _allQuestions.length;

    // Rule 2: Minimum 1-2 questions to submit early
    if (answered == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text('Bạn vui lòng làm tối thiểu 1 - 2 câu trước khi nộp bài nhé!'),
              ),
            ],
          ),
          backgroundColor: Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final unAnswered = total - answered;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.assignment_turned_in, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Xác nhận nộp bài', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
            children: [
              const TextSpan(text: 'Bạn đã hoàn thành '),
              TextSpan(
                text: '$answered',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
              const TextSpan(text: ' câu hỏi'),
              if (unAnswered > 0) ...[
                const TextSpan(text: ' (còn '),
                TextSpan(
                  text: '$unAnswered',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                ),
                const TextSpan(text: ' câu chưa làm)'),
              ],
              const TextSpan(text: '.\n\nBạn có chắc chắn muốn nộp bài và chấm điểm ngay không?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tiếp tục làm'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _performSubmit();
            },
            child: const Text('Nộp bài tính điểm'),
          ),
        ],
      ),
    );
  }

  Future<void> _performSubmit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final quiz = _quizExam!;
      final totalSecondsSpent = (quiz.durationMinutes * 60) - _remainingSeconds;

      final answers = _selectedAnswers.entries.map((e) {
        return UserAnswer(
          questionId: e.key,
          selectedOptionId: e.value,
        );
      }).toList();

      final attempt = SubmitAttempt(
        deviceIdentifier: 'flutter-client-guest',
        durationSeconds: totalSecondsSpent < 0 ? 0 : totalSecondsSpent,
        answers: answers,
      );

      final result = await _apiService.submitExam(widget.examId, attempt);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExamResultScreen(
              examId: widget.examId,
              examTitle: widget.examTitle,
              result: result,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể nộp bài: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showQuestionPalette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bảng Câu Hỏi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusLegend(const Color(0xFF10B981), 'Đã làm'),
                      const SizedBox(width: 14),
                      _buildStatusLegend(const Color(0xFFCBD5E1), 'Chưa làm'),
                      const SizedBox(width: 14),
                      _buildStatusLegend(AppTheme.primary, 'Đang xem', hasBorder: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      itemCount: _allQuestions.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, idx) {
                        final q = _allQuestions[idx];
                        final isAnswered = _selectedAnswers[q.id] != null;
                        final isCurrent = idx == _currentIndex;

                        Color bgColor;
                        Color textColor;
                        if (isAnswered) {
                          bgColor = const Color(0xFF10B981);
                          textColor = Colors.white;
                        } else {
                          bgColor = const Color(0xFFF1F5F9);
                          textColor = const Color(0xFF475569);
                        }

                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            setState(() {
                              _currentIndex = idx;
                            });
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10),
                              border: isCurrent
                                  ? Border.all(color: AppTheme.primary, width: 2.5)
                                  : null,
                            ),
                            child: Text(
                              '${q.questionNumber}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusLegend(Color color, String label, {bool hasBorder = false}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: hasBorder ? Colors.white : color,
            borderRadius: BorderRadius.circular(4),
            border: hasBorder ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.examTitle)),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải cấu trúc đề thi...', style: TextStyle(color: AppTheme.textMuted)),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null || _allQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.examTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 54, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'Không tìm thấy câu hỏi trong đề thi.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadExamQuiz,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = _allQuestions[_currentIndex];
    final currentPassage = _questionPassageMap[currentQuestion.id];
    final isPart6or7 = currentQuestion.partNumber == 6 || currentQuestion.partNumber == 7;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.examTitle,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Timer Widget
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, size: 16, color: _getTimerColor()),
                const SizedBox(width: 4),
                Text(
                  _formatTimer(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _getTimerColor(),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Submit Button
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _answeredCount >= 1 ? Colors.amber : Colors.white24,
                foregroundColor: _answeredCount >= 1 ? const Color(0xFF78350F) : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _isSubmitting ? null : _confirmSubmit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Nộp bài',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Subheader: Part info & progress counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Part ${currentQuestion.partNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Câu ${_currentIndex + 1}/${_allQuestions.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Đã làm: $_answeredCount/${_allQuestions.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _answeredCount > 0 ? const Color(0xFF10B981) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Question Body (Split View if Part 6/7, Single Card if Part 5)
          Expanded(
            child: isPart6or7 && currentPassage != null
                ? _buildSplitPassageView(currentPassage, currentQuestion)
                : _buildSingleQuestionView(currentQuestion),
          ),

          // Bottom Bar Navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  /// Single Question View for Part 5
  Widget _buildSingleQuestionView(QuizQuestion q) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionHeaderCard(q),
          const SizedBox(height: 16),
          _buildOptionsList(q),
        ],
      ),
    );
  }

  /// Split View for Part 6 & Part 7 (Passage 45% Top, Questions 55% Bottom)
  Widget _buildSplitPassageView(QuizPassageGroup passage, QuizQuestion currentQ) {
    return Column(
      children: [
        // Top 45%: Passage content
        Expanded(
          flex: 45,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Bài đọc Part ${passage.partNumber} (Câu ${passage.questions.first.questionNumber} - ${passage.questions.last.questionNumber})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildPassageContent(passage),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom 55%: Current Question & Options
        Expanded(
          flex: 55,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionHeaderCard(currentQ),
                  const SizedBox(height: 12),
                  _buildOptionsList(currentQ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassageContent(QuizPassageGroup passage) {
    final rawHtml = passage.contentHtml ?? '';
    // Format text and highlight blanks like [131], [132], [147]
    final cleanText = rawHtml
        .replaceAll(RegExp(r'<p[^>]*>'), '\n\n')
        .replaceAll('</p>', '')
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br />', '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (passage.imageUrl != null && passage.imageUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              passage.imageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 10),
        ],
        _buildFormattedPassageText(cleanText),
      ],
    );
  }

  Widget _buildFormattedPassageText(String text) {
    // Regex matching [131], [132], etc.
    final regex = RegExp(r'(\[\d{3}\])');
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF1E293B)),
      );
    }

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(
            color: Color(0xFF1E40AF),
            fontWeight: FontWeight.bold,
            backgroundColor: Color(0xFFDBEAFE),
          ),
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF1E293B)),
        children: spans,
      ),
    );
  }

  Widget _buildQuestionHeaderCard(QuizQuestion q) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu ${q.questionNumber}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              if (_selectedAnswers[q.id] != null)
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedAnswers[q.id] = null;
                    });
                  },
                  child: const Text('Bỏ chọn', style: TextStyle(fontSize: 12, color: Colors.red)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            q.questionText ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F172A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList(QuizQuestion q) {
    final selectedId = _selectedAnswers[q.id];

    return Column(
      children: q.options.map((opt) {
        final isSelected = opt.id == selectedId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onOptionSelected(q.id, opt.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppTheme.primary : const Color(0xFFF1F5F9),
                      ),
                      child: Text(
                        opt.optionLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt.optionText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _currentIndex > 0
                  ? () => setState(() => _currentIndex--)
                  : null,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Câu trước'),
            ),

            // Palette Grid Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF1E293B),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _showQuestionPalette,
              icon: const Icon(Icons.grid_view_rounded, size: 16, color: AppTheme.primary),
              label: const Text('Bảng câu hỏi'),
            ),

            // Next / Finish Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _currentIndex < _allQuestions.length - 1
                  ? () => setState(() => _currentIndex++)
                  : _confirmSubmit,
              label: Text(_currentIndex < _allQuestions.length - 1 ? 'Câu tiếp' : 'Nộp bài'),
              icon: Icon(
                _currentIndex < _allQuestions.length - 1 ? Icons.arrow_forward : Icons.check,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
