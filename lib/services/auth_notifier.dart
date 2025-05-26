import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthChangeNotifier extends ChangeNotifier {
  String? role;
  bool needsChange = false;

  String? firstName;
  String? lastName;

  String get displayName {
    final fn = firstName?.trim() ?? '';
    final sn = lastName?.trim() ?? '';
    if (fn.isEmpty && sn.isEmpty) return 'Usuario';
    return '$fn${sn.isEmpty ? '' : ' '}$sn';
  }

  AuthChangeNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        role = null;
        needsChange = false;
        firstName = null;
        lastName = null;
        notifyListeners();
      } else {
        final q = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (q.docs.isNotEmpty) {
          final data = q.docs.first.data();
          role = data['role'] as String? ?? 'user';
          needsChange = data['needsPasswordChange'] as bool?   ?? false;
          firstName = data['firstName'] as String? ?? '';
          lastName = data['lastName'] as String? ?? '';
        } else {
          role = 'user';
          needsChange = false;
          firstName = '';
          lastName = '';
        }
        notifyListeners();
      }
    });
  }
}
