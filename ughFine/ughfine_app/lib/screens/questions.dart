import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

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

  void _next() {
    if (_step < 6) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _submit() async {
    final userProvider = context.read<UserProvider>();

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

    await userProvider.saveUserProfile(user);

    // AI + plan generation will be added here

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(Routes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_step + 1} of 7'),
        leading: _step > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back)
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildStep()),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_step < 6 ? 'Next' : 'Finish'),
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

  Widget _stepName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is your name?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Full name'),
          autofocus: true,
        ),
      ],
    );
  }

  Widget _stepAge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How old are you?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ageCtrl,
          decoration: const InputDecoration(labelText: 'Age'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _stepBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your body stats',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _weightCtrl,
          decoration: const InputDecoration(labelText: 'Weight (kg)'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _heightCtrl,
          decoration: const InputDecoration(labelText: 'Height (cm)'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _stepGoal() {
    final goals = [
      ('lose_weight', 'Lose Weight', Icons.trending_down),
      ('build_muscle', 'Build Muscle', Icons.fitness_center),
      ('general_health', 'General Health', Icons.favorite),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is your goal?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...goals.map((g) {
          final isSelected = _goal == g.$1;
          return ListTile(
            leading: Icon(g.$3),
            title: Text(g.$2),
            tileColor: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            onTap: () => setState(() => _goal = g.$1),
          );
        }),
      ],
    );
  }

  Widget _stepGymDays() {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Which days do you go to the gym?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: days.map((day) {
              final isSelected = _gymDays.contains(day);
              return CheckboxListTile(
                title: Text(day),
                value: isSelected,
                onChanged: (checked) => setState(() {
                  if (checked == true) {
                    _gymDays.add(day);
                  } else {
                    _gymDays.remove(day);
                  }
                }),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _stepDiet() {
    final options = [
      ('none', 'No preference'),
      ('vegetarian', 'Vegetarian'),
      ('vegan', 'Vegan'),
      ('keto', 'Keto'),
      ('high_protein', 'High Protein'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Any diet preference?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...options.map((o) {
          final isSelected = _dietPreference == o.$1;
          return ListTile(
            title: Text(o.$2),
            tileColor: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            onTap: () => setState(() => _dietPreference = o.$1),
          );
        }),
      ],
    );
  }

  Widget _stepHealthNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Any injuries or health notes?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Leave blank if none.', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _healthNotesCtrl,
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
