import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isAuthenticated => _auth.currentUser != null;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw getReadableAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred during login. Please try again.';
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw getReadableAuthError(e);
    } catch (e) {
      throw 'Unable to send password reset email. Please try again.';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('[AuthService] Error during sign out: $e');
      rethrow;
    }
  }

  /// Map Firebase Auth exception codes to clean, human-readable messages
  static String getReadableAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No admin account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please verify your credentials and try again.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'user-disabled':
        return 'This admin account has been suspended or disabled.';
      case 'too-many-requests':
        return 'Access temporarily blocked due to multiple failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled for this project.';
      default:
        return e.message ?? 'Authentication failed (${e.code}). Please try again.';
    }
  }
}
