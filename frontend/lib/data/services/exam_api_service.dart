import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../models/exam_model.dart';
import '../models/quiz_model.dart';
import '../models/submit_result_model.dart';

class ExamApiService {
  final http.Client _client;

  ExamApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Lay danh sach de thi da xuat ban (No-Auth)
  Future<List<MobileExam>> getExams() async {
    final uri = Uri.parse(ApiConfig.examsUrl);
    final response = await _client.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
      return list.map((e) => MobileExam.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Không thể tải danh sách đề thi (Mã lỗi: ${response.statusCode})');
    }
  }

  /// Lay toan bo cau truc de thi de vao lam bai ngay (No-Auth)
  Future<QuizExam> getQuizExam(int examId) async {
    final uri = Uri.parse(ApiConfig.examStartUrl(examId));
    final response = await _client.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return QuizExam.fromJson(data);
    } else {
      throw Exception('Không thể tải nội dung đề thi #$examId (Mã lỗi: ${response.statusCode})');
    }
  }

  /// Nop bai cham diem (Ho tro nop som chi sau 1-2 cau)
  Future<SubmitResult> submitExam(int examId, SubmitAttempt attempt) async {
    final uri = Uri.parse(ApiConfig.examSubmitUrl(examId));
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(attempt.toJson()),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return SubmitResult.fromJson(data);
    } else {
      String errorMessage = 'Lỗi nộp bài (Mã lỗi: ${response.statusCode})';
      try {
        final errJson = jsonDecode(utf8.decode(response.bodyBytes));
        if (errJson['message'] != null) {
          errorMessage = errJson['message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
