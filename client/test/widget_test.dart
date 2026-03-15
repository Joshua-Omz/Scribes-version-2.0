import 'package:flutter_test/flutter_test.dart';
import 'package:scribes/main.dart';

void main() {
  testWidgets('Scribes app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ScribesApp());
    expect(find.text('Scribes'), findsOneWidget);
  });
}
