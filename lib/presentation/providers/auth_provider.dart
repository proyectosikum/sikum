// lib/presentation/providers/auth_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum LoginStatus { success, invalid, inactive }

class LoginResult {
  final LoginStatus status;
  final bool needsChange;
  final String role;
  final String firstName;
  final String lastName;

  LoginResult(
    this.status, {
    this.needsChange = false,
    this.role = 'user',
    this.firstName = '',
    this.lastName = '',
  });
}

/// El único StreamProvider que escucha Auth y luego Firestore
final authProfileProvider = StreamProvider<LoginResult?>((ref) {
  final auth = FirebaseAuth.instance;
  final db   = FirebaseFirestore.instance;

  return auth.authStateChanges().asyncExpand((fbUser) {
    if (fbUser == null) {
      // Emito null inmediatamente en logout
      return Stream.value(null);
    }
    // Con sesión activa, escucho su perfil en Firestore.
    return db
      .collection('users')
      .doc(fbUser.uid)
      .snapshots()
      .map((snap) {
        if (!snap.exists) return null;
        final data      = snap.data()!;
        final available = data['available'] as bool? ?? false;
        final needs     = data['needsPasswordChange'] as bool? ?? false;
        final role      = data['role'] as String? ?? 'user';
        final firstName = data['firstName'] as String? ?? '';
        final lastName  = data['lastName']  as String? ?? '';
        return LoginResult(
          available ? LoginStatus.success : LoginStatus.inactive,
          needsChange: needs,
          role: role,
          firstName: firstName,
          lastName: lastName,
        );
      });
  });
});

/// Provider de acciones de Auth
final authActionsProvider = Provider<AuthActions>((ref) => AuthActions());

class AuthActions {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<LoginResult> login(String username, String password) async {
    try {
      final q = await _db
          .collection('users')
          .where('user', isEqualTo: username)
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        return LoginResult(LoginStatus.invalid);
      }

      final data      = q.docs.first.data();
      final email     = data['email'] as String?;
      final available = data['available'] as bool? ?? false;
      final needs     = data['needsPasswordChange'] as bool? ?? false;
      final role      = data['role'] as String? ?? 'user';

      if (!available) {
        return LoginResult(LoginStatus.inactive, needsChange: needs, role: role);
      }
      if (email == null) {
        return LoginResult(LoginStatus.invalid);
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return LoginResult(
        LoginStatus.success,
        needsChange: needs,
        role: role,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthActions.login error: ${e.code} – ${e.message}');
      return LoginResult(LoginStatus.invalid);
    } catch (e) {
      debugPrint('AuthActions.login unexpected: $e');
      return LoginResult(LoginStatus.invalid);
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('AuthActions.sendPasswordResetEmail error: $e');
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return false;
    try {
      final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      final q = await _db
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
      if (q.docs.isNotEmpty) {
        await q.docs.first.reference.update({'needsPasswordChange': false});
      }
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('AuthActions.changePassword error: $e');
      return false;
    }
  }
}
