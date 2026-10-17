class MobileExam {
  final int id;
  final String title;
  final int durationMinutes;
  final int totalQuestions;
  final int attemptCount;

  MobileExam({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.attemptCount,
  });

  factory MobileExam.fromJson(Map<String, dynamic> json) {
    return MobileExam(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 75,
      totalQuestions: json['totalQuestions'] as int? ?? 100,
      attemptCount: json['attemptCount'] as int? ?? 0,
    );
  }
}
