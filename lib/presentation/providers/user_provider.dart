// lib/presentation/providers/user_provider.dart

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

/// 2) Detalle de usuario - MEJORADO CON DEBUG
final userDetailsStreamProvider =
    StreamProvider.family<User?, String?>((ref, userId) {
  final col = FirebaseFirestore.instance.collection('users');

  print('DEBUG userDetailsStreamProvider: userId = "$userId"');

  if (userId != null && userId.isNotEmpty) {
    print('DEBUG: Buscando usuario por ID: $userId');
    
    // Escucha directamente /users/{userId}
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
    
    // Busca por email del auth.currentUser
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

/// 3) Provider alternativo para casos específicos donde sabemos que el userId no es null
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

/// 4) Acciones sobre usuarios
class UserActions {
  final _col = FirebaseFirestore.instance.collection('users');
  final _auth = fb_auth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> toggleAvailability(String id, bool newValue) {
    return _col.doc(id).update({'available': newValue});
  }

  // Método para verificar si un usuario existe
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _col.doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error verificando si el usuario existe: $e');
      return false;
    }
  }

  // Método para obtener usuario de forma async (alternativa)
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _col.doc(userId).get();
      return doc.exists ? User.fromDoc(doc) : null;
    } catch (e) {
      print('Error obteniendo usuario: $e');
      return null;
    }
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