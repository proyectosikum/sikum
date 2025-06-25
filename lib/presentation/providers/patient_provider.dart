import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/birth_data.dart';
import 'package:sikum/entities/patient.dart';


final patientsStreamProvider = StreamProvider<List<Patient>>((ref) {
  final col = FirebaseFirestore.instance
      .collection('dischargeDataPatient')
      .withConverter<Patient>(
        fromFirestore: Patient.fromFirestore,
        toFirestore: (p, _) => p.toFirestore(),
      );

  return col
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.data()).toList());
});



final patientDetailsStreamProvider =
    StreamProvider.family<Patient?, String>((ref, patientId) {
  final doc = FirebaseFirestore.instance
      .collection('dischargeDataPatient')
      .withConverter<Patient>(
        fromFirestore: Patient.fromFirestore,
        toFirestore: (p, _) => p.toFirestore(),
      )
      .doc(patientId);

  return doc
      .snapshots()
      .map((snap) => snap.data());
});



class PatientActions {
  final CollectionReference<Patient> _col;

  PatientActions([FirebaseFirestore? db])
      : _col = (db ?? FirebaseFirestore.instance)
          .collection('dischargeDataPatient')
          .withConverter<Patient>(
            fromFirestore: Patient.fromFirestore,
            toFirestore: (p, _) => p.toFirestore(),
          );

  Future<void> addPatient(Patient patient) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final createdBy = currentUser?.uid ?? 'unknown';
      
      final patientWithCreatedBy = Patient(
        id: patient.id,
        firstName: patient.firstName,
        lastName: patient.lastName,
        dni: patient.dni,
        medicalRecordNumber: patient.medicalRecordNumber,
        available: patient.available,
        createdByUserId: createdBy,
        createdAt: patient.createdAt,
      );
      
      await _col.add(patientWithCreatedBy);
    } catch (e) {
      debugPrint('Error al agregar paciente: $e');
      rethrow;
    }
  }



  Future<void> updatePatient(Patient patient) async {
    try {
      final docRef = _col.doc(patient.id);
      await docRef.update(patient.toFirestore());
    } catch (e) {
      debugPrint('Error al actualizar paciente: $e');
      rethrow;
    }
  }

  Future<void> submitBirthData(String patientId, BirthData data) async {

    try {
      final docRef = FirebaseFirestore.instance.collection('dischargeDataPatient').doc(patientId);
      
      await docRef.set({
        'birthData': data.toMap(),
      }, SetOptions(merge: true));
      print('Guardado en la DB');
      
    } catch (e) {
      throw Exception('Error al guardar datos maternos: $e');
    }
  }
  
  Future<void> closeHospitalization(String patientId, Map<String, dynamic> closureData) async {
    final docRef = FirebaseFirestore.instance.collection('dischargeDataPatient').doc(patientId);
    await docRef.set({
      'closureOfHospitalization': closureData,
      'available': false,
    }, SetOptions(merge: true));
  }

  

}

final patientActionsProvider = Provider<PatientActions>((ref) {
  return PatientActions();
});