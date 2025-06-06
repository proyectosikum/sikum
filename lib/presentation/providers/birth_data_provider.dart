import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/birth_data.dart';
import 'package:sikum/presentation/screens/patients/birth/birth_data_enums.dart';

final birthDataProvider = NotifierProvider<BirthDataNotifier,BirthData>(BirthDataNotifier.new);

class BirthDataNotifier extends Notifier<BirthData>{

  @override
  BirthData build() {
    return BirthData(
      birthType:BirthTypeEnum.Unknown.getValue(),
      presentation:PresentationEnum.Unknown.getValue(),
      ruptureOfMembrane:RuptureOfMembraneEnum.Unknown.getValue(),
      amnioticFluid: AmnioticFluidEnum.Unknown.getValue(),
      sex: SexEnum.Unknown.getValue(),
    );
  }

    void updateBirthType(String type) {
    state = state.copyWith(birthType:type);
  }
  
    void updatePresentation(String presentation) {
    state = state.copyWith(presentation:presentation);
  }

    void updateRuptureOfMembrane(String ruptureOfMembrane) {
    state = state.copyWith(ruptureOfMembrane:ruptureOfMembrane);
  }

    void updateAmnioticFluid(String amnioticFluid) {
    state = state.copyWith(amnioticFluid:amnioticFluid);
  }

    void updateSex(String sex) {
    state = state.copyWith(sex:sex);
  }



 Future<void> submitBirthData(String patientId) async {
    // Primero validar todo
  //  if (!validateAll()) {
    //  throw Exception('Hay errores en el formulario, por favor revisa los campos');
   // }



   try {
    // Guardamos los datos en Firestore
    final docRef = FirebaseFirestore.instance.collection('dischargeDataPatient').doc(patientId);
    
    await docRef.set({
      'birthData': state.toMap(),
    }, SetOptions(merge: true)); // merge para no borrar otros campos del paciente
    print('Guardado en la DB');
    
  } catch (e) {
    throw Exception('Error al guardar datos maternos: $e');
  }
}

}
