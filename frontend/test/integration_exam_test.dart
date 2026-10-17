import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/api_config.dart';
import 'package:flutter_application_1/data/models/submit_result_model.dart';
import 'package:flutter_application_1/data/services/exam_api_service.dart';

void main() {
  test('E2E Test: No-Auth exam list -> Start Quiz -> Early Submit 2 questions -> Verify Score & Hint', () async {
    ApiConfig.customBaseUrl = 'http://localhost:5283';
    final apiService = ExamApiService();

    // Step 1: No-Auth get published exams
    final exams = await apiService.getExams();
    expect(exams.isNotEmpty, isTrue, reason: 'Phải có đề thi đã xuất bản sẵn sàng');
    final exam = exams.firstWhere((e) => e.title.contains('EnglishTest'));
    expect(exam.totalQuestions, equals(34));

    // Step 2: Start exam (No-Auth)
    final quiz = await apiService.getQuizExam(exam.id);
    expect(quiz.part5Questions.length, equals(30));
    expect(quiz.part6Groups.length, equals(1));
    expect(quiz.allQuestions.length, equals(34));

    // Identify question 101 and 102
    final q101 = quiz.allQuestions.firstWhere((q) => q.questionNumber == 101);
    final q102 = quiz.allQuestions.firstWhere((q) => q.questionNumber == 102);

    // Question 101 correct answer is 'her' (Option B)
    final opt101B = q101.options.firstWhere((o) => o.optionLabel == 'B');
    // Question 102 correct answer is 'knowledge' (Option C)
    final opt102C = q102.options.firstWhere((o) => o.optionLabel == 'C');

    // Step 3: Early Submission with only 2 answered questions out of 34
    final attempt = SubmitAttempt(
      deviceIdentifier: 'flutter-e2e-test-device',
      durationSeconds: 45,
      answers: [
        UserAnswer(questionId: q101.id, selectedOptionId: opt101B.id),
        UserAnswer(questionId: q102.id, selectedOptionId: opt102C.id),
      ],
    );

    final result = await apiService.submitExam(exam.id, attempt);

    // Step 4: Verify Scoring & Early Submission details
    expect(result.answeredCount, equals(2));
    expect(result.correctCount, equals(2));
    expect(result.wrongCount, equals(0));
    expect(result.skippedCount, equals(32));
    expect(result.totalQuestions, equals(34));
    expect(result.toeicReadingScore, equals(10)); // 2 correct * 5 = 10 TOEIC pts

    // Verify Hint explanations are provided
    final review101 = result.details.firstWhere((d) => d.questionNumber == 101);
    expect(review101.isCorrect, isTrue);
    expect(review101.hint, isNotNull);
    expect(review101.hint, contains('her'));

    final review102 = result.details.firstWhere((d) => d.questionNumber == 102);
    expect(review102.isCorrect, isTrue);
    expect(review102.hint, isNotNull);
    expect(review102.hint, contains('knowledge'));

    print('E2E TEST SUCCESS: Answered 2/34, Correct: 2, Skipped: 32, Score: ${result.score}/10, TOEIC: ${result.toeicReadingScore}/495');
  });
}
