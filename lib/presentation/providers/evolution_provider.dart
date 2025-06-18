import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/evolution.dart';

//Evoluciones de un paciente
final evolutionsStreamProvider = StreamProvider.family<List<Evolution>, String>(
  (ref, patientId) {
    final col = FirebaseFirestore.instance.collection('evolutions');
    return col
        .where('patientId', isEqualTo: patientId)
        .where('available', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Evolution.fromFirestore(d)).toList(),
        );
  },
);

//Detalle de una evolución específica
final evolutionDetailsProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, evolutionId) {
      final doc = FirebaseFirestore.instance
          .collection('evolutions')
          .doc(evolutionId);

      return doc.snapshots().map((snap) {
        if (!snap.exists) return null;
        final data = snap.data()!;
        return {
          'id': snap.id,
          'specialty': data['specialty'],
          'details': data['details'],
          'createdAt': data['createdAt'],
          'patientId': data['patientId'],
          'available': data['available'],
          'createdByUserId': data['createdByUserId'],
        };
      });
    });

class EvolutionActions {
  final String patientId;
  EvolutionActions(this.patientId);

  CollectionReference get _col =>
      FirebaseFirestore.instance.collection('evolutions');

  Future<void> addEvolution(Map<String, dynamic> payload) async {
    final now = FieldValue.serverTimestamp();
    final currentUser = FirebaseAuth.instance.currentUser;
    final createdBy = currentUser?.uid ?? 'unknown';

    await _col.add({
      'patientId': patientId,
      'specialty': payload['specialty'],
      'details': payload['details'],
      'available': true,
      'createdAt': now,
      'createdByUserId': createdBy,
    });
  }

  Future<void> updateEvolution(
    String evolutionId,
    Map<String, dynamic> newDetails,
  ) async {
    await _col.doc(evolutionId).update({
      'details': newDetails,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteEvolution(String evolutionId) async {
    await _col.doc(evolutionId).update({
      'available': false,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }
}

final evolutionActionsProvider = Provider.family<EvolutionActions, String>((
  ref,
  patientId,
) {
  return EvolutionActions(patientId);
});
