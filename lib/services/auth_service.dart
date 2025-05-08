import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class LoginResult {
  final bool success;
  final bool needsChange;
  final String role;

  LoginResult(
    this.success, {
    this.needsChange = false,
    this.role = 'user',
  });
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Login
  Future<LoginResult> login(String username, String password) async {
    try {
      final q = await _db
          .collection('usuarios')
          .where('user', isEqualTo: username)
          .limit(1)
          .get();
      if (q.docs.isEmpty) return LoginResult(false);

      final data = q.docs.first.data();
      final email = data['email'] as String?;
      final needs = data['needsPasswordChange'] as bool? ?? false;
      final role = data['role'] as String? ?? 'user';

      if (email == null) return LoginResult(false);

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return LoginResult(true, needsChange: needs, role: role);
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService.login error: ${e.code} – ${e.message}');
      return LoginResult(false);
    } catch (e) {
      debugPrint('AuthService.login unexpected: $e');
      return LoginResult(false);
    }
  }

  /// Logout
  Future<void> logout() => _auth.signOut();

  /// Recuperación de contraseña
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'AuthService.sendPasswordResetEmail error: ${e.code} – ${e.message}');
      return false;
    } catch (e) {
      debugPrint('AuthService.sendPasswordResetEmail unexpected: $e');
      return false;
    }
  }

  /// Cambio de contraseña
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return false;

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(newPassword);

      final q = await _db
          .collection('usuarios')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        await q.docs.first.reference.update({'needsPasswordChange': false});
      }
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'AuthService.changePassword error: ${e.code} – ${e.message}');
      return false;
    } catch (e) {
      debugPrint('AuthService.changePassword unexpected: $e');
      return false;
    }
  }
}
