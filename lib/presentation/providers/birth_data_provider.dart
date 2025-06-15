import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/birth_data.dart';
import 'package:sikum/entities/patient.dart';

final birthDataProvider = NotifierProvider<BirthDataNotifier,BirthData?>(BirthDataNotifier.new);

class BirthDataNotifier extends Notifier<BirthData?>{

  Patient? _patient;
  bool isUpdateView = false;
  Map<String, String?> errors = {};

  @override
  BirthData? build() {
    return  state ?? _patient?.birthData;
  }

  void setPatient(Patient p){ 
    if(_patient==null || p.id != _patient!.id){
      reset();
      _patient=p;
      state = p.birthData ?? BirthData();
    }
  }

  Patient? get patient => _patient;


  void reset(){
    state= _patient?.birthData ?? BirthData();
    errors = {};
  }

   void updateBirthType(String type) {
    state = state?.copyWith(birthType:type);
  }
  
    void updatePresentation(String presentation) {
    state = state?.copyWith(presentation:presentation);
  }

    void updateRuptureOfMembrane(String ruptureOfMembrane) {
    state = state?.copyWith(ruptureOfMembrane:ruptureOfMembrane);
  }

    void updateAmnioticFluid(String amnioticFluid) {
    state = state?.copyWith(amnioticFluid:amnioticFluid);
  }

    void updateSex(String sex) {
    state = state?.copyWith(sex:sex);
  }

    void updateTwin(String twin) {
    state = state?.copyWith(twin:twin);
  }

    void updateFirstApgar(String apgarScore) {
    state = state?.copyWith(firstApgarScore:apgarScore);
  }

    void updateSecondApgar(String apgarScore) {
    state = state?.copyWith(secondApgarScore:apgarScore);
  }

    void updateThirdApgar(String apgarScore) {
    state = state?.copyWith(thirdApgarScore:apgarScore);
  }

    void updateHasHepatitisBVaccine(bool value ) {
    state = state?.copyWith(hasHepatitisBVaccine:value);
  }

    void updateHasVitaminK(bool value ) {
    state = state?.copyWith(hasVitaminK:value);
  }

    void updateHasOphthalmicDrops(bool value ) {
    state = state?.copyWith(hasOphthalmicDrops:value);
  }

      void updateDisposition(String value ) {
    state = state?.copyWith(disposition:value);
  }

      void updateGestationalAge(int value ) {
    state = state?.copyWith(gestationalAge:value);
  }

  void updateBirthDate(DateTime birthDate) {
  state = state?.copyWith(birthDate: birthDate);
}

void updateBirthTime(String birthTime) {
  state = state?.copyWith(birthTime: birthTime);
}

void updateWeight(int weight) {
  state = state?.copyWith(weight: weight);
}

void updateLength(int length) {
  state = state?.copyWith(length: length);
}

void updateHeadCircumference(int headCircumference) {
  state = state?.copyWith(headCircumference: headCircumference);
}

void updatePhysicalExamination(String physicalExamination) {
  state = state?.copyWith(physicalExamination: physicalExamination);
}

void updatePhysicalExaminationDetails(String details) {
  state = state?.copyWith(physicalExaminationDetails: details);
}

void updateBirthPlace(String birthPlace) {
  state = state?.copyWith(birthPlace: birthPlace);
}

void updateBirthPlaceDetails(String details) {
  state = state?.copyWith(birthPlaceDetails: details);
}

void updateBraceletNumber(int value) {
  state = state?.copyWith(braceletNumber: value);
}

void updateBloodType(String value) {
  state = state?.copyWith(bloodType: value);
}

  void updateIsDataSaved(bool value) {
    print(value);
    state = state?.copyWith(isDataSaved: value);
}

String? errorTextFor(String field) => errors.containsKey(field) ? errors[field] : null;


// VALIDACIONES 
bool validateAll() {
  errors.clear();
  final d = state;
  if (d == null) return false;

  final now = DateTime.now();

  // Obligatorios
  if (d.ruptureOfMembrane == null) errors['ruptureOfMembrane'] = 'Campo obligatorio';
  if (d.amnioticFluid == null) errors['amnioticFluid'] = 'Campo obligatorio';
  if (d.birthType == null) errors['birthType'] = 'Campo obligatorio';
  if (d.presentation == null) errors['presentation'] = 'Campo obligatorio';
  if (d.sex == null) errors['sex'] = 'Campo obligatorio';
  if (d.twin == null) errors['twin'] = 'Campo obligatorio';
  if (d.firstApgarScore == null) errors['firstApgarScore'] = 'Campo obligatorio';
  if (d.secondApgarScore == null) errors['secondApgarScore'] = 'Campo obligatorio';
  if (d.thirdApgarScore == null) errors['thirdApgarScore'] = 'Campo obligatorio';
  if (d.disposition == null) errors['disposition'] = 'Campo obligatorio';
  if (d.bloodType == null) errors['bloodType'] = 'Campo obligatorio';

  // Lugar de nacimiento y detalle
  if (d.birthPlace == null) {
    errors['birthPlace'] = 'Campo obligatorio';
  } else if (d.birthPlace == "Otro" &&
      (d.birthPlaceDetails == null || d.birthPlaceDetails!.trim().isEmpty)) {
    errors['birthPlaceDetails'] = 'Debe detallar el lugar';
  }

  // Examen físico
  if (state?.physicalExamination == "Anormal") {
  if (state?.physicalExaminationDetails?.trim().isEmpty ?? true) {
    errors['physicalExaminationDetails'] =
      "Debe completar los detalles si el examen es anormal.";
  }
}


  // Fecha y hora de nacimiento
  if (d.birthDate == null) {
    errors['birthDate'] = 'Campo obligatorio';
  } else if (d.birthDate!.isAfter(now)) {
    errors['birthDate'] = 'No puede ser posterior a hoy';
  }

  if (d.birthTime == null || d.birthTime!.isEmpty) {
    errors['birthTime'] = 'Campo obligatorio';
  } else {
    // Verificación cruzada de fecha y hora combinadas
    try {
      final timeParts = d.birthTime!.split(':');
      final combined = DateTime(
        d.birthDate?.year ?? now.year,
        d.birthDate?.month ?? now.month,
        d.birthDate?.day ?? now.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      if (combined.isAfter(now)) {
        errors['birthTime'] = 'La fecha y hora no pueden ser futuras';
      }
    } catch (_) {
      errors['birthTime'] = 'Hora inválida';
    }
  }

  // Validaciones numéricas
  final age = d.gestationalAge;
  if (age != null && (age < 23 || age > 42)) {
    errors['gestationalAge'] = 'Edad gestacional fuera de rango (23–42)';
  }

  if (d.weight == null) {
    errors['weight'] = 'Campo obligatorio';
  } else if (d.weight! > 10000) {
    errors['weight'] = 'Peso fuera de rango (hasta 10.000 g)';
  }

  if (d.length != null && d.length! > 100) {
    errors['length'] = 'Longitud demasiado alta';
  }

  if (d.headCircumference != null && d.headCircumference! > 100) {
    errors['headCircumference'] = 'Perímetro cefálico fuera de rango: hasta 100';
  }

  if (d.braceletNumber != null && d.braceletNumber! < 0) {
    errors['braceletNumber'] = 'Número inválido';
  }

  return errors.isEmpty;
}

}
