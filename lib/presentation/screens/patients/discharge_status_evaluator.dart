import 'package:sikum/entities/patient.dart';
import 'package:sikum/entities/evolution.dart';

enum DischargeStatus {
  notReady, // gris
  ready,    // verde
  blocked,  // rojo
}

class DischargeResult {
  final DischargeStatus status;
  final List<String> missingItems;
  
  DischargeResult(this.status, this.missingItems);
}

DischargeResult getDischargeStatusWithDetails(Patient patient, List<Evolution> evolutions) {
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

  // Validar datos maternos - solo que exista el form
  final maternalData = patient.maternalData;
  if (maternalData == null) {
    missing.add('Formulario de datos maternos');
  }

  // Validar datos de nacimiento - que exista y que ningún campo sea null
  final birthData = patient.birthData;
  if (birthData == null) {
    missing.add('Datos de nacimiento');
  } else {
    // Verificar que los campos obligatorios no sean null o vacíos
    final Map<String, dynamic> birthDataMap = birthData.toMap();
    final emptyFields = <String>[];
    
    // Definir los campos que deben validarse (excluyendo los booleanos que tienen valores por defecto)
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

    // Validación específica para Hepatitis B - debe ser true
    if (birthData.hasHepatitisBVaccine != true) {
      emptyFields.add('Vacuna de Hepatitis B (debe estar aplicada)');
    }
    
    // Validación específica para grupo y factor sanguíneo - no puede ser "Resultado pendiente"
    if (birthData.bloodType == "Resultado pendiente") {
      emptyFields.add('Grupo y factor sanguíneo (resultado pendiente)');
    }
    
    // Para physicalExaminationDetails, solo validar si physicalExamination es "Otros"
    if (birthData.physicalExamination == "Anormal") {
      if (birthData.physicalExaminationDetails == null || birthData.physicalExaminationDetails!.isEmpty) {
        emptyFields.add('Detalles del examen físico');
      }
    }
    
    // Para birthPlaceDetails, solo validar si birthPlace es "Otro"
    if (birthData.birthPlace == "Extra hospitalario") {
      if (birthData.birthPlaceDetails == null || birthData.birthPlaceDetails!.isEmpty) {
        emptyFields.add('Detalles del lugar de nacimiento');
      }
    }
    
    if (emptyFields.isNotEmpty) {
      missing.add('Completar en datos de nacimiento: ${emptyFields.join(', ')}');
    }
  }

  // Validar evolución FEI - solo que exista
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
DischargeStatus getDischargeStatus(Patient patient, List<Evolution> evolutions) {
  return getDischargeStatusWithDetails(patient, evolutions).status;
}

// No requiere exactamente 48 horas, sino que sea el segundo día después
bool hasTwoDaysPassed(DateTime referenceDate, DateTime currentDate) {
  // Normalizar las fechas para comparar solo días (sin horas)
  final referenceDay = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
  final currentDay = DateTime(currentDate.year, currentDate.month, currentDate.day);
  
  // Calcular la diferencia en días
  final daysDifference = currentDay.difference(referenceDay).inDays;
  
  // Debe haber pasado al menos 2 días completos
  return daysDifference >= 2;
} 
