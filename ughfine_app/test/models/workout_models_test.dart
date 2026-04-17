import 'package:flutter_test/flutter_test.dart';
import 'package:ughfine_app/models/workout_models.dart';

void main() {
  group('Exercise Model Tests', () {
    late Exercise exercise;

    setUp(() {
      exercise = Exercise(
        name: 'Bench Press',
        sets: 3,
        reps: 10,
        restTime: '90 seconds',
        instructions: 'Keep your back flat on the bench.',
      );
    });

    test('Exercise should have readable properties', () {
      expect(exercise.name, 'Bench Press');
      expect(exercise.sets, 3);
      expect(exercise.reps, 10);
      expect(exercise.restTime, '90 seconds');
      expect(exercise.instructions, 'Keep your back flat on the bench.');
    });

    test('Exercise should convert to map correctly', () {
      final map = exercise.toMap();

      expect(map['name'], 'Bench Press');
      expect(map['sets'], 3);
      expect(map['reps'], 10);
      expect(map['restTime'], '90 seconds');
      expect(map['instructions'], 'Keep your back flat on the bench.');
    });

    test('Exercise should create from map correctly', () {
      final data = {
        'name': 'Squats',
        'sets': 4,
        'reps': 8,
        'restTime': '2 minutes',
        'instructions': 'Keep your chest up.',
      };

      final created = Exercise.fromMap(data);

      expect(created.name, 'Squats');
      expect(created.sets, 4);
      expect(created.reps, 8);
      expect(created.restTime, '2 minutes');
      expect(created.instructions, 'Keep your chest up.');
    });

    test('Exercise should handle missing fields with defaults', () {
      final data = {'name': 'Deadlift'};

      final created = Exercise.fromMap(data);

      expect(created.name, 'Deadlift');
      expect(created.sets, 0);
      expect(created.reps, 0);
      expect(created.restTime, '');
      expect(created.instructions, '');
    });
  });

  group('WorkoutDay Model Tests', () {
    late WorkoutDay workoutDay;

    setUp(() {
      workoutDay = WorkoutDay(
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
          Exercise(
            name: 'Squats',
            sets: 4,
            reps: 8,
            restTime: '2 minutes',
            instructions: 'Keep chest up.',
          ),
        ],
      );
    });

    test('WorkoutDay should have readable properties', () {
      expect(workoutDay.day, 'Monday');
      expect(workoutDay.isRestDay, false);
      expect(workoutDay.exercises.length, 2);
      expect(workoutDay.exercises[0].name, 'Bench Press');
    });

    test('WorkoutDay should convert to map correctly', () {
      final map = workoutDay.toMap();

      expect(map['day'], 'Monday');
      expect(map['isRestDay'], false);
      expect(map['exercises'], isA<List>());
      expect(map['exercises'].length, 2);
    });

    test('WorkoutDay should create rest day with empty exercises', () {
      final restDay = WorkoutDay(day: 'Sunday', isRestDay: true, exercises: []);

      expect(restDay.day, 'Sunday');
      expect(restDay.isRestDay, true);
      expect(restDay.exercises.isEmpty, true);
    });

    test('WorkoutDay should create from map correctly', () {
      final data = {
        'day': 'Tuesday',
        'isRestDay': false,
        'exercises': [
          {
            'name': 'Pull-ups',
            'sets': 3,
            'reps': 12,
            'restTime': '60 seconds',
            'instructions': 'Full range of motion.',
          },
        ],
      };

      final created = WorkoutDay.fromMap(data);

      expect(created.day, 'Tuesday');
      expect(created.isRestDay, false);
      expect(created.exercises.length, 1);
      expect(created.exercises[0].name, 'Pull-ups');
    });

    test('WorkoutDay should handle rest day with no exercises', () {
      final data = {'day': 'Wednesday', 'isRestDay': true, 'exercises': []};

      final created = WorkoutDay.fromMap(data);

      expect(created.day, 'Wednesday');
      expect(created.isRestDay, true);
      expect(created.exercises.isEmpty, true);
    });
  });

  group('WorkoutPlan Model Tests', () {
    late WorkoutPlan workoutPlan;

    setUp(() {
      workoutPlan = WorkoutPlan(
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
          WorkoutDay(day: 'Sunday', isRestDay: true, exercises: []),
        ],
      );
    });

    test('WorkoutPlan should have readable properties', () {
      expect(workoutPlan.userId, 'user123');
      expect(workoutPlan.days.length, 2);
      expect(workoutPlan.days[0].day, 'Monday');
      expect(workoutPlan.days[1].isRestDay, true);
    });

    test('WorkoutPlan should convert to map correctly', () {
      final map = workoutPlan.toMap();

      expect(map['userId'], 'user123');
      expect(map['days'], isA<List>());
      expect(map['days'].length, 2);
    });

    test('WorkoutPlan should create from firestore correctly', () {
      final data = {
        'userId': 'user456',
        'days': [
          {
            'day': 'Friday',
            'isRestDay': false,
            'exercises': [
              {
                'name': 'Deadlift',
                'sets': 5,
                'reps': 5,
                'restTime': '3 minutes',
                'instructions': 'Keep back straight.',
              },
            ],
          },
        ],
      };

      final created = WorkoutPlan.fromFirestore(data);

      expect(created.userId, 'user456');
      expect(created.days.length, 1);
      expect(created.days[0].day, 'Friday');
      expect(created.days[0].exercises[0].name, 'Deadlift');
    });

    test(
      'WorkoutPlan round-trip: toMap -> fromFirestore should be identical',
      () {
        final map = workoutPlan.toMap();

        final reconstructed = WorkoutPlan.fromFirestore(map);

        expect(reconstructed.userId, workoutPlan.userId);
        expect(reconstructed.days.length, workoutPlan.days.length);
        expect(reconstructed.days[0].day, workoutPlan.days[0].day);
        expect(
          reconstructed.days[0].exercises.length,
          workoutPlan.days[0].exercises.length,
        );
      },
    );
  });
}
//comment