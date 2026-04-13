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

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(Routes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell us about yourself'),
        leading: _step > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back)
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step ${_step + 1} of 7',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 24),
            // Render the current step's content
            Expanded(child: _buildStep()),
            const SizedBox(height: 24),
            // Next / Finish button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
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
        Text(
          "What's your name?",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Full name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _stepAge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How old are you?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _ageCtrl,
          decoration: const InputDecoration(
            labelText: 'Age',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _stepBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Body measurements',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _weightCtrl,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _heightCtrl,
          decoration: const InputDecoration(
            labelText: 'Height (cm)',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _stepGoal() {
    const goals = [
      ('lose_weight', 'Lose Weight'),
      ('gain_muscle', 'Gain Muscle'),
      ('general_health', 'General Health'),
      ('improve_endurance', 'Improve Endurance'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's your main fitness goal?",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        // Radio buttons — one per goal option
        ...goals.map(
          (g) => RadioListTile<String>(
            title: Text(g.$2),
            value: g.$1,
            groupValue: _goal,
            onChanged: (v) => setState(() => _goal = v!),
          ),
        ),
      ],
    );
  }

  Widget _stepGymDays() {
    const days = [
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
        Text(
          'Which days do you go to the gym?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        ...days.map(
          (day) => CheckboxListTile(
            title: Text(day),
            value: _gymDays.contains(day),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _gymDays.add(day);
                } else {
                  _gymDays.remove(day);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _stepDiet() {
    const diets = [
      ('none', 'No Preference'),
      ('vegetarian', 'Vegetarian'),
      ('vegan', 'Vegan'),
      ('keto', 'Keto'),
      ('halal', 'Halal'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Any dietary preferences?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...diets.map(
          (d) => RadioListTile<String>(
            title: Text(d.$2),
            value: d.$1,
            groupValue: _dietPreference,
            onChanged: (v) => setState(() => _dietPreference = v!),
          ),
        ),
      ],
    );
  }

  Widget _stepHealthNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Any health notes or injuries?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('This helps us tailor your plan safely.'),
        const SizedBox(height: 16),
        TextField(
          controller: _healthNotesCtrl,
          decoration: const InputDecoration(
            labelText: 'Health notes (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
      ],
    );
  }
}
