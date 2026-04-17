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
    final plan = dietProvider.dietPlan;
    final uid = context.read<UserProvider>().firebaseUser?.uid;

    if (plan == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFFFFAA00))),
      );
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
                    'assets/images/athlete5.jpg',
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
                          'Diet Plan',
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
                          'Your nutrition schedule',
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
                        BorderSide(color: Color(0xFFFFAA00), width: 2.5),
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
                ? const _RestDayView()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
      ),
    );
  }
}

class _RestDayView extends StatelessWidget {
  const _RestDayView();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.08,
          child: Image.asset(
            'assets/images/athlete4.jpg',
            fit: BoxFit.cover,
          ),
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
                  Icons.spa_rounded,
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
              const Text(
                'Eat clean, rest well.',
                style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onToggle});

  final Meal meal;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final completed = meal.isCompleted;

    return GestureDetector(
      onTap: () => onToggle(!completed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: completed
              ? const Color(0xFF101A10)
              : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: completed
                ? const Color(0xFF2A4A2A)
                : const Color(0xFF2A2A2A),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    completed ? const Color(0xFF4CAF50) : Colors.transparent,
                border: Border.all(
                  color: completed
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF444444),
                  width: 2,
                ),
              ),
              child: completed
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFAA00).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          meal.type,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFAA00),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        meal.time,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF666666)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    meal.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: completed
                          ? const Color(0xFF4A4A4A)
                          : const Color(0xFFCCCCCC),
                      decoration:
                          completed ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFF4A4A4A),
                      height: 1.4,
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
