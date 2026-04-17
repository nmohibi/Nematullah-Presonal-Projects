import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/diet_provider.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  int _step = 0;

  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _healthNotesCtrl = TextEditingController();
  bool _isLoading = false;
  var _goal = 'general_health';
  var _dietPreference = 'none';
  final List<String> _gymDays = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _healthNotesCtrl.dispose();
    super.dispose();
  }

  String? _stepError;

  void _next() {
    final error = _validateStep(_step);
    if (error != null) {
      setState(() => _stepError = error);
      return;
    }
    setState(() => _stepError = null);
    if (_step < 6) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  String? _validateStep(int step) {
    switch (step) {
      case 0:
        if (_nameCtrl.text.trim().isEmpty) return 'Please enter your name.';
        return null;
      case 1:
        final age = int.tryParse(_ageCtrl.text.trim());
        if (_ageCtrl.text.trim().isEmpty) return 'Please enter your age.';
        if (age == null || age < 10 || age > 100) return 'Please enter a valid age (10–100).';
        return null;
      case 2:
        final weight = double.tryParse(_weightCtrl.text.trim());
        final height = double.tryParse(_heightCtrl.text.trim());
        if (_weightCtrl.text.trim().isEmpty) return 'Please enter your weight.';
        if (weight == null || weight <= 0) return 'Please enter a valid weight.';
        if (_heightCtrl.text.trim().isEmpty) return 'Please enter your height.';
        if (height == null || height <= 0) return 'Please enter a valid height.';
        return null;
      case 3:
        return null;
      case 4:
        if (_gymDays.isEmpty) return 'Please select at least one gym day.';
        return null;
      case 5:
        return null;
      case 6:
        return null;
      default:
        return null;
    }
  }

  void _back() {
    if (_step > 0) setState(() { _step--; _stepError = null; });
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final workoutProvider = context.read<WorkoutProvider>();
      final dietProvider = context.read<DietProvider>();
      final firestoreService = FirestoreService();
      final aiService = AiService();

      final user = UserModel(
        uid: userProvider.firebaseUser!.uid,
        email: userProvider.firebaseUser!.email ?? '',
        name: _nameCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
        weightKg: double.tryParse(_weightCtrl.text.trim()) ?? 0.0,
        heightCm: double.tryParse(_heightCtrl.text.trim()) ?? 0.0,
        goal: _goal,
        gymDays: List.from(_gymDays),
        dietPreference: _dietPreference,
        healthNotes: _healthNotesCtrl.text.trim(),
        hasCompletedOnboarding: true,
      );

      final plans = await aiService.generatePlans(user);
      await userProvider.saveUserProfile(user);
      workoutProvider.setWorkoutPlan(plans.workout);
      dietProvider.setDietPlan(plans.diet);
      await firestoreService.saveWorkoutPlan(plans.workout);
      await firestoreService.saveDietPlan(plans.diet);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(Routes.dashboard);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong generating your plan. Please try again.',
          ),
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const totalSteps = 7;
    final progress = (_step + 1) / totalSteps;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: _back,
              )
            : null,
        title: Text(
          'Step ${_step + 1} of $totalSteps',
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF888888),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: const Color(0xFF1A1A1A),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF6B00),
                ),
              ),
            ),

            const SizedBox(height: 32),

            Expanded(child: _buildStep()),

            if (_stepError != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1010),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF5A2020)),
                ),
                child: Text(
                  _stepError!,
                  style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 13,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _next,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_step < 6 ? 'Next' : 'Generate My Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _stepName(),
      1 => _stepAge(),
      2 => _stepBody(),
      3 => _stepGoal(),
      4 => _stepGymDays(),
      5 => _stepDiet(),
      _ => _stepHealthNotes(),
    };
  }

  Widget _stepQuestion(String question) {
    return Text(
      question,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
    );
  }

  Widget _stepName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepQuestion('What is\nyour name?'),
        const SizedBox(height: 32),
        TextFormField(
          controller: _nameCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            labelText: 'Full name',
            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF555555), size: 20),
          ),
          autofocus: true,
          onChanged: (_) => setState(() => _stepError = null),
        ),
      ],
    );
  }

  Widget _stepAge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepQuestion('How old\nare you?'),
        const SizedBox(height: 32),
        TextFormField(
          controller: _ageCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            labelText: 'Age',
            prefixIcon: Icon(Icons.cake_outlined, color: Color(0xFF555555), size: 20),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() => _stepError = null),
        ),
      ],
    );
  }

  Widget _stepBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepQuestion('Your\nbody stats'),
        const SizedBox(height: 32),
        TextFormField(
          controller: _weightCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            prefixIcon: Icon(Icons.monitor_weight_outlined, color: Color(0xFF555555), size: 20),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() => _stepError = null),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _heightCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            labelText: 'Height (cm)',
            prefixIcon: Icon(Icons.height_rounded, color: Color(0xFF555555), size: 20),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() => _stepError = null),
        ),
      ],
    );
  }

  Widget _stepGoal() {
    final goals = [
      ('lose_weight', 'Lose Weight', Icons.trending_down_rounded),
      ('build_muscle', 'Build Muscle', Icons.fitness_center_rounded),
      ('general_health', 'General Health', Icons.favorite_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepQuestion('What is\nyour goal?'),
        const SizedBox(height: 28),
        ...goals.map((g) {
          final isSelected = _goal == g.$1;
          return GestureDetector(
            onTap: () => setState(() => _goal = g.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1A0D00)
                    : const Color(0xFF141414),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B00)
                      : const Color(0xFF2A2A2A),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    g.$3,
                    color: isSelected
                        ? const Color(0xFFFF6B00)
                        : const Color(0xFF555555),
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    g.$2,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF888888),
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFFFF6B00),
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _stepGymDays() {
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepQuestion('Gym\ndays?'),
        const SizedBox(height: 28),
        Expanded(
          child: ListView(
            children: days.map((day) {
              final isSelected = _gymDays.contains(day);
              return GestureDetector(
                onTap: () => setState(() {
                  _stepError = null;
                  if (isSelected) {
                    _gymDays.remove(day);
                  } else {
                    _gymDays.add(day);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1A0D00)
                        : const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF6B00)
                          : const Color(0xFF2A2A2A),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF888888),
                        ),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFFFF6B00)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF6B00)
                                : const Color(0xFF444444),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _stepDiet() {
    final options = [
      ('none', 'No preference', Icons.restaurant_rounded),
      ('vegetarian', 'Vegetarian', Icons.eco_rounded),
      ('vegan', 'Vegan', Icons.spa_rounded),
      ('keto', 'Keto', Icons.local_fire_department_rounded),
      ('high_protein', 'High Protein', Icons.fitness_center_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepQuestion('Diet\npreference?'),
        const SizedBox(height: 28),
        ...options.map((o) {
          final isSelected = _dietPreference == o.$1;
          return GestureDetector(
            onTap: () => setState(() => _dietPreference = o.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1A0D00)
                    : const Color(0xFF141414),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B00)
                      : const Color(0xFF2A2A2A),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    o.$3,
                    color: isSelected
                        ? const Color(0xFFFF6B00)
                        : const Color(0xFF555555),
                    size: 20,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    o.$2,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF888888),
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFFFF6B00),
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _stepHealthNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepQuestion('Any injuries\nor health notes?'),
        const SizedBox(height: 8),
        const Text(
          'Leave blank if none — we got you either way.',
          style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 28),
        TextFormField(
          controller: _healthNotesCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'Health notes (optional)',
            alignLabelWithHint: true,
          ),
          maxLines: 4,
        ),
      ],
    );
  }
}
