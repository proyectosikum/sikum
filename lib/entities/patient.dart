import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final int dni;
  final int medicalRecordNumber;
  final bool available;
  final String? createdByUserId;
  final DateTime? createdAt;
  final String? modifiedByUserId;
  final DateTime? modifiedAt;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dni,
    required this.medicalRecordNumber,
    required this.available,
    this.createdByUserId,
    this.createdAt,
    this.modifiedByUserId,
    this.modifiedAt,
  });

  factory Patient.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return Patient(
      id: doc.id,
      firstName: data['firstName'],
      lastName: data['lastName'],
      dni: data['dni'],
      medicalRecordNumber: data['medicalRecordNumber'],
      available: data['available'],
      createdByUserId: data['createdByUserId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      modifiedByUserId: data['modifiedByUserId'],
      modifiedAt: (data['modifiedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dni': dni,
      'medicalRecordNumber': medicalRecordNumber,
      'available': available,
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (createdAt != null) 'createdAt': createdAt,
      if (modifiedByUserId != null) 'modifiedByUserId': modifiedByUserId,
      if (modifiedAt != null) 'modifiedAt': modifiedAt,
    };
  }
}
