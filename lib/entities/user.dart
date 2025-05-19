import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String dni;
  final String email;
  final String phone;
  final String provReg;
  final String specialty;
  final String role;
  final bool needsPasswordChange;
  final bool available;
  final String user;
  final String userId;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dni,
    required this.email,
    required this.phone,
    required this.provReg,
    required this.specialty,
    required this.role,
    required this.needsPasswordChange,
    required this.available,
    required this.user,
    required this.userId,
  });

  factory User.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return User(
      id: doc.id,
      firstName: data['firstName']        as String? ?? '',
      lastName: data['lastName']          as String? ?? '',
      dni: data['dni']                    as String? ?? '',
      email: data['email']                as String? ?? '',
      phone: data['phone']                as String? ?? '',
      provReg: data['provReg']            as String? ?? '',
      specialty: data['specialty']        as String? ?? '',
      role: data['role']                  as String? ?? '',
      needsPasswordChange:
          data['needsPasswordChange']     as bool?   ?? false,
      available: data['available']        as bool?   ?? false,
      user: data['user']                  as String? ?? '',
      userId: data['userId']              as String? ?? '',
    );
  }
}
