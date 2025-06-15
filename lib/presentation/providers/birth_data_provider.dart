import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/birth_data.dart';
import 'package:sikum/entities/patient.dart';

final birthDataProvider = NotifierProvider<BirthDataNotifier,BirthData?>(BirthDataNotifier.new);

class BirthDataNotifier extends Notifier<BirthData?>{

  Patient? _patient;
  bool isUpdateView = false;

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
    state=BirthData();
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
    state = state?.copyWith(isDataSaved: value);
}


}
