import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/birth_data.dart';
import 'package:sikum/entities/patient.dart';

final birthDataProvider = NotifierProvider<BirthDataNotifier,BirthData?>(BirthDataNotifier.new);

class BirthDataNotifier extends Notifier<BirthData?>{

  Patient? _patient;

  @override
  BirthData? build() {
    return _patient?.birthData ?? BirthData(
    hasHepatitisBVaccine: _patient?.birthData?.hasHepatitisBVaccine ?? false,
    hasVitaminK : _patient?.birthData?.hasVitaminK ?? false ,
    hasOphthalmicDrops : _patient?.birthData?.hasOphthalmicDrops ?? false,
  );
  }

  void setPatient(Patient p){
    _patient=p;
    print('paso id: $_patient');
  }

  void reset(){
    BirthData();
  }

   Future<void> updateBirthType(String type) async {
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

 
}
