import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ughfine_app/providers/user_provider.dart';
import 'package:ughfine_app/screens/login.dart';

class MockUserProvider extends Mock implements UserProvider {}

void main() {
  group('LoginScreen Widget Tests', () {
    late Widget app;
    late MockUserProvider mockUserProvider;

    setUp(() {
      mockUserProvider = MockUserProvider();

      when(mockUserProvider.isLoading).thenReturn(false);
      when(mockUserProvider.errorMessage).thenReturn(null);
      when(mockUserProvider.hasCompletedOnboarding).thenReturn(false);

      app = MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: LoginScreen(),
        ),
      );
    });

    testWidgets('LoginScreen should display "UghFine" title in AppBar', (
      tester,
    ) async {
      await tester.pumpWidget(app);

      final title = find.text('UghFine');

      expect(title, findsOneWidget);
    });

    testWidgets('LoginScreen should display Login and Register tabs', (
      tester,
    ) async {
      await tester.pumpWidget(app);

      final loginTab = find.text('Login');
      final registerTab = find.text('Register');

      expect(loginTab, findsOneWidget);
      expect(registerTab, findsOneWidget);
    });

    testWidgets('LoginScreen should have email input field', (tester) async {
      await tester.pumpWidget(app);

      final emailField = find.byType(TextFormField);

      expect(emailField, findsWidgets);
    });

    testWidgets('LoginScreen should have password input field', (tester) async {
      await tester.pumpWidget(app);

      final passwordFields = find.byType(TextFormField);

      expect(passwordFields, findsWidgets);
    });

    testWidgets('LoginScreen should have a Continue button', (tester) async {
      await tester.pumpWidget(app);

      final continueButton = find.byType(ElevatedButton);

      expect(continueButton, findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('LoginScreen should initially show Login tab', (tester) async {
      await tester.pumpWidget(app);

      final continueButton = find.byType(ElevatedButton);

      expect(continueButton, findsOneWidget);
    });

    testWidgets('LoginScreen should switch to Register tab when tapped', (
      tester,
    ) async {
      await tester.pumpWidget(app);

      final registerTab = find.text('Register');
      await tester.tap(registerTab);
      await tester.pumpAndSettle();

      final continueButton = find.byType(ElevatedButton);
      expect(continueButton, findsOneWidget);
    });

    testWidgets('LoginScreen should show error message when provided', (
      tester,
    ) async {
      when(mockUserProvider.errorMessage)
          .thenReturn('Invalid email or password');
      when(mockUserProvider.isLoading).thenReturn(false);

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final errorMessage = find.text('Invalid email or password');

      expect(errorMessage, findsOneWidget);
    });

    testWidgets('LoginScreen should show loading spinner when isLoading is true',
        (tester) async {
      when(mockUserProvider.isLoading).thenReturn(true);
      when(mockUserProvider.errorMessage).thenReturn(null);

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final spinner = find.byType(CircularProgressIndicator);

      expect(spinner, findsOneWidget);
    });

    testWidgets('LoginScreen Continue button should be disabled when loading', (
      tester,
    ) async {
      when(mockUserProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final button = find.byType(ElevatedButton);
      final buttonWidget = tester.widget<ElevatedButton>(button);

      expect(buttonWidget.onPressed, isNull);
    });

    testWidgets('LoginScreen email field should accept text input', (
      tester,
    ) async {
      await tester.pumpWidget(app);

      final emailFields = find.byType(TextFormField);
      await tester.enterText(emailFields.first, 'test@example.com');

      expect(
        find.text('test@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('LoginScreen should have Form widget for validation', (
      tester,
    ) async {
      await tester.pumpWidget(app);

      final form = find.byType(Form);

      expect(form, findsOneWidget);
    });
  });
}
