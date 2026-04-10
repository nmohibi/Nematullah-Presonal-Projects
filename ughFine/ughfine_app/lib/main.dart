import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/diet_provider.dart';
import 'screens/about.dart';
import 'screens/login.dart';

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
      title: 'FitAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F5C99),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      routes: {
        Routes.about: (context) => const AboutScreen(),
        Routes.login: (context) => const LoginScreen(),
      },
    );
  }
}
