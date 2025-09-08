import 'package:flutter_test/flutter_test.dart';
import 'package:kindergarten_frontend/main.dart';

void main() {
  testWidgets('App boots and shows dashboard tab', (tester) async {
    await tester.pumpWidget(const KindergartenApp());
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
