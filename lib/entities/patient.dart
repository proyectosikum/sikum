// lib/domain/patient.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final String lastName;
  final int dni;
  final int medicalRecordNumber;
  final bool available;

  Patient({
    required this.id,
    required this.name,
    required this.lastName,
    required this.dni,
    required this.medicalRecordNumber,
    required this.available,
  });

  factory Patient.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return Patient(
      id: doc.id,
      name: data['firstName'],
      lastName: data['lastName'],
      dni: data['dni'],
      medicalRecordNumber: data['medicalRecordNumber'],
      available: data['available'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': name,
      'lastName': lastName,
      'dni': dni,
      'medicalRecordNumber': medicalRecordNumber,
      'available': available,
    };
  }
}
