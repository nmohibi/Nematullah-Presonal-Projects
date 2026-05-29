import 'package:flutter/material.dart';
import '../models/diet_model.dart';
import '../services/firestore_service.dart';

class DietProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  DietProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  DietPlan? _dietPlan;
  int _selectedDayIndex = 0;

  DietPlan? get dietPlan => _dietPlan;
  int get selectedDayIndex => _selectedDayIndex;

  DietDay? get selectedDay {
    if (_dietPlan == null) return null;
    if (_selectedDayIndex >= _dietPlan!.days.length) return null;
    return _dietPlan!.days[_selectedDayIndex];
  }

  void setDietPlan(DietPlan plan) {
    _dietPlan = plan;
    _selectedDayIndex = 0;
    notifyListeners();
  }

  Future<void> loadDietPlan(String uid) async {
    final plan = await _firestoreService.getDietPlan(uid);
    if (plan != null) {
      _dietPlan = plan;
      _selectedDayIndex = 0;
      notifyListeners();
    }
  }

  void selectDay(int index) {
    if (_dietPlan == null) return;
    if (index < 0 || index >= _dietPlan!.days.length) return;
    _selectedDayIndex = index;
    notifyListeners();
  }

  Future<void> toggleMeal({
    required String uid,
    required int mealIndex,
    required bool isCompleted,
  }) async {
    if (_dietPlan == null) return;

    final day = _dietPlan!.days[_selectedDayIndex];
    final updatedMeals = List<Meal>.from(day.meals);

    updatedMeals[mealIndex] = updatedMeals[mealIndex].copyWith(
      isCompleted: isCompleted,
    );

    final updatedDays = List<DietDay>.from(_dietPlan!.days);
    updatedDays[_selectedDayIndex] = DietDay(
      day: day.day,
      isRestDay: day.isRestDay,
      meals: updatedMeals,
    );
    _dietPlan = DietPlan(userId: _dietPlan!.userId, days: updatedDays);

    notifyListeners();

    await _firestoreService.updateMealCompletion(
      uid: uid,
      dayIndex: _selectedDayIndex,
      mealIndex: mealIndex,
      isCompleted: isCompleted,
    );
  }
}
