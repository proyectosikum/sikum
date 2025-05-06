import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> login(String username, String password) async {
    try {
      final query = await _db
        .collection('usuarios')
        .where('usuario', isEqualTo: username)
        .limit(1)
        .get();

      if (query.docs.isEmpty) {
        return false;
      }

      final data = query.docs.first.data();
      final storedPassword = data['contrasenia'] as String;

      if (storedPassword == password) {
        return true;
      }

      final inputHash = sha256.convert(utf8.encode(password)).toString();
      return inputHash == storedPassword;
    } catch (e) {
      debugPrint('AuthService.login error: $e');
      return false;
    }
  }
}
