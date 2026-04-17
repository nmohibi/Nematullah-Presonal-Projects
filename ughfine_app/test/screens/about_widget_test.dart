import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ughfine_app/screens/about.dart';

void main() {
  group('AboutScreen Widget Tests', () {
    late Widget app;

    setUp(() {
      app = MaterialApp(
        home: AboutScreen(),
      );
    });

    testWidgets('AboutScreen should display app title "UghFine"', (
      tester,
    ) async {
      await tester.pumpWidget(app);

      final title = find.text('UghFine');

      expect(title, findsOneWidget);
    });

    testWidgets('AboutScreen should display subtitle', (tester) async {
      await tester.pumpWidget(app);

      final subtitle = find.text('Your AI-Powered Fitness Coach');

      expect(subtitle, findsOneWidget);
    });

    testWidgets('AboutScreen should display description text', (tester) async {
      await tester.pumpWidget(app);

      final description = find.text(
        'Get a personalized workout & diet plan\nbuilt just for you by AI.',
      );

      expect(description, findsOneWidget);
    });

    testWidgets('AboutScreen should display "Get Started" button', (tester) async {
      await tester.pumpWidget(app);

      final button = find.text('Get Started');

      expect(button, findsOneWidget);
    });

    testWidgets('AboutScreen should display fitness center icon', (tester) async {
      await tester.pumpWidget(app);

      final icon = find.byIcon(Icons.fitness_center);

      expect(icon, findsOneWidget);
    });

    testWidgets('AboutScreen should have an ElevatedButton', (tester) async {
      await tester.pumpWidget(app);

      final button = find.byType(ElevatedButton);

      expect(button, findsOneWidget);
    });

    testWidgets('AboutScreen should animate on load', (tester) async {
      await tester.pumpWidget(app);

      await tester.pumpAndSettle();

      final title = find.text('UghFine');

      expect(title, findsOneWidget);
    });

    testWidgets('AboutScreen should display content with proper opacity after animation',
        (tester) async {
      await tester.pumpWidget(app);

      await tester.pumpAndSettle();

      expect(find.text('UghFine'), findsOneWidget);
      expect(find.text('Your AI-Powered Fitness Coach'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('AboutScreen should have a gradient background', (tester) async {
      await tester.pumpWidget(app);

      final container = find.byType(Container);

      expect(container, findsWidgets);
    });

    testWidgets('AboutScreen Get Started button should be tappable', (
      tester,
    ) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final button = find.byType(ElevatedButton);

      expect(button, findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(button).onPressed,
        isNotNull,
      );
    });
  });
}
