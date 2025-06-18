import 'package:sikum/entities/patient.dart';
import 'package:sikum/entities/evolution.dart';

enum DischargeStatus {
  notReady, // gris
  ready, // verde
  blocked, // rojo
}

class DischargeResult {
  final DischargeStatus status;
  final List<String> missingItems;

  DischargeResult(this.status, this.missingItems);
}

DischargeResult getDischargeStatusWithDetails(
  Patient patient,
  List<Evolution> evolutions,
) {
  final now = DateTime.now();
  //final admittedAt = patient.birthData?.birthDate; -> para cuando cambiemos a fecha de nacimiento
  final admittedAt = patient.createdAt;
  final List<String> missing = [];

  if (admittedAt == null) {
    return DischargeResult(DischargeStatus.notReady, []);
  }

  //final admittedDateTime = admittedAt.toDate(); -> para cuando cambiemos a fecha de nacimiento
  if (!hasTwoDaysPassed(admittedAt, now)) {
    return DischargeResult(DischargeStatus.notReady, []);
  }

  final maternalData = patient.maternalData;
  if (maternalData == null) {
    missing.add('Formulario de datos maternos');
  }

  final birthData = patient.birthData;
  if (birthData == null) {
    missing.add('Datos de nacimiento');
  } else {
    final Map<String, dynamic> birthDataMap = birthData.toMap();
    final emptyFields = <String>[];

    final fieldsToValidate = {
      'birthType': 'Tipo de nacimiento',
      'presentation': 'Presentación',
      'ruptureOfMembrane': 'Ruptura de membrana',
      'amnioticFluid': 'Líquido amniótico',
      'sex': 'Sexo',
      'twin': 'Gemelar',
      'firstApgarScore': 'Apgar 1 minuto',
      'secondApgarScore': 'Apgar 5 minutos',
      'thirdApgarScore': 'Apgar 10 minutos',
      'disposition': 'Destino',
      'gestationalAge': 'Edad gestacional',
      'birthDate': 'Fecha de nacimiento',
      'birthTime': 'Hora de nacimiento',
      'weight': 'Peso',
      'length': 'Talla',
      'headCircumference': 'Perímetro cefálico',
      'physicalExamination': 'Examen físico',
      'birthPlace': 'Lugar de nacimiento',
      'braceletNumber': 'Número de pulsera',
      'bloodType': 'Grupo y factor sanguíneo',
    };

    fieldsToValidate.forEach((key, displayName) {
      final value = birthDataMap[key];
      if (value == null || (value is String && value.isEmpty)) {
        emptyFields.add(displayName);
      }
    });

    if (birthData.hasHepatitisBVaccine != true) {
      emptyFields.add('Vacuna de Hepatitis B (debe estar aplicada)');
    }

    if (birthData.bloodType == "Resultado pendiente") {
      emptyFields.add('Grupo y factor sanguíneo (resultado pendiente)');
    }

    if (birthData.physicalExamination == "Anormal") {
      if (birthData.physicalExaminationDetails == null ||
          birthData.physicalExaminationDetails!.isEmpty) {
        emptyFields.add('Detalles del examen físico');
      }
    }

    if (birthData.birthPlace == "Extra hospitalario") {
      if (birthData.birthPlaceDetails == null ||
          birthData.birthPlaceDetails!.isEmpty) {
        emptyFields.add('Detalles del lugar de nacimiento');
      }
    }

    if (emptyFields.isNotEmpty) {
      missing.add(
        'Completar en datos de nacimiento: ${emptyFields.join(', ')}',
      );
    }
  }

  final fei = evolutions.where((e) => e.specialty == 'enfermeria_fei');
  if (fei.isEmpty) {
    missing.add('Evolución de enfermería FEI');
  }

  if (missing.isNotEmpty) {
    return DischargeResult(DischargeStatus.blocked, missing);
  }

  return DischargeResult(DischargeStatus.ready, []);
}

// Función de compatibilidad para mantener la API anterior
DischargeStatus getDischargeStatus(
  Patient patient,
  List<Evolution> evolutions,
) {
  return getDischargeStatusWithDetails(patient, evolutions).status;
}

bool hasTwoDaysPassed(DateTime referenceDate, DateTime currentDate) {
  final referenceDay = DateTime(
    referenceDate.year,
    referenceDate.month,
    referenceDate.day,
  );
  final currentDay = DateTime(
    currentDate.year,
    currentDate.month,
    currentDate.day,
  );

  final daysDifference = currentDay.difference(referenceDay).inDays;

  return daysDifference >= 2;
}
