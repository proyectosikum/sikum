import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/presentation/providers/evolutions_by_patient_provider.dart';
import 'package:sikum/presentation/screens/patients/discharge_status_evaluator.dart';
import 'package:sikum/entities/patient.dart';

final dischargeStatusProvider =
    Provider.family<AsyncValue<DischargeResult>, Patient>((ref, patient) {
      final evolutionsAsync = ref.watch(
        evolutionsByPatientIdProvider(patient.id),
      );

      return evolutionsAsync.whenData((evolutions) {
        return getDischargeStatusWithDetails(patient, evolutions);
      });
    });
