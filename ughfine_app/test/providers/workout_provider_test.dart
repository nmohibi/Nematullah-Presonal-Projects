import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ughfine_app/models/workout_models.dart';
import 'package:ughfine_app/providers/workout_provider.dart';
import 'package:ughfine_app/services/firestore_service.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  group('WorkoutProvider Tests', () {
    late WorkoutProvider provider;
    late MockFirestoreService mockFirestoreService;
    late WorkoutPlan testPlan;

    setUp(() {
      mockFirestoreService = MockFirestoreService();

      testPlan = WorkoutPlan(
        userId: 'user123',
        days: [
          WorkoutDay(
            day: 'Monday',
            isRestDay: false,
            exercises: [
              Exercise(
                name: 'Bench Press',
                sets: 3,
                reps: 10,
                restTime: '90 seconds',
                instructions: 'Keep your back flat.',
              ),
            ],
          ),
          WorkoutDay(
            day: 'Sunday',
            isRestDay: true,
            exercises: [],
          ),
        ],
      );

      provider = WorkoutProvider();
    });

    test('WorkoutProvider should have null workoutPlan on init', () {
      expect(provider.workoutPlan, isNull);
    });

    test('WorkoutProvider should have selectedDayIndex of 0 on init', () {
      expect(provider.selectedDayIndex, 0);
    });

    test('WorkoutProvider setWorkoutPlan should store plan and notify', () {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      provider.setWorkoutPlan(testPlan);

      expect(provider.workoutPlan, testPlan);
      expect(provider.selectedDayIndex, 0);
      expect(notifyCount, 1);
    });

    test('WorkoutProvider selectedDay should return current day', () {
      provider.setWorkoutPlan(testPlan);

      final selectedDay = provider.selectedDay;

      expect(selectedDay, isNotNull);
      expect(selectedDay?.day, 'Monday');
    });

    test('WorkoutProvider selectDay should change selectedDayIndex', () {
      provider.setWorkoutPlan(testPlan);
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      provider.selectDay(1);

      expect(provider.selectedDayIndex, 1);
      expect(provider.selectedDay?.day, 'Sunday');
      expect(notifyCount, 1);
    });

    test('WorkoutProvider selectedDay should return null if plan is null', () {
      final selectedDay = provider.selectedDay;

      expect(selectedDay, isNull);
    });

    test('WorkoutProvider selectedDay should return null if index is out of bounds',
        () {
      provider.setWorkoutPlan(testPlan);

      provider.selectDay(100);
      final selectedDay = provider.selectedDay;

      expect(selectedDay, isNull);
    });

    test('WorkoutProvider should notify listeners when plan is set', () {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      provider.setWorkoutPlan(testPlan);
      provider.setWorkoutPlan(testPlan);

      expect(notifyCount, 2);
    });

    test('WorkoutProvider should reset selectedDayIndex when setting new plan',
        () {
      provider.setWorkoutPlan(testPlan);
      provider.selectDay(1);
      expect(provider.selectedDayIndex, 1);

      provider.setWorkoutPlan(testPlan);

      expect(provider.selectedDayIndex, 0);
    });
  });
}
