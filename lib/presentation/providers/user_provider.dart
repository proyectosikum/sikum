
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/user.dart';

/// 1) Lista de todos los usuarios, cada uno toma su doc.id en el constructor
final usersStreamProvider = StreamProvider<List<User>>((ref) {
  final col = FirebaseFirestore.instance.collection('users');
  return col.snapshots().map((snap) =>
      snap.docs.map((doc) => User.fromDoc(doc)).toList());
});

/// 2) Detalle de usuario
final userDetailsStreamProvider =
    StreamProvider.family<User?, String?>((ref, userId) {
  final col = FirebaseFirestore.instance.collection('users');

  if (userId != null) {
    // Escucha directamente /users/{userId}
    return col.doc(userId).snapshots().map((snap) =>
        snap.exists ? User.fromDoc(snap) : null);
  } else {
    // Busca por email del auth.currentUser
    final auth = fb_auth.FirebaseAuth.instance;
    return auth.authStateChanges().asyncExpand((fbUser) {
      if (fbUser == null) return Stream.value(null);
      return col
          .where('email', isEqualTo: fbUser.email)
          .limit(1)
          .snapshots()
          .map((qs) =>
              qs.docs.isNotEmpty ? User.fromDoc(qs.docs.first) : null);
    });
  }
});

/// 3) Acciones sobre usuarios
class UserActions {
  final _col = FirebaseFirestore.instance.collection('users');
  final _auth = fb_auth.FirebaseAuth.instance;

  Future<void> toggleAvailability(String id, bool newValue) {
    return _col.doc(id).update({'available': newValue});
  }

  Future<void> createUser({
    required String name,
    required String surname,
    required String dni,
    required String email,
    required String phone,
    required String provReg,
    required String specialty,
    required String role,
  }) async {
    try {
      final fbUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: dni,
      );

      final uid = fbUser.user!.uid;

      final newUser = {
        'name': name,
        'surname': surname,
        'dni': dni,
        'email': email,
        'phone': phone,
        'provReg': provReg,
        'specialty': specialty,
        'role': role,
        'needsPasswordChange': true,
        'available': true,
        'user': dni,
        'userId': uid,
      };

      await _col.doc(uid).set(newUser);

    } catch (e) {
      print("Error al crear usuario: $e");
      rethrow;
    }
  }
}


final userActionsProvider = Provider<UserActions>((ref) {
  return UserActions();
});
