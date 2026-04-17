import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/user_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/diet_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final dietProvider = context.watch<DietProvider>();

    final uid = userProvider.firebaseUser?.uid;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (uid != null && workoutProvider.workoutPlan == null) {
        workoutProvider.loadWorkoutPlan(uid);
      }
      if (uid != null && dietProvider.dietPlan == null) {
        dietProvider.loadDietPlan(uid);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Hellloooooo, ${userProvider.userModel?.name ?? 'there'}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              userProvider.logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(Routes.workout),
              child: const Text('My Workout Plan'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(Routes.diet),
              child: const Text('My Diet Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
