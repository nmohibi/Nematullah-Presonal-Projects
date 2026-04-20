import 'package:flutter_test/flutter_test.dart';
import 'package:ughfine_app/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    late UserModel user;

    setUp(() {
      user = UserModel(
        uid: 'user123',
        email: 'nemo@example.com',
        name: 'NEMO',
        age: 25,
        weightKg: 75.5,
        heightCm: 180.0,
        goal: 'build_muscle',
        gymDays: ['Monday', 'Wednesday', 'Friday'],
        dietPreference: 'high_protein',
        healthNotes: 'No injuries',
        hasCompletedOnboarding: true,
      );
    });

    test('UserModel should have readable properties', () {
      expect(user.uid, 'user123');
      expect(user.email, 'nemo@example.com');
      expect(user.name, 'NEMO');
      expect(user.age, 25);
      expect(user.weightKg, 75.5);
      expect(user.heightCm, 180.0);
      expect(user.goal, 'build_muscle');
      expect(user.hasCompletedOnboarding, true);
    });

    test('UserModel should convert to map correctly', () {
      final map = user.toMap();

      expect(map['email'], 'nemo@example.com');
      expect(map['name'], 'NEMO');
      expect(map['age'], 25);
      expect(map['weightKg'], 75.5);
      expect(map['heightCm'], 180.0);
      expect(map['goal'], 'build_muscle');
      expect(map['gymDays'], ['Monday', 'Wednesday', 'Friday']);
      expect(map['hasCompletedOnboarding'], true);
    });

    test('UserModel should create from firestore data correctly', () {
      final data = {
        'email': 'nemo@example.com',
        'name': 'NEMO',
        'age': 25,
        'weightKg': 75.5,
        'heightCm': 180.0,
        'goal': 'build_muscle',
        'gymDays': ['Monday', 'Wednesday', 'Friday'],
        'dietPreference': 'high_protein',
        'healthNotes': 'No injuries',
        'hasCompletedOnboarding': true,
      };

      final created = UserModel.fromFirestore(data, 'user123');

      expect(created.uid, 'user123');
      expect(created.email, 'nemo@example.com');
      expect(created.name, 'NEMO');
      expect(created.age, 25);
      expect(created.weightKg, 75.5);
      expect(created.heightCm, 180.0);
      expect(created.goal, 'build_muscle');
    });

    test('UserModel should handle missing firestore fields with defaults', () {
      final data = {'email': 'nemo@example.com', 'name': 'NEMO'};

      final created = UserModel.fromFirestore(data, 'user123');

      expect(created.age, 0);
      expect(created.weightKg, 0.0);
      expect(created.heightCm, 0.0);
      expect(created.goal, 'general_health');
      expect(created.gymDays, []);
      expect(created.dietPreference, 'none');
      expect(created.hasCompletedOnboarding, false);
    });

    test('UserModel copyWith should update only specified fields', () {
      final updated = user.copyWith(age: 26, weightKg: 78.0);

      expect(updated.age, 26);
      expect(updated.weightKg, 78.0);

      expect(updated.uid, user.uid);
      expect(updated.email, user.email);
      expect(updated.name, user.name);
      expect(updated.heightCm, user.heightCm);
      expect(updated.goal, user.goal);
      expect(updated.hasCompletedOnboarding, user.hasCompletedOnboarding);
    });

    test(
      'UserModel copyWith should preserve all fields when called without args',
      () {
        final copy = user.copyWith();

        expect(copy.uid, user.uid);
        expect(copy.email, user.email);
        expect(copy.name, user.name);
        expect(copy.age, user.age);
        expect(copy.weightKg, user.weightKg);
        expect(copy.heightCm, user.heightCm);
        expect(copy.goal, user.goal);
        expect(copy.gymDays, user.gymDays);
        expect(copy.dietPreference, user.dietPreference);
        expect(copy.hasCompletedOnboarding, user.hasCompletedOnboarding);
      },
    );

    test(
      'UserModel round-trip: toMap -> fromFirestore should be identical',
      () {
        final map = user.toMap();

        final reconstructed = UserModel.fromFirestore(map, user.uid);

        expect(reconstructed.email, user.email);
        expect(reconstructed.name, user.name);
        expect(reconstructed.age, user.age);
        expect(reconstructed.weightKg, user.weightKg);
        expect(reconstructed.heightCm, user.heightCm);
        expect(reconstructed.goal, user.goal);
        expect(reconstructed.gymDays, user.gymDays);
        expect(reconstructed.dietPreference, user.dietPreference);
        expect(reconstructed.healthNotes, user.healthNotes);
        expect(
          reconstructed.hasCompletedOnboarding,
          user.hasCompletedOnboarding,
        );
      },
    );
  });
}
