import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/user_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/diet_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final workoutProvider = context.read<WorkoutProvider>();
      final dietProvider = context.read<DietProvider>();
      final uid = userProvider.firebaseUser?.uid;
      if (uid != null && workoutProvider.workoutPlan == null) {
        workoutProvider.loadWorkoutPlan(uid);
      }
      if (uid != null && dietProvider.dietPlan == null) {
        dietProvider.loadDietPlan(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final firstName = userProvider.userModel?.name.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/athlete1.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.45, 1.0],
                        colors: [
                          Color(0x33000000),
                          Color(0x66000000),
                          Color(0xFF0A0A0A),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 52,
                    right: 20,
                    child: SafeArea(
                      child: GestureDetector(
                        onTap: () {
                          userProvider.logout();
                          Navigator.of(context).pushReplacementNamed('/');
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            size: 17,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B00),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hey, $firstName! 💪',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Let's crush today's goals.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Plans',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _PlanCard(
                    imagePath: 'assets/images/athlete3.jpg',
                    imageAlignment: Alignment.topCenter,
                    label: 'Training',
                    title: 'Workout Plan',
                    subtitle: 'Your personalized training program',
                    accentColor: const Color(0xFFFF6B00),
                    onTap: () =>
                        Navigator.of(context).pushNamed(Routes.workout),
                  ),

                  const SizedBox(height: 14),

                  _PlanCard(
                    imagePath: 'assets/images/athlete5.jpg',
                    imageAlignment: Alignment.topCenter,
                    label: 'Nutrition',
                    title: 'Diet Plan',
                    subtitle: 'Track your meals and macros',
                    accentColor: const Color(0xFFFFAA00),
                    onTap: () =>
                        Navigator.of(context).pushNamed(Routes.diet),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.imagePath,
    required this.imageAlignment,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final String imagePath;
  final Alignment imageAlignment;
  final String label;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 155,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: imageAlignment,
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.82),
                      Colors.black.withValues(alpha: 0.25),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, Colors.transparent],
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                right: 55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                right: 18,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: accentColor.withValues(alpha: 0.4)),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: accentColor,
                      size: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
