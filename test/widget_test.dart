import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:education_planner/src/ui/app.dart';

void main() {
  group('EducationPlannerApp', () {
    testWidgets('renders MaterialApp', (tester) async {
      await tester.pumpWidget(const EducationPlannerApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('has correct title', (tester) async {
      await tester.pumpWidget(const EducationPlannerApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.title, 'Education Planner');
    });

    testWidgets('debug banner is off', (tester) async {
      await tester.pumpWidget(const EducationPlannerApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(const EducationPlannerApp());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpWidget(const EducationPlannerApp());
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });
  });
}
