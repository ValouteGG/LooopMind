import 'package:flutter_test/flutter_test.dart';
import 'package:phonebook_app/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // build our app and trigger a frame.
    await tester.pumpWidget(const LoopMindApp());

    // verify that the app loads.
    await tester.pump();
  });
}
