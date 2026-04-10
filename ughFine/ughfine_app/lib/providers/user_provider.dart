import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  bool get isLoading => false;
  bool get isLoggedIn => false;
  bool get hasCompletedOnboarding => false;
  String? get errorMessage => null;

  Future<bool> login({required String email, required String password}) async =>
      false;
  Future<bool> register({
    required String email,
    required String password,
  }) async => false;
}
