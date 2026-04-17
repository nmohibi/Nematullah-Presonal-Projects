import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ughfine_app/models/diet_model.dart';
import 'package:ughfine_app/providers/diet_provider.dart';
import 'package:ughfine_app/services/firestore_service.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  group('DietProvider Tests', () {
    late DietProvider provider;
    late MockFirestoreService mockFirestoreService;
    late DietPlan testPlan;

    setUp(() {
      mockFirestoreService = MockFirestoreService();

      testPlan = DietPlan(
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
              Meal(
                type: 'Lunch',
                time: '12:30 PM',
                description: 'Grilled chicken',
                isCompleted: false,
              ),
            ],
          ),
          DietDay(
            day: 'Sunday',
            isRestDay: true,
            meals: [],
          ),
        ],
      );

      provider = DietProvider();
    });

    test('DietProvider should have null dietPlan on init', () {
      expect(provider.dietPlan, isNull);
    });

    test('DietProvider should have selectedDayIndex of 0 on init', () {
      expect(provider.selectedDayIndex, 0);
    });

    test('DietProvider setDietPlan should store plan and notify', () {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      provider.setDietPlan(testPlan);

      expect(provider.dietPlan, testPlan);
      expect(provider.selectedDayIndex, 0);
      expect(notifyCount, 1);
    });

    test('DietProvider selectedDay should return current day', () {
      provider.setDietPlan(testPlan);

      final selectedDay = provider.selectedDay;

      expect(selectedDay, isNotNull);
      expect(selectedDay?.day, 'Monday');
      expect(selectedDay?.meals.length, 2);
    });

    test('DietProvider selectDay should change selectedDayIndex', () {
      provider.setDietPlan(testPlan);
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      provider.selectDay(1);

      expect(provider.selectedDayIndex, 1);
      expect(provider.selectedDay?.day, 'Sunday');
      expect(notifyCount, 1);
    });

    test('DietProvider selectedDay should return null if plan is null', () {
      final selectedDay = provider.selectedDay;

      expect(selectedDay, isNull);
    });

    test('DietProvider selectDay should validate index bounds', () {
      provider.setDietPlan(testPlan);

      provider.selectDay(100);

      expect(provider.selectedDayIndex, 0);
    });

    test('DietProvider selectDay should not allow negative index', () {
      provider.setDietPlan(testPlan);

      provider.selectDay(-1);

      expect(provider.selectedDayIndex, 0);
    });

    test('DietProvider toggleMeal should update meal completion status', () async {
      provider.setDietPlan(testPlan);
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      when(mockFirestoreService.updateMealCompletion(
        uid: 'user123',
        dayIndex: 0,
        mealIndex: 0,
        isCompleted: true,
      )).thenAnswer((_) async {});

      await provider.toggleMeal(
        uid: 'user123',
        mealIndex: 0,
        isCompleted: true,
      );

      expect(provider.selectedDay?.meals[0].isCompleted, true);
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('DietProvider toggleMeal should preserve other meal data', () async {
      provider.setDietPlan(testPlan);
      final originalMeal = provider.selectedDay?.meals[0];

      when(mockFirestoreService.updateMealCompletion(
        uid: 'user123',
        dayIndex: 0,
        mealIndex: 0,
        isCompleted: true,
      )).thenAnswer((_) async {});

      await provider.toggleMeal(
        uid: 'user123',
        mealIndex: 0,
        isCompleted: true,
      );

      final updatedMeal = provider.selectedDay?.meals[0];

      expect(updatedMeal?.type, originalMeal?.type);
      expect(updatedMeal?.time, originalMeal?.time);
      expect(updatedMeal?.description, originalMeal?.description);
      expect(updatedMeal?.isCompleted, true);
    });

    test('DietProvider should notify listeners when plan is set', () {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      provider.setDietPlan(testPlan);
      provider.setDietPlan(testPlan);

      expect(notifyCount, 2);
    });

    test('DietProvider should reset selectedDayIndex when setting new plan', () {
      provider.setDietPlan(testPlan);
      provider.selectDay(1);
      expect(provider.selectedDayIndex, 1);

      provider.setDietPlan(testPlan);

      expect(provider.selectedDayIndex, 0);
    });
  });
}
