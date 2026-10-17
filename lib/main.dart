import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'ui/exam_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ToeicExamApp());
}

class ToeicExamApp extends StatelessWidget {
  const ToeicExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luyện Thi TOEIC Reading',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // No-Auth Entry: Vao thang danh sach de thi va thi ngay, khong man hinh login
      home: const ExamListScreen(),
    );
  }
}
