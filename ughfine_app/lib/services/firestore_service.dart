import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/workout_models.dart';
import '../models/diet_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromFirestore(doc.data()!, uid);
  }

  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    await _db.collection('workoutPlans').doc(plan.userId).set(plan.toMap());
  }

  Future<WorkoutPlan?> getWorkoutPlan(String uid) async {
    final doc = await _db.collection('workoutPlans').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return WorkoutPlan.fromFirestore(doc.data()!);
  }

  Future<void> saveDietPlan(DietPlan plan) async {
    await _db.collection('dietPlans').doc(plan.userId).set(plan.toMap());
  }

  Future<DietPlan?> getDietPlan(String uid) async {
    final doc = await _db.collection('dietPlans').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return DietPlan.fromFirestore(doc.data()!);
  }

  Future<void> updateMealCompletion({
    required String uid,
    required int dayIndex,
    required int mealIndex,
    required bool isCompleted,
  }) async {
    final plan = await getDietPlan(uid);
    if (plan == null) return;

    final updatedDays = List<DietDay>.from(plan.days);
    final day = updatedDays[dayIndex];
    final updatedMeals = List<Meal>.from(day.meals);
    updatedMeals[mealIndex] = updatedMeals[mealIndex].copyWith(
      isCompleted: isCompleted,
    );
    updatedDays[dayIndex] = DietDay(
      day: day.day,
      isRestDay: day.isRestDay,
      meals: updatedMeals,
    );

    await saveDietPlan(DietPlan(userId: uid, days: updatedDays));
  }
}
