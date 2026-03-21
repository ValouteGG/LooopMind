import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loopmind/main.dart';

void main() {
  testWidgets('LoopMindApp renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const LoopMindApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
