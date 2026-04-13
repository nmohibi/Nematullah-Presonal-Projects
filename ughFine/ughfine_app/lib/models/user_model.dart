class UserModel {
  final String uid;
  final String email;
  final bool hasCompletedOnboarding;

  const UserModel({
    required this.uid,
    required this.email,
    this.hasCompletedOnboarding = false,
  });
}
