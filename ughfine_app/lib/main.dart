// Route protection with onGenerateRoute: https://docs.flutter.dev/ui/navigation#using-named-routes
// Provider setup: https://pub.dev/packages/provider#getting-started
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/diet_provider.dart';
import 'screens/about.dart';
import 'screens/login.dart';

import 'screens/dashboard.dart';
import 'screens/workout.dart';
import 'screens/diet.dart';
import 'screens/questions.dart';

class Routes {
  static const about = '/';
  static const login = '/login';
  static const questions = '/questions';
  static const dashboard = '/dashboard';
  static const workout = '/workout';
  static const diet = '/diet';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => DietProvider()),
      ],
      child: const UghFineApp(),
    ),
  );
}

class UghFineApp extends StatelessWidget {
  const UghFineApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UghFine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B00),
          onPrimary: Colors.white,
          secondary: Color(0xFFFFAA00),
          onSecondary: Colors.black,
          surface: Color(0xFF141414),
          onSurface: Colors.white,
          error: Color(0xFFCF6679),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0A),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A1A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B00),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF888888)),
          floatingLabelStyle: const TextStyle(color: Color(0xFFFF6B00)),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Color(0xFFFF6B00),
          unselectedLabelColor: Color(0xFF666666),
          indicatorColor: Color(0xFFFF6B00),
          indicatorSize: TabBarIndicatorSize.label,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFFF6B00);
            }
            return Colors.transparent;
          }),
          side: const BorderSide(color: Color(0xFF555555)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: Color(0xFF1A1A1A),
          textColor: Colors.white,
          iconColor: Color(0xFFFF6B00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2A2A2A),
          space: 1,
        ),
      ),

      routes: {
        Routes.about: (context) => const AboutScreen(),
        Routes.login: (context) => const LoginScreen(),
      },
      onGenerateRoute: (settings) {
        final protected = <String, WidgetBuilder>{
          Routes.questions: (_) => const QuestionsScreen(),
          Routes.dashboard: (_) => const DashboardScreen(),
          Routes.workout: (_) => const WorkoutScreen(),
          Routes.diet: (_) => const DietScreen(),
        };

        if (protected.containsKey(settings.name)) {
          return MaterialPageRoute(
            builder: (routeContext) {
              final userProvider = Provider.of<UserProvider>(
                routeContext,
                listen: false,
              );
              if (!userProvider.isLoggedIn) {
                return const LoginScreen();
              }
              return protected[settings.name]!(routeContext);
            },
          );
        }
        return null;
      },
    );
  }
}
