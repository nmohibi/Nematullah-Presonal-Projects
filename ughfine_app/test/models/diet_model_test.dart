import 'package:flutter_test/flutter_test.dart';
import 'package:ughfine_app/models/diet_model.dart';

void main() {
  group('Meal Model Tests', () {
    late Meal meal;

    setUp(() {
      meal = Meal(
        type: 'Breakfast',
        time: '8:00 AM',
        description: 'Oats with banana and protein powder',
        isCompleted: false,
      );
    });

    test('Meal should have readable properties', () {
      expect(meal.type, 'Breakfast');
      expect(meal.time, '8:00 AM');
      expect(meal.description, 'Oats with banana and protein powder');
      expect(meal.isCompleted, false);
    });

    test('Meal should convert to map correctly', () {
      final map = meal.toMap();

      expect(map['type'], 'Breakfast');
      expect(map['time'], '8:00 AM');
      expect(map['description'], 'Oats with banana and protein powder');
      expect(map['isCompleted'], false);
    });

    test('Meal should create from map correctly', () {
      final data = {
        'type': 'Lunch',
        'time': '12:30 PM',
        'description': 'Grilled chicken with rice',
        'isCompleted': true,
      };

      final created = Meal.fromMap(data);

      expect(created.type, 'Lunch');
      expect(created.time, '12:30 PM');
      expect(created.description, 'Grilled chicken with rice');
      expect(created.isCompleted, true);
    });

    test('Meal should handle missing fields with defaults', () {
      final data = {'type': 'Dinner'};

      final created = Meal.fromMap(data);

      expect(created.type, 'Dinner');
      expect(created.time, '');
      expect(created.description, '');
      expect(created.isCompleted, false);
    });

    test('Meal copyWith should toggle isCompleted', () {
      expect(meal.isCompleted, false);

      final updated = meal.copyWith(isCompleted: true);

      expect(updated.isCompleted, true);
      expect(updated.type, meal.type);
      expect(updated.time, meal.time);
      expect(updated.description, meal.description);
    });

    test('Meal copyWith should preserve other fields when toggling', () {
      final updated = meal.copyWith(isCompleted: true);

      expect(updated.type, 'Breakfast');
      expect(updated.time, '8:00 AM');
      expect(updated.description, 'Oats with banana and protein powder');
    });
  });

  group('DietDay Model Tests', () {
    late DietDay dietDay;

    setUp(() {
      dietDay = DietDay(
        day: 'Monday',
        isRestDay: false,
        meals: [
          Meal(
            type: 'Breakfast',
            time: '8:00 AM',
            description: 'Oats with banana',
            isCompleted: false,
          ),
          Meal(
            type: 'Lunch',
            time: '12:30 PM',
            description: 'Grilled chicken',
            isCompleted: true,
          ),
        ],
      );
    });

    test('DietDay should have readable properties', () {
      expect(dietDay.day, 'Monday');
      expect(dietDay.isRestDay, false);
      expect(dietDay.meals.length, 2);
      expect(dietDay.meals[0].type, 'Breakfast');
    });

    test('DietDay should convert to map correctly', () {
      final map = dietDay.toMap();

      expect(map['day'], 'Monday');
      expect(map['isRestDay'], false);
      expect(map['meals'], isA<List>());
      expect(map['meals'].length, 2);
    });

    test('DietDay should create rest day with empty meals', () {
      final restDay = DietDay(day: 'Sunday', isRestDay: true, meals: []);

      expect(restDay.day, 'Sunday');
      expect(restDay.isRestDay, true);
      expect(restDay.meals.isEmpty, true);
    });

    test('DietDay should create from map correctly', () {
      final data = {
        'day': 'Tuesday',
        'isRestDay': false,
        'meals': [
          {
            'type': 'Breakfast',
            'time': '7:00 AM',
            'description': 'Eggs and toast',
            'isCompleted': false,
          },
        ],
      };

      final created = DietDay.fromMap(data);

      expect(created.day, 'Tuesday');
      expect(created.isRestDay, false);
      expect(created.meals.length, 1);
      expect(created.meals[0].type, 'Breakfast');
    });

    test('DietDay should handle rest day with no meals', () {
      final data = {'day': 'Saturday', 'isRestDay': true, 'meals': []};

      final created = DietDay.fromMap(data);

      expect(created.day, 'Saturday');
      expect(created.isRestDay, true);
      expect(created.meals.isEmpty, true);
    });
  });

  group('DietPlan Model Tests', () {
    late DietPlan dietPlan;

    setUp(() {
      dietPlan = DietPlan(
        userId: 'user123',
        days: [
          DietDay(
            day: 'Monday',
            isRestDay: false,
            meals: [
              Meal(
                type: 'Breakfast',
                time: '8:00 AM',
                description: 'Oats with banana',
                isCompleted: false,
              ),
            ],
          ),
          DietDay(day: 'Sunday', isRestDay: true, meals: []),
        ],
      );
    });

    test('DietPlan should have readable properties', () {
      expect(dietPlan.userId, 'user123');
      expect(dietPlan.days.length, 2);
      expect(dietPlan.days[0].day, 'Monday');
      expect(dietPlan.days[1].isRestDay, true);
    });

    test('DietPlan should convert to map correctly', () {
      final map = dietPlan.toMap();

      expect(map['userId'], 'user123');
      expect(map['days'], isA<List>());
      expect(map['days'].length, 2);
    });

    test('DietPlan should create from firestore correctly', () {
      final data = {
        'userId': 'user456',
        'days': [
          {
            'day': 'Friday',
            'isRestDay': false,
            'meals': [
              {
                'type': 'Dinner',
                'time': '6:00 PM',
                'description': 'Salmon with vegetables',
                'isCompleted': false,
              },
            ],
          },
        ],
      };

      final created = DietPlan.fromFirestore(data);

      expect(created.userId, 'user456');
      expect(created.days.length, 1);
      expect(created.days[0].day, 'Friday');
      expect(created.days[0].meals[0].type, 'Dinner');
    });

    test('DietPlan round-trip: toMap -> fromFirestore should be identical', () {
      final map = dietPlan.toMap();

      final reconstructed = DietPlan.fromFirestore(map);

      expect(reconstructed.userId, dietPlan.userId);
      expect(reconstructed.days.length, dietPlan.days.length);
      expect(reconstructed.days[0].day, dietPlan.days[0].day);
      expect(reconstructed.days[0].meals.length, dietPlan.days[0].meals.length);
    });
  });
}
