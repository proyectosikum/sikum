import 'package:cloud_firestore/cloud_firestore.dart';

class Evolution {
  final String id;
  final String patientId;
  final String specialty;
  final Map<String, dynamic> details;
  final DateTime createdAt;
  final String createdByUserId;
  final bool available;
  final DateTime? updatedAt;

  Evolution({
    required this.id,
    required this.patientId,
    required this.specialty,
    required this.details,
    required this.createdAt,
    required this.createdByUserId,
    required this.available,
    this.updatedAt,
  });

  factory Evolution.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Evolution(
      id: doc.id,
      patientId: data['patientId'] as String,
      specialty: data['specialty'] as String,
      details: Map<String, dynamic>.from(data['details'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdByUserId: data['createdByUserId'] as String,
      available: data['available'] as bool? ?? true,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'specialty': specialty,
      'details': details,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdByUserId': createdByUserId,
      'available': available,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }
}