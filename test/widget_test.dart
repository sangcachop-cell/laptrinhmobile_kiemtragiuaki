import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('TOEIC App loads ExamListScreen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ToeicExamApp());

    // Verify that the title of the exam screen is shown
    expect(find.text('Luyện Thi TOEIC Reading'), findsOneWidget);
  });
}
