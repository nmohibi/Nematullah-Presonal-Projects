class Exercise {
  final String name;
  final int sets;
  final int reps;
  final String restTime;
  final String instructions;

  const Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restTime,
    required this.instructions,
  });

  factory Exercise.fromMap(Map<String, dynamic> data) {
    return Exercise(
      name: data['name'] ?? '',
      sets: _toInt(data['sets']),
      reps: _toInt(data['reps']),
      restTime: data['restTime']?.toString() ?? '',
      instructions: data['instructions']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'sets': sets,
    'reps': reps,
    'restTime': restTime,
    'instructions': instructions,
  };
}

class WorkoutDay {
  final String day;
  final bool isRestDay;
  final List<Exercise> exercises;

  const WorkoutDay({
    required this.day,
    required this.isRestDay,
    required this.exercises,
  });

  factory WorkoutDay.fromMap(Map<String, dynamic> data) {
    final rest = data['isRestDay'] as bool? ?? false;
    return WorkoutDay(
      day: data['day'] ?? '',
      isRestDay: rest,
      exercises: rest
          ? []
          : (data['exercises'] as List<dynamic>? ?? [])
                .map((e) => Exercise.fromMap(e as Map<String, dynamic>))
                .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'day': day,
    'isRestDay': isRestDay,
    'exercises': exercises.map((e) => e.toMap()).toList(),
  };
}

class WorkoutPlan {
  final String userId;
  final List<WorkoutDay> days;

  const WorkoutPlan({required this.userId, required this.days});

  factory WorkoutPlan.fromFirestore(Map<String, dynamic> data) {
    return WorkoutPlan(
      userId: data['userId'] ?? '',
      days: (data['days'] as List<dynamic>? ?? [])
          .map((d) => WorkoutDay.fromMap(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'days': days.map((d) => d.toMap()).toList(),
  };
}
