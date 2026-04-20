import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } on PlatformException catch (e) {
      throw FirebaseAuthException(
        code: _mapPlatformCode(e.code),
        message: e.message,
      );
    } catch (e) {
      throw FirebaseAuthException(code: 'unknown', message: e.toString());
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } on PlatformException catch (e) {
      throw FirebaseAuthException(
        code: _mapPlatformCode(e.code),
        message: e.message,
      );
    } catch (e) {
      throw FirebaseAuthException(code: 'unknown', message: e.toString());
    }
  }

  Future<void> logout() async => await _auth.signOut();

  String _mapPlatformCode(String code) {
    return switch (code.toUpperCase()) {
      'ERROR_INVALID_CREDENTIAL' ||
      'ERROR_WRONG_PASSWORD' => 'invalid-credential',
      'ERROR_USER_NOT_FOUND' => 'user-not-found',
      'ERROR_EMAIL_ALREADY_IN_USE' => 'email-already-in-use',
      'ERROR_WEAK_PASSWORD' => 'weak-password',
      'ERROR_INVALID_EMAIL' => 'invalid-email',
      'ERROR_USER_DISABLED' => 'user-disabled',
      'ERROR_NETWORK_REQUEST_FAILED' => 'network-request-failed',
      'ERROR_TOO_MANY_REQUESTS' => 'too-many-requests',
      _ => 'unknown',
    };
  }
}
