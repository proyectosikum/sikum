import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikum/entities/evolution.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final evolutionsStreamProvider = StreamProvider.family<List<Evolution>, String>((ref, patientId) {
  final col = ref.read(firestoreProvider).collection('evolutions');
  return col
    .where('available', isEqualTo: true)
    .where('patientId', isEqualTo: patientId)
    .orderBy('createdAt', descending: true)
    .snapshots()                                  // en lugar de .get()
    .map((snap) =>
      snap.docs.map((d) => Evolution.fromFirestore(d)).toList()
    );
});
