import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {
  static String? customBaseUrl;

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://localhost:5283';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5283';
      }
    } catch (_) {}
    return 'http://localhost:5283';
  }

  static String get examsUrl => '$baseUrl/api/mobile/exams';
  static String examStartUrl(int id) => '$baseUrl/api/mobile/exams/$id/start';
  static String examSubmitUrl(int id) => '$baseUrl/api/mobile/exams/$id/submit';
}
