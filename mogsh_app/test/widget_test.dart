import 'package:flutter_test/flutter_test.dart';
import 'package:mogsh/main.dart';

void main() {
  testWidgets('App smoke test — MogshApp renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MogshApp());
    // Just verify it doesn't throw on startup
  });
}
