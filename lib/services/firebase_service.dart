import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      debugPrint('[FirebaseService] Successfully initialized Firebase');
    } catch (e) {
      debugPrint('[FirebaseService] Firebase initialization notice: $e');
      // Set initialized true if already initialized
      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
      }
    }
  }
}
