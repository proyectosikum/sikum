import 'package:sikum/entities/patient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikum/entities/evolution.dart';

enum DischargeStatus {
  notReady, // gris
  ready,    // verde
  blocked,  // rojo
}

DischargeStatus getDischargeStatus(Patient patient, List<Evolution> evolutions) {
  final now = DateTime.now();
  final admittedAt = patient.createdAt; 
  if (admittedAt == null) {
  return DischargeStatus.notReady; // hay que definir qué pasa si no hay fecha (no debería no tener)
  }

  final hoursSinceAdmission = now.difference(admittedAt).inHours;

  if (hoursSinceAdmission < 48) return DischargeStatus.notReady;

  final maternalData = patient.maternalData;
  if (maternalData == null || maternalData['testResults'] == null) {
    return DischargeStatus.blocked;
  }

  final Map<String, String> testResults = Map<String, String>.from(maternalData['testResults']);

  final hasPendingTest = testResults.values.any((r) => r == 'Sin dato');
  if (hasPendingTest) return DischargeStatus.blocked;

  // falta tener completo el código de birthData!

/*   final birthData = patient.birthData;
  if (birthData == null || birthData.values.any((v) => v == null || v == '')) {
    return DischargeStatus.blocked;
  } */ 

final fei = evolutions.where((e) => e.specialty == 'enfermeria_fei');
if (fei.isEmpty) return DischargeStatus.blocked;

final feiEvolution = fei.first;

final feiDateRaw = feiEvolution.details['feiDate'];
final recordNumberRaw = feiEvolution.details['recordNumber'];

DateTime? feiDate;

if (feiDateRaw is Timestamp) {
  feiDate = feiDateRaw.toDate();
} else if (feiDateRaw is String) {
  feiDate = DateTime.tryParse(feiDateRaw);
}

final isRecordNumberValid = recordNumberRaw != null && recordNumberRaw.toString().isNotEmpty;
final isFeiDateValid = feiDate != null;

if (!isRecordNumberValid || !isFeiDateValid) {
  return DischargeStatus.blocked;
}

  return DischargeStatus.ready;
  
}
