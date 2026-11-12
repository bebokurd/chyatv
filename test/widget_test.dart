import 'package:flutter_test/flutter_test.dart';
import 'package:netflix_kurdish/main.dart';

void main() {
  testWidgets('Netflix Kurd smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NetflixKurdApp());
    expect(find.byType(NetflixKurdApp), findsOneWidget);
  });
}
