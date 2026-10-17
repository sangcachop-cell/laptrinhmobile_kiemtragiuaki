class QuizExam {
  final int id;
  final String title;
  final int durationMinutes;
  final int totalQuestions;
  final List<QuizQuestion> part5Questions;
  final List<QuizPassageGroup> part6Groups;
  final List<QuizPassageGroup> part7Groups;

  QuizExam({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.part5Questions,
    required this.part6Groups,
    required this.part7Groups,
  });

  /// Flatten all questions across Part 5, Part 6, Part 7 in order
  List<QuizQuestion> get allQuestions {
    final list = <QuizQuestion>[];
    list.addAll(part5Questions);
    for (final group in part6Groups) {
      list.addAll(group.questions);
    }
    for (final group in part7Groups) {
      list.addAll(group.questions);
    }
    list.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));
    return list;
  }

  factory QuizExam.fromJson(Map<String, dynamic> json) {
    return QuizExam(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 75,
      totalQuestions: json['totalQuestions'] as int? ?? 100,
      part5Questions: (json['part5Questions'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      part6Groups: (json['part6Groups'] as List<dynamic>? ?? [])
          .map((e) => QuizPassageGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      part7Groups: (json['part7Groups'] as List<dynamic>? ?? [])
          .map((e) => QuizPassageGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizPassageGroup {
  final int passageId;
  final int partNumber;
  final String? contentHtml;
  final String? imageUrl;
  final List<QuizQuestion> questions;

  QuizPassageGroup({
    required this.passageId,
    required this.partNumber,
    this.contentHtml,
    this.imageUrl,
    required this.questions,
  });

  factory QuizPassageGroup.fromJson(Map<String, dynamic> json) {
    return QuizPassageGroup(
      passageId: json['passageId'] as int? ?? 0,
      partNumber: json['partNumber'] as int? ?? 6,
      contentHtml: json['contentHtml'] as String?,
      imageUrl: json['imageUrl'] as String?,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizQuestion {
  final int id;
  final int partNumber;
  final int questionNumber;
  final String? questionText;
  final List<QuizOption> options;

  QuizQuestion({
    required this.id,
    required this.partNumber,
    required this.questionNumber,
    this.questionText,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int? ?? 0,
      partNumber: json['partNumber'] as int? ?? 5,
      questionNumber: json['questionNumber'] as int? ?? 0,
      questionText: json['questionText'] as String?,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => QuizOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizOption {
  final int id;
  final String optionLabel; // 'A', 'B', 'C', 'D'
  final String optionText;

  QuizOption({
    required this.id,
    required this.optionLabel,
    required this.optionText,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'] as int? ?? 0,
      optionLabel: json['optionLabel'] as String? ?? '',
      optionText: json['optionText'] as String? ?? '',
    );
  }
}
