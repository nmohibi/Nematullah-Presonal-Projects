class Meal {
  final String type;
  final String time;
  final String description;
  final bool isCompleted;

  const Meal({
    required this.type,
    required this.time,
    required this.description,
    this.isCompleted = false,
  });

  factory Meal.fromMap(Map<String, dynamic> data) {
    return Meal(
      type: data['type'] ?? '',
      time: data['time'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type,
    'time': time,
    'description': description,
    'isCompleted': isCompleted,
  };

  Meal copyWith({bool? isCompleted}) => Meal(
    type: type,
    time: time,
    description: description,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}

class DietDay {
  final String day;
  final bool isRestDay;
  final List<Meal> meals;

  const DietDay({
    required this.day,
    required this.isRestDay,
    required this.meals,
  });

  factory DietDay.fromMap(Map<String, dynamic> data) {
    final rest = data['isRestDay'] as bool? ?? false;
    return DietDay(
      day: data['day'] ?? '',
      isRestDay: rest,
      meals: rest
          ? []
          : (data['meals'] as List<dynamic>? ?? [])
                .map((m) => Meal.fromMap(m as Map<String, dynamic>))
                .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'day': day,
    'isRestDay': isRestDay,
    'meals': meals.map((m) => m.toMap()).toList(),
  };
}

class DietPlan {
  final String userId;
  final List<DietDay> days;

  const DietPlan({required this.userId, required this.days});

  factory DietPlan.fromFirestore(Map<String, dynamic> data) {
    return DietPlan(
      userId: data['userId'] ?? '',
      days: (data['days'] as List<dynamic>? ?? [])
          .map((d) => DietDay.fromMap(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'days': days.map((d) => d.toMap()).toList(),
  };
}
