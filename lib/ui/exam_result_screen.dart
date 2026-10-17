import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../data/models/submit_result_model.dart';
import 'exam_room_screen.dart';

class ExamResultScreen extends StatefulWidget {
  final int examId;
  final String examTitle;
  final SubmitResult result;

  const ExamResultScreen({
    super.key,
    required this.examId,
    required this.examTitle,
    required this.result,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  String _activeFilter = 'ALL'; // ALL, ANSWERED, CORRECT, WRONG, SKIPPED

  List<QuestionReview> get _filteredDetails {
    switch (_activeFilter) {
      case 'ANSWERED':
        return widget.result.details.where((d) => d.selectedOptionId != null).toList();
      case 'CORRECT':
        return widget.result.details.where((d) => d.isCorrect).toList();
      case 'WRONG':
        return widget.result.details.where((d) => d.selectedOptionId != null && !d.isCorrect).toList();
      case 'SKIPPED':
        return widget.result.details.where((d) => d.selectedOptionId == null).toList();
      default:
        return widget.result.details;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Kết Quả Thi & Giải Thích Chi Tiết'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Về danh sách đề',
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Score Overview Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  widget.examTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      result.score.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      ' / 10',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Điểm TOEIC Reading: ${result.toeicReadingScore} / 495',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF78350F),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Đã làm ${result.answeredCount} / ${result.totalQuestions} câu',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3 Metric Badges
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  icon: Icons.check_circle_rounded,
                  label: 'Câu Đúng',
                  count: result.correctCount,
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFFD1FAE5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricBox(
                  icon: Icons.cancel_rounded,
                  label: 'Câu Sai',
                  count: result.wrongCount,
                  color: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFEE2E2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricBox(
                  icon: Icons.remove_circle_outline_rounded,
                  label: 'Bỏ Qua',
                  count: result.skippedCount,
                  color: const Color(0xFF64748B),
                  bgColor: const Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Review Mode Title & Filters
          const Text(
            'Rà soát & Lời giải chi tiết (Hint)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả (${result.details.length})', 'ALL'),
                const SizedBox(width: 8),
                _buildFilterChip('Đã làm (${result.answeredCount})', 'ANSWERED'),
                const SizedBox(width: 8),
                _buildFilterChip('Đúng (${result.correctCount})', 'CORRECT'),
                const SizedBox(width: 8),
                _buildFilterChip('Sai (${result.wrongCount})', 'WRONG'),
                const SizedBox(width: 8),
                _buildFilterChip('Bỏ qua (${result.skippedCount})', 'SKIPPED'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Questions List
          ..._filteredDetails.map((q) => _buildQuestionReviewCard(q)),

          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExamRoomScreen(
                          examId: widget.examId,
                          examTitle: widget.examTitle,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh, color: AppTheme.primary),
                  label: const Text(
                    'Làm lại đề này',
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.list_alt),
                  label: const Text(
                    'Danh sách đề',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMetricBox({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterKey) {
    final isSelected = _activeFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : const Color(0xFF334155),
      ),
      onSelected: (val) {
        if (val) setState(() => _activeFilter = filterKey);
      },
    );
  }

  Widget _buildQuestionReviewCard(QuestionReview q) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (q.selectedOptionId == null) {
      statusColor = const Color(0xFF64748B);
      statusText = 'Bỏ qua';
      statusIcon = Icons.remove_circle_outline;
    } else if (q.isCorrect) {
      statusColor = const Color(0xFF10B981);
      statusText = 'Chính xác';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = const Color(0xFFEF4444);
      statusText = 'Chưa đúng';
      statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Part + Question Number + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '[Part ${q.partNumber}] Câu ${q.questionNumber}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Question Text
          Text(
            q.questionText ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Options List
          ...q.options.map((opt) {
            final isUserChoice = opt.id == q.selectedOptionId;
            final isCorrect = opt.isCorrect;

            Color borderColor = const Color(0xFFE2E8F0);
            Color bgColor = Colors.white;
            Color textColor = const Color(0xFF334155);
            Widget? trailingIcon;

            if (isCorrect) {
              borderColor = const Color(0xFF10B981);
              bgColor = const Color(0xFFD1FAE5);
              textColor = const Color(0xFF065F46);
              trailingIcon = const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18);
            } else if (isUserChoice && !isCorrect) {
              borderColor = const Color(0xFFEF4444);
              bgColor = const Color(0xFFFEE2E2);
              textColor = const Color(0xFF991B1B);
              trailingIcon = const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 18);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: isCorrect || isUserChoice ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrect
                          ? const Color(0xFF10B981)
                          : (isUserChoice ? const Color(0xFFEF4444) : const Color(0xFFF1F5F9)),
                    ),
                    child: Text(
                      opt.optionLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCorrect || isUserChoice ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      opt.optionText,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor,
                        fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  ?trailingIcon,
                ],
              ),
            );
          }),

          // Hint / Explanation Section
          if (q.hint != null && q.hint!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giải thích chi tiết (Hint):',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          q.hint!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF78350F),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
