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
}
