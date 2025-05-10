import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

final usersProvider = StateNotifierProvider<UsersNotifier, List<User>>(
  (ref) => UsersNotifier(
    FirebaseFirestore.instance,
    fb_auth.FirebaseAuth.instance,
  ),
);

class UsersNotifier extends StateNotifier<List<User>> {
  final FirebaseFirestore db;
  final fb_auth.FirebaseAuth auth;

  UsersNotifier(this.db, this.auth) : super([]);

  Future<void> getAllUsers() async {
    final snapshot = await db.collection('users').get();
    final users = snapshot.docs.map((doc) => User.fromDoc(doc)).toList();
    state = users;
  }

  Future<void> addUser({
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
      final fbUser = await auth.createUserWithEmailAndPassword(
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

      await db.collection('users').doc(uid).set(newUser);

      final userModel = User.fromDoc(await db.collection('users').doc(uid).get());
      state = [...state, userModel];

    } catch (e) {
      print("Error al crear usuario: $e");
      rethrow;
    }
  }
}