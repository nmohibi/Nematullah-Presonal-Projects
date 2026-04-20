import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/secrets.dart';
import '../models/user_model.dart';
import '../models/workout_models.dart';
import '../models/diet_model.dart';

class AiService {
  final _model = GenerativeModel(
    model: 'models/gemini-2.5-pro',
    apiKey: Secrets.geminiApiKey,
  );

  Future<({WorkoutPlan workout, DietPlan diet})> generatePlans(
    UserModel user,
  ) async {
    final prompt =
        '''
You are a certified personal trainer and nutritionist.
Generate a 7-day workout and diet plan for this user:

Name: ${user.name}
Age: ${user.age}
Weight: ${user.weightKg} kg
Height: ${user.heightCm} cm
Goal: ${user.goal}
Gym days: ${user.gymDays.join(', ')}
Diet preference: ${user.dietPreference}
Health notes: ${user.healthNotes.isEmpty ? 'None' : user.healthNotes}

Rules:
- Only assign exercises on the user's gym days. All other days are rest days.
- Each gym day should have 4–6 exercises with sets, reps, rest time, and brief instructions.
- Each day should have 3–4 meals.

Return ONLY valid JSON in exactly this format with no extra text:
{
  "workout": {
    "userId": "${user.uid}",
    "days": [
      {
        "day": "Monday",
        "isRestDay": false,
        "exercises": [
          {
            "name": "Bench Press",
            "sets": 3,
            "reps": 10,
            "restTime": "90 seconds",
            "instructions": "Keep your back flat on the bench."
          }
        ]
      },
      {
        "day": "Tuesday",
        "isRestDay": true,
        "exercises": []
      }
    ]
  },
  "diet": {
    "userId": "${user.uid}",
    "days": [
      {
        "day": "Monday",
        "isRestDay": false,
        "meals": [
          {
            "type": "Breakfast",
            "time": "8:00 AM",
            "description": "Oats with banana and protein powder",
            "isCompleted": false
          }
        ]
      }
    ]
  }
}
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '';

    String cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceAll(RegExp(r'```\w*'), '').trim();
    }

    final Map<String, dynamic> json = jsonDecode(cleaned);

    final workout = WorkoutPlan.fromFirestore(
      json['workout'] as Map<String, dynamic>,
    );
    final diet = DietPlan.fromFirestore(json['diet'] as Map<String, dynamic>);

    return (workout: workout, diet: diet);
  }
}
