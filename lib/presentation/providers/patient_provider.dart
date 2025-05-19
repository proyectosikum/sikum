import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/patient.dart';

final patientProvider = StateNotifierProvider<PatientsNotifier, List<Patient>>(
  (ref) => PatientsNotifier(FirebaseFirestore.instance),
);

class PatientsNotifier extends StateNotifier<List<Patient>> {
  final FirebaseFirestore db;

  PatientsNotifier(this.db) : super([]);

  Future<void> getAllPatients() async {
    final query = db.collection('dischargeDataPatient').withConverter(
          fromFirestore: Patient.fromFirestore,
          toFirestore: (Patient patient, _) => patient.toFirestore(),
        );
    final patientsSnapshot = await query.get();

    
    state = patientsSnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addPatient(Patient patient) async {
    final doc = db.collection('dischargeDataPatient').doc();
    try {
      await doc.set(patient.toFirestore());
      state = [...state, patient];
    } catch (e) {
      print(e);
    }
  }
}
