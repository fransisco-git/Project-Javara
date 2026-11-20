import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_app/main.dart';

void main() {
  testWidgets('App starts without crash smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const JavaraApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(JavaraApp), findsOneWidget);
  });
}
