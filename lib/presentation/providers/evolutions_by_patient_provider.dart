import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikum/entities/evolution.dart';

final evolutionsByPatientIdProvider = StreamProvider.family<List<Evolution>, String>((ref, patientId) {
  final snapshots = FirebaseFirestore.instance
      .collection('evolutions')
      .where('patientId', isEqualTo: patientId)
      .snapshots();

  return snapshots.map((query) {
    return query.docs.map((doc) => Evolution.fromFirestore(doc)).toList();
  });
});
