import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_service.dart';

class UserService {
  final FirebaseService _firebase = FirebaseService.instance;

  Future<bool> login(String nic, String password) async {
    final nicKey = nic.trim().toUpperCase();

    try {
      await _firebase.signInAsAdmin();

      final valid = await _firebase.validateNicPassword(nicKey, password);
      if (!valid) {
        await _firebase.signOut();
        return false;
      }

      await _saveNic(nicKey);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-login-credentials') {
        final migrated = await _firebase.migrateLegacyUser(nicKey, password);
        if (migrated) {
          final valid = await _firebase.validateNicPassword(nicKey, password);
          if (!valid) {
            await _firebase.signOut();
            return false;
          }
          await _saveNic(nicKey);
          return true;
        }
        return false;
      }
      print('FirebaseAuthException: ${e.code} — ${e.message}');
      rethrow;
    } catch (e) {
      print(e);
      await _firebase.signOut();
      return false;
    }
  }

  Future<void> _saveNic(String nicKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(FirebaseService.loggedInNicKey, nicKey);
  }

  Future<bool> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nic = prefs.getString(FirebaseService.loggedInNicKey);
      if (nic == null || nic.isEmpty) {
        return false;
      }
      return FirebaseAuth.instance.currentUser != null;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String?> getLoggedInNic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(FirebaseService.loggedInNicKey);
  }

  Future<String?> requireLoggedInNic() async {
    await _firebase.ensureAuthenticated();
    return getLoggedInNic();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(FirebaseService.loggedInNicKey);
    await _firebase.signOut();
  }

  static String? messageForAuthError(FirebaseAuthException e) {
    final msg = e.message ?? '';
    if (msg.contains('CONFIGURATION_NOT_FOUND') || e.code == 'unknown') {
      return 'Firebase Authentication is not configured. In Firebase Console '
          '(project safe-a67e3): open Authentication → Get started → enable '
          'Email/Password, add your app SHA-1 fingerprint, then download a '
          'new google-services.json.';
    }
    if (e.code == 'operation-not-allowed') {
      return 'Email/Password sign-in is disabled. Enable it under '
          'Authentication → Sign-in method in Firebase Console.';
    }
    if (e.code == 'weak-password' ||
        msg.toLowerCase().contains('at least 6')) {
      return 'Firebase admin password must be at least 6 characters. '
          'Set admin@safeme.app password to SafeMe123 in Firebase Console.';
    }
    return null;
  }
}
