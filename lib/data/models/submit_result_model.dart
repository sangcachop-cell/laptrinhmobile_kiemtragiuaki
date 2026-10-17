class SubmitAttempt {
  final String deviceIdentifier;
  final int durationSeconds;
  final List<UserAnswer> answers;

  SubmitAttempt({
    required this.deviceIdentifier,
    required this.durationSeconds,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceIdentifier': deviceIdentifier,
      'durationSeconds': durationSeconds,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

class UserAnswer {
  final int questionId;
  final int? selectedOptionId;

  UserAnswer({
    required this.questionId,
    this.selectedOptionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOptionId': selectedOptionId,
    };
  }
}

class SubmitResult {
  final int attemptId;
  final double score;
  final int toeicReadingScore;
  final int totalQuestions;
  final int answeredCount;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final List<QuestionReview> details;

  SubmitResult({
    required this.attemptId,
    required this.score,
    required this.toeicReadingScore,
    required this.totalQuestions,
    required this.answeredCount,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.details,
  });

  factory SubmitResult.fromJson(Map<String, dynamic> json) {
    return SubmitResult(
      attemptId: json['attemptId'] as int? ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      toeicReadingScore: json['toeicReadingScore'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      answeredCount: json['answeredCount'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      wrongCount: json['wrongCount'] as int? ?? 0,
      skippedCount: json['skippedCount'] as int? ?? 0,
      details: (json['details'] as List<dynamic>? ?? [])
          .map((e) => QuestionReview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuestionReview {
  final int questionId;
  final int questionNumber;
  final int partNumber;
  final String? questionText;
  final int? selectedOptionId;
  final String? selectedLabel;
  final int correctOptionId;
  final String correctLabel;
  final bool isCorrect;
  final String? hint;
  final List<OptionReview> options;

  QuestionReview({
    required this.questionId,
    required this.questionNumber,
    required this.partNumber,
    this.questionText,
    this.selectedOptionId,
    this.selectedLabel,
    required this.correctOptionId,
    required this.correctLabel,
    required this.isCorrect,
    this.hint,
    required this.options,
  });

  factory QuestionReview.fromJson(Map<String, dynamic> json) {
    return QuestionReview(
      questionId: json['questionId'] as int? ?? 0,
      questionNumber: json['questionNumber'] as int? ?? 0,
      partNumber: json['partNumber'] as int? ?? 5,
      questionText: json['questionText'] as String?,
      selectedOptionId: json['selectedOptionId'] as int?,
      selectedLabel: json['selectedLabel'] as String?,
      correctOptionId: json['correctOptionId'] as int? ?? 0,
      correctLabel: json['correctLabel'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      hint: json['hint'] as String?,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => OptionReview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OptionReview {
  final int id;
  final String optionLabel;
  final String optionText;
  final bool isCorrect;

  OptionReview({
    required this.id,
    required this.optionLabel,
    required this.optionText,
    required this.isCorrect,
  });

  factory OptionReview.fromJson(Map<String, dynamic> json) {
    return OptionReview(
      id: json['id'] as int? ?? 0,
      optionLabel: json['optionLabel'] as String? ?? '',
      optionText: json['optionText'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }
}
