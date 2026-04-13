class UserModel {
  final String uid;
  final String email;
  final String name;
  final int age;
  final double weightKg;
  final double heightCm;
  final String goal;
  final List<String> gymDays;
  final String dietPreference;
  final String healthNotes;
  final bool hasCompletedOnboarding;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.goal,
    required this.gymDays,
    required this.dietPreference,
    required this.healthNotes,
    this.hasCompletedOnboarding = false,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      age: (data['age'] ?? 0) as int,
      weightKg: (data['weightKg'] ?? 0.0).toDouble(),
      heightCm: (data['heightCm'] ?? 0.0).toDouble(),
      goal: data['goal'] ?? 'general_health',
      gymDays: List<String>.from(data['gymDays'] ?? []),
      dietPreference: data['dietPreference'] ?? 'none',
      healthNotes: data['healthNotes'] ?? '',
      hasCompletedOnboarding: data['hasCompletedOnboarding'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'goal': goal,
      'gymDays': gymDays,
      'dietPreference': dietPreference,
      'healthNotes': healthNotes,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  UserModel copyWith({
    String? name,
    int? age,
    double? weightKg,
    double? heightCm,
    String? goal,
    List<String>? gymDays,
    String? dietPreference,
    String? healthNotes,
    bool? hasCompletedOnboarding,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      goal: goal ?? this.goal,
      gymDays: gymDays ?? this.gymDays,
      dietPreference: dietPreference ?? this.dietPreference,
      healthNotes: healthNotes ?? this.healthNotes,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
