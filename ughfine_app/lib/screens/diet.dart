import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diet_model.dart';
import '../providers/diet_provider.dart';
import '../providers/user_provider.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dietProvider = context.watch<DietProvider>();
    final userProvider = context.watch<UserProvider>();
    final plan = dietProvider.dietPlan;
    final uid = userProvider.firebaseUser?.uid;

    if (plan == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_tabController == null || _tabController!.length != plan.days.length) {
      _tabController?.dispose();
      _tabController = TabController(length: plan.days.length, vsync: this);
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          dietProvider.selectDay(_tabController!.index);
        }
      });
    }

    final selectedDay = dietProvider.selectedDay;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plan'),
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
              child: Text('Rest Day 🥗', style: TextStyle(fontSize: 24)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: selectedDay.meals.length,
              itemBuilder: (context, index) {
                final meal = selectedDay.meals[index];
                return _MealCard(
                  meal: meal,
                  onToggle: (isCompleted) {
                    if (uid == null) return;
                    dietProvider.toggleMeal(
                      uid: uid,
                      mealIndex: index,
                      isCompleted: isCompleted,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onToggle});

  final Meal meal;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => onToggle(!meal.isCompleted),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: meal.isCompleted ? accent : Colors.transparent,
                  border: Border.all(
                    color: meal.isCompleted ? accent : Colors.white38,
                    width: 2,
                  ),
                ),
                child: meal.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
        title: Text(
          '${meal.type}  •  ${meal.time}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          meal.description,
          style: TextStyle(
            decoration: meal.isCompleted ? TextDecoration.lineThrough : null,
            color: meal.isCompleted ? Colors.white38 : null,
          ),
        ),
      ),
    );
  }
}
