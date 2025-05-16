import 'package:cloud_firestore/cloud_firestore.dart';

class Evolution {
  final String id;
  final String specialty;
  final DateTime createdAt;

  Evolution({
    required this.id,
    required this.specialty,
    required this.createdAt,
  });

  factory Evolution.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    // final details = data['details'] as Map<String, dynamic>;
    return Evolution(
      id: doc.id,
      specialty: data['specialty'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
