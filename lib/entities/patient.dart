import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikum/entities/birth_data.dart';

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
  final Map<String, dynamic>? maternalData;
  final BirthData? birthData;

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
    this.maternalData,
    this.birthData,
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
      maternalData: data['maternalData'],
      birthData: data['birthData'] != null ? BirthData.fromMap(data['birthData']) : BirthData(),
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
      'birthData': birthData?.toMap(),
    };
  }

  Map<String, dynamic> toMap() {
  final map = toFirestore();
  map['maternalData'] = maternalData;
  return map;
}

}
