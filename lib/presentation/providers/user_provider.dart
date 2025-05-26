
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/user.dart';

/// 1) Lista de todos los usuarios
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
    return col.doc(userId).snapshots().map((snap) =>
        snap.exists ? User.fromDoc(snap) : null);
  } else {
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
  final _firestore = FirebaseFirestore.instance;

  Future<void> toggleAvailability(String id, bool newValue) {
    return _col.doc(id).update({'available': newValue});
  }

  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String dni,
    required String email,
    required String phone,
    required String provReg,
    required String specialty,
    required String role,
    required String adminEmail,
    required String adminPassword,
  }) async {
    try {
      // 1) Evita duplicados por DNI
      final existingUser = await _col.where('dni', isEqualTo: dni).get();
      if (existingUser.docs.isNotEmpty) {
        throw Exception('Ya existe un usuario con ese DNI.');
      }

      // 2) Crea el nuevo usuario
      final fbUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: dni,
      );
      final uid = fbUser.user!.uid;

      // 3) Guarda el perfil en Firestore
      final newUser = {
        'firstName': firstName,
        'lastName': lastName,
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

      // 4) Cierra sesión del usuario nuevo
      await _auth.signOut();

      // 5) Loguea nuevamente como admin
      await _auth.signInWithEmailAndPassword(
        email:    adminEmail,
        password: adminPassword,
      );
    } catch (e) {
      print("Error al crear usuario: $e");
      rethrow;
    }
  }

  Future<void> updateUser({
    required String id,
    required String firstName,
    required String lastName,
    required String dni,
    required String email,
    required String phone,
    required String provReg,
    required String specialty,
  }) async {
    try {
      await _firestore.collection('users').doc(id).update({
        'firstName': firstName,
        'lastName': lastName,
        'dni': dni,
        'email': email,
        'phone': phone,
        'provReg': provReg,
        'specialty': specialty,
      });
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  Future<User> getUserById(String id) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
    final data = doc.data();
    if (data == null) {
      throw Exception('Usuario no encontrado');
  }
  return User.fromMap(data, doc.id);
  }
}


final userActionsProvider = Provider<UserActions>((ref) {
  return UserActions();
});
