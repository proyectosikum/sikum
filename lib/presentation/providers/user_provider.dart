import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/user.dart';


final usersStreamProvider = StreamProvider<List<User>>((ref) {
  final col = FirebaseFirestore.instance.collection('users');
  return col.snapshots().map((snap) =>
      snap.docs.map((doc) => User.fromDoc(doc)).toList());
});


final userDetailsStreamProvider =
    StreamProvider.family<User?, String?>((ref, userId) {
  final col = FirebaseFirestore.instance.collection('users');

  print('DEBUG userDetailsStreamProvider: userId = "$userId"');

  if (userId != null && userId.isNotEmpty) {
    print('DEBUG: Buscando usuario por ID: $userId');

    
    return col.doc(userId).snapshots().map((snap) {
      print('DEBUG: Snapshot exists: ${snap.exists}');
      if (snap.exists) {
        print('DEBUG: Datos del documento: ${snap.data()}');
      }

      return snap.exists ? User.fromDoc(snap) : null;
    }).handleError((error) {
      print('ERROR en userDetailsStreamProvider: $error');
      throw error;
    });
  } else {
    print('DEBUG: userId es null o vacío, buscando por email del auth');

  
    final auth = fb_auth.FirebaseAuth.instance;
    return auth.authStateChanges().asyncExpand((fbUser) {
      if (fbUser == null) {
        print('DEBUG: No hay usuario autenticado');
        return Stream.value(null);
      }

      print('DEBUG: Buscando usuario por email: ${fbUser.email}');

      return col
          .where('email', isEqualTo: fbUser.email)
          .limit(1)
          .snapshots()
          .map((qs) {
            print('DEBUG: Documentos encontrados por email: ${qs.docs.length}');
            return qs.docs.isNotEmpty ? User.fromDoc(qs.docs.first) : null;
          })
          .handleError((error) {
            print('ERROR buscando por email: $error');
            throw error;
          });
    });
  }
});


final userByIdStreamProvider = StreamProvider.family<User?, String>((ref, userId) {
  final col = FirebaseFirestore.instance.collection('users');

  print('DEBUG userByIdStreamProvider: userId = "$userId"');

  return col.doc(userId).snapshots().map((snap) {
    print('DEBUG userByIdStreamProvider: Snapshot exists: ${snap.exists}');
    if (snap.exists) {
      print('DEBUG userByIdStreamProvider: Datos: ${snap.data()}');
      return User.fromDoc(snap);
    } else {
      print('DEBUG userByIdStreamProvider: Documento no existe');
      return null;
    }
  }).handleError((error) {
    print('ERROR en userByIdStreamProvider: $error');
    throw error;
  });
});


class UserActions {
  final _col = FirebaseFirestore.instance.collection('users');
  final _firestore = FirebaseFirestore.instance;

  Future<void> toggleAvailability(String id, bool newValue) {
    return _col.doc(id).update({'available': newValue});
  }

 
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _col.doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error verificando si el usuario existe: $e');
      return false;
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

  Future<FirebaseApp> _initSecondaryApp() {
    return Firebase.initializeApp(
      name: 'Secondary',
      options: Firebase.app().options,
    );
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
}) async {
  try {
    if (!email.contains('@')) {
      throw 'El correo electrónico ingresado no es válido.';
    }

    final dniRegExp = RegExp(r'^\d{7,8}$');
    if (!dniRegExp.hasMatch(dni)) {
      throw 'El DNI debe tener 7 u 8 números y no contener letras ni símbolos.';
    }

    final existingUser = await _col.where('dni', isEqualTo: dni).get();
    if (existingUser.docs.isNotEmpty) {
      throw 'Ya existe un usuario con ese DNI.';
    }

    final existingEmail = await _col.where('email', isEqualTo: email).get();
    if (existingEmail.docs.isNotEmpty) {
      throw 'Ya existe un usuario con ese email.';
    }

    final secondaryApp = await _initSecondaryApp();
    final secondaryAuth = fb_auth.FirebaseAuth.instanceFor(app: secondaryApp);

    final fbUser = await secondaryAuth.createUserWithEmailAndPassword(
      email: email,
      password: dni,
    );
    final uid = fbUser.user!.uid;

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

    await secondaryAuth.signOut();
    await secondaryApp.delete();
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
    if (firstName.trim().isEmpty ||
        lastName.trim().isEmpty ||
        dni.trim().isEmpty ||
        email.trim().isEmpty ||
        provReg.trim().isEmpty ||
        specialty.trim().isEmpty) {
      throw 'Ningún campo obligatorio puede quedar vacío.';
    }

    final dniRegExp = RegExp(r'^\d{7,8}$');
    if (!dniRegExp.hasMatch(dni)) {
      throw 'El DNI debe tener 7 u 8 números y no contener letras ni símbolos.';
    }

    if (!email.contains('@')) {
      throw 'El email debe contener "@"';
    }

    final dniQuery = await _firestore
        .collection('users')
        .where('dni', isEqualTo: dni)
        .get();
    final dniDuplicado = dniQuery.docs.any((doc) => doc.id != id);
    if (dniDuplicado) {
      throw 'El DNI ya está registrado en otro usuario.';
    }

    final emailQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    final emailDuplicado = emailQuery.docs.any((doc) => doc.id != id);
    if (emailDuplicado) {
      throw 'El email ya está registrado en otro usuario.';
    }

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
    print("Error al actualizar usuario: $e");
    rethrow;
  }
}

  Future<List<User>> getAllUsers() async {
  try {
    final querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs.map((doc) => User.fromDoc(doc)).toList();
  } catch (e) {
    throw Exception('Error al obtener usuarios: $e');
    }
  }
}

final userActionsProvider = Provider<UserActions>((ref) {
  return UserActions();
});
