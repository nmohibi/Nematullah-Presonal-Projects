import 'package:flutter/material.dart';
import '../models/workout_models.dart';
import '../services/firestore_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  WorkoutPlan? _workoutPlan;
  int _selectedDayIndex = 0;

  WorkoutPlan? get workoutPlan => _workoutPlan;
  int get selectedDayIndex => _selectedDayIndex;

  WorkoutDay? get selectedDay {
    if (_workoutPlan == null) return null;
    if (_selectedDayIndex >= _workoutPlan!.days.length) return null;
    return _workoutPlan!.days[_selectedDayIndex];
  }

  void setWorkoutPlan(WorkoutPlan plan) {
    _workoutPlan = plan;
    _selectedDayIndex = 0;
    notifyListeners();
  }

  Future<void> loadWorkoutPlan(String uid) async {
    final plan = await _firestoreService.getWorkoutPlan(uid);
    if (plan != null) {
      _workoutPlan = plan;
      _selectedDayIndex = 0;
      notifyListeners();
    }
  }

  void selectDay(int index) {
    _selectedDayIndex = index;
    notifyListeners();
  }
}
