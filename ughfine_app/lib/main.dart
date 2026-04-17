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
      onGenerateRoute: (settings) {
        final protected = <String, WidgetBuilder>{
          Routes.questions: (_) => const QuestionsScreen(),
          Routes.dashboard: (_) => const DashboardScreen(),
          Routes.workout: (_) => const WorkoutScreen(),
          Routes.diet: (_) => const DietScreen(),
        };

        if (protected.containsKey(settings.name)) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          if (!userProvider.isLoggedIn) {
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          }
          return MaterialPageRoute(builder: protected[settings.name]!);
        }
        return null;
      },
    );
  }
}
