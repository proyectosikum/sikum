// lib/presentation/providers/patient_providers.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/patient.dart';

/// ----------------------------------------
/// 1) StreamProvider para la lista de pacientes
///    escucha en tiempo real todos los docs
/// ----------------------------------------
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


/// ----------------------------------------
/// 2) StreamProvider para el detalle de un paciente
///    escucha en tiempo real el doc `/dischargeDataPatient/{id}`
/// ----------------------------------------
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


/// ----------------------------------------
/// 3) Provider para acciones (añadir pacientes)
/// ----------------------------------------
class PatientActions {
  final CollectionReference<Patient> _col;

  PatientActions([FirebaseFirestore? db])
      : _col = (db ?? FirebaseFirestore.instance)
          .collection('dischargeDataPatient')
          .withConverter<Patient>(
            fromFirestore: Patient.fromFirestore,
            toFirestore: (p, _) => p.toFirestore(),
          );

  /// Agrega un paciente y deja que el StreamProvider lo recoja automáticamente
  Future<void> addPatient(Patient patient) async {
    try {
      // Obtener el usuario actual de Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      final createdBy = currentUser?.uid ?? 'unknown';
      
      // Crear una copia del patient con el createdByUserId actualizado
      final patientWithCreatedBy = Patient(
        id: patient.id,
        firstName: patient.firstName,
        lastName: patient.lastName,
        dni: patient.dni,
        medicalRecordNumber: patient.medicalRecordNumber,
        available: patient.available,
        createdByUserId: createdBy, // Aquí se asigna automáticamente
        createdAt: patient.createdAt,
      );
      
      await _col.add(patientWithCreatedBy);
    } catch (e) {
      debugPrint('Error al agregar paciente: $e');
      rethrow;
    }
  }
}

final patientActionsProvider = Provider<PatientActions>((ref) {
  return PatientActions();
});