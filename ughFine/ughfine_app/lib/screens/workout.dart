import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final plan = workoutProvider.workoutPlan;

    if (plan == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_tabController == null || _tabController!.length != plan.days.length) {
      _tabController?.dispose();
      _tabController = TabController(length: plan.days.length, vsync: this);
      _tabController!.addListener(() {
        workoutProvider.selectDay(_tabController!.index);
      });
    }

    final selectedDay = workoutProvider.selectedDay;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plan'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: plan.days.map((d) => Tab(text: d.day.substring(0, 3))).toList(),
        ),
      ),
      body: selectedDay == null
          ? const Center(child: Text('No day selected'))
          : selectedDay.isRestDay
          ? const Center(
              child: Text('Rest Day 🛋️', style: TextStyle(fontSize: 24)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: selectedDay.exercises.length,
              itemBuilder: (context, index) {
                final exercise = selectedDay.exercises[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${exercise.sets} sets × ${exercise.reps} reps  •  Rest: ${exercise.restTime}\n${exercise.instructions}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
