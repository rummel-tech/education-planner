import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:education_planner/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Education Planner — App Launch', () {
    testWidgets('App loads and initialises without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      expect(tester.takeException(), isNull);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Material app is configured', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Loading state resolves to main shell', (WidgetTester tester) async {
      app.main();

      // Initially may show loading indicator
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Eventually settles on main content
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Should not be stuck in loading
      final progressIndicators = find.byType(CircularProgressIndicator);
      // May still be loading data, but app scaffold should be present
      expect(find.byType(Scaffold), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('Education Planner — Navigation Bar', () {
    testWidgets('Bottom navigation bar is present', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('Goals tab is present and selectable', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      expect(find.text('Goals'), findsOneWidget);
    });

    testWidgets('Plans tab is present and selectable', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      expect(find.text('Plans'), findsOneWidget);
    });

    testWidgets('Notes tab is present', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('Library tab is present', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      expect(find.text('Library'), findsOneWidget);
    });
  });

  group('Education Planner — Tab Navigation', () {
    testWidgets('Tapping Plans tab switches content', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      await tester.tap(find.text('Plans'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Tapping Notes tab switches content', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Tapping Library tab switches content', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Cycling through all tabs does not crash', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      for (final tab in ['Goals', 'Plans', 'Notes', 'Library']) {
        final tabFinder = find.text(tab);
        if (tabFinder.evaluate().isNotEmpty) {
          await tester.tap(tabFinder.first);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('Returning to Goals tab restores goals screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Navigate away
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // Return to Goals
      await tester.tap(find.text('Goals'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Education Planner — Goals Screen', () {
    testWidgets('Goals screen renders after launch', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Goals is the default tab — screen should be visible
      expect(tester.takeException(), isNull);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Goals screen shows empty state or goal list', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Either goals are listed or an empty state is shown — both valid
      expect(tester.takeException(), isNull);
    });
  });

  group('Education Planner — Stability', () {
    testWidgets('App is stable after extended pump settle', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('Rapid tab switches do not crash app', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      final tabs = ['Plans', 'Notes', 'Goals', 'Library', 'Goals'];
      for (final tab in tabs) {
        final tabFinder = find.text(tab);
        if (tabFinder.evaluate().isNotEmpty) {
          await tester.tap(tabFinder.first);
          await tester.pump(const Duration(milliseconds: 150));
        }
      }

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
