import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_models.dart';
import '../providers/workout_provider.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _lastPlanLength = -1;

  void _initTabController(WorkoutProvider workoutProvider, int length) {
    _tabController?.dispose();
    _tabController = TabController(length: length, vsync: this);
    _lastPlanLength = length;
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        workoutProvider.selectDay(_tabController!.index);
      }
    });
  }

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
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00))),
      );
    }

    if (_tabController == null || _lastPlanLength != plan.days.length) {
      _initTabController(workoutProvider, plan.days.length);
    }

    final selectedDay = workoutProvider.selectedDay;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/athlete3.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.5, 1.0],
                        colors: [
                          Color(0x44000000),
                          Color(0x88000000),
                          Color(0xFF0A0A0A),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 60,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workout Plan',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 8),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your training schedule',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: const Color(0xFF0A0A0A),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: const UnderlineTabIndicator(
                    borderSide:
                        BorderSide(color: Color(0xFFFF6B00), width: 2.5),
                    insets: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF555555),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  tabs: plan.days
                      .map((d) =>
                          Tab(text: d.day.substring(0, 3).toUpperCase()))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
        body: selectedDay == null
            ? const Center(child: Text('No day selected'))
            : selectedDay.isRestDay
                ? _RestDayView(
                    message: 'Recovery is part of the process.',
                    imagePath: 'assets/images/athlete2.jpg',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    itemCount: selectedDay.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = selectedDay.exercises[index];
                      return _ExerciseCard(exercise: exercise, index: index);
                    },
                  ),
      ),
    );
  }
}

class _RestDayView extends StatelessWidget {
  const _RestDayView({required this.message, required this.imagePath});
  final String message;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.08,
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: const Icon(
                  Icons.hotel_rounded,
                  size: 32,
                  color: Color(0xFF444444),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Rest Day',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.index});
  final Exercise exercise;
  final int index;

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatChip(icon: Icons.repeat_rounded, label: '${exercise.sets} sets'),
                const SizedBox(width: 8),
                _StatChip(icon: Icons.numbers_rounded, label: '${exercise.reps} reps'),
                const SizedBox(width: 8),
                _StatChip(icon: Icons.timer_outlined, label: exercise.restTime),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6B00),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              exercise.instructions,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFAAAAAA),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B00), Color(0xFFFFAA00)],
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _StatChip(
                          icon: Icons.repeat_rounded,
                          label: '${exercise.sets} sets'),
                      _StatChip(
                          icon: Icons.numbers_rounded,
                          label: '${exercise.reps} reps'),
                      _StatChip(
                          icon: Icons.timer_outlined,
                          label: exercise.restTime),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    exercise.instructions,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF777777),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hold for details',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF444444),
                      fontStyle: FontStyle.italic,
                    ),
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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFFF6B00)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFAAAAAA),
            ),
          ),
        ],
      ),
    );
  }
}
