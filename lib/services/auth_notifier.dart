import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthChangeNotifier extends ChangeNotifier {
  String? role;
  bool needsChange = false;

  AuthChangeNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        role = null;
        needsChange = false;
        notifyListeners();
      } else {
        final q = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (q.docs.isNotEmpty) {
          final data = q.docs.first.data();
          role = data['role'] as String? ?? 'user';
          needsChange =
              data['needsPasswordChange'] as bool? ?? false;
        } else {
          role = 'user';
          needsChange = false;
        }
        notifyListeners();
      }
    });
  }
}
