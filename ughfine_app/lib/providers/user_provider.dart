import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _firebaseUser != null;

  UserModel? get userModel => _userModel;

  bool get hasCompletedOnboarding =>
      _userModel?.hasCompletedOnboarding ?? false;

  UserProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;

      if (user != null) {
        _userModel = await _firestoreService.getUser(user.uid);
      } else {
        _userModel = null;
      }

      notifyListeners();
    });
  }

  Future<void> saveUserProfile(UserModel user) async {
    _userModel = user;
    notifyListeners();
    await _firestoreService.saveUser(user);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      await _authService.login(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      await _authService.register(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _friendlyError(String code) {
    return switch (code) {
      'user-not-found' => 'No account found with that email.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'invalid-credential' => 'Incorrect email or password. Please try again.',
      'email-already-in-use' => 'An account with that email already exists.',
      'weak-password' => 'Password must be at least 6 characters.',
      'invalid-email' => 'Please enter a valid email address.',
      'network-request-failed' => 'No internet connection. Please try again.',
      'too-many-requests' => 'Too many attempts. Please wait a moment and try again.',
      'user-disabled' => 'This account has been disabled.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
