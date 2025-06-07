import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikum/utils/validators.dart';
import 'package:sikum/entities/maternal_data.dart';

final List<String> allTests = [
  'VDRL',
  'Prueba Treponemica',
  'HIV',
  'Hepatitis B',
  'Chagas',
  'Toxo IgG',
  'Toxo IgM',
  'EGB',
  'PCI',
];


class MaternalDataFormNotifier extends ChangeNotifier {

  // step1
  String firstName = '';
  String lastName = '';
  String idType = '';
  String idNumber = '';
  String age = '';
  String locality = '';
  String address = '';
  String email = '';
  String phoneNumber = '';

  // step2
  String gravidity = ''; // Gestas
  String parity = ''; // Partos
  String cesareans = ''; 
  String abortions = ''; 
  // Mapa de complicaciones (checkbox)
  Map<String, bool> complications = {};

  // step3
  Map<String, String?> testResults = {}; 
  Map<String, String?> testDates = {}; 

    MaternalDataFormNotifier() {
    for (final name in allTests) {
      testResults[name] = '';
      testDates[name] = '';
    }
  }

  //step4
  String serologies = '';
  String bloodType = '';

  // para verificar si ya hay datos guardados
  bool isDataSaved = false;

  //para guardar copia de maternal data
  MaternalData? _originalData;
  String? _loadedPatientId;

  //solución para cargar data guardada de cada paciente
  bool get isLoadedForCurrentPatient => _loadedPatientId != null;

  // Mapa de errores para cada campo
  final Map<String, String?> errors = {};

  // Setters con validación y notifyListeners

  void updateFirstName(String value) {
    firstName = value;
    errors['firstName'] = validateNotEmpty(value, fieldName: 'Nombre');
    notifyListeners();
  }

  void updateLastName(String value) {
    lastName = value;
    errors['lastName'] = validateNotEmpty(value, fieldName: 'Apellido');
    notifyListeners();
  }

  void updateIdType(String value) {
    idType = value;
    errors['idType'] = validateNotEmpty(value, fieldName: 'Tipo de documento');
    notifyListeners();
  }

  void updateIdNumber(String value) {
    idNumber = value;
    errors['idNumber'] = validateNumeric(value, fieldName: 'Número de documento');
    notifyListeners();
  }

  void updateAge(String value) {
    age = value;
    errors['age'] = validateNumeric(value, fieldName: 'Edad');
    notifyListeners();
  }

  void updateLocality(String value) {
    locality = value;
    errors['locality'] = validateNotEmpty(value, fieldName: 'Localidad');
    notifyListeners();
  }

  void updateAddress(String value) {
    address = value;
    errors['address'] = validateNotEmpty(value, fieldName: 'Domicilio');
    notifyListeners();
  }

  void updateEmail(String value) {
    email = value;
    errors['email'] = validateEmail(value);
    notifyListeners();
  }

  void updatePhoneNumber(String value) {
    phoneNumber = value;
    errors['phoneNumber'] = validateNumeric(value, fieldName: 'Teléfono');
    notifyListeners();
  }

  void updateGravidity(String value) {
    gravidity = value;
    errors['gravidity'] = validateNumeric(value, fieldName: 'Cantidad de gestas');
    notifyListeners();
  }

  void updateParity(String value) {
    parity = value;
    errors['parity'] = validateNumeric(value, fieldName: 'Cantidad de partos');
    notifyListeners();
  }

  void updateCesareans(String value) {
    cesareans = value;
    errors['cesareans'] = validateNumeric(value, fieldName: 'Cantidad de cesáreas');
    notifyListeners();
  }

  void updateAbortions(String value) {
    abortions = value;
    errors['abortions'] = validateNumeric(value, fieldName: 'Cantidad de abortos');
    notifyListeners();
  }

  void updateComplication(String complication, bool value) {
    complications[complication] = value;
    notifyListeners();
  }

  void updateTestResult(String key, String value) {
    testResults[key] = value;
    notifyListeners();
  }

  void updateTestDate(String key, String date) {
    testDates[key] = date;
    notifyListeners();
  }

  void updateSerologies(String value) {
    serologies = value;
    notifyListeners();
}

  void updateBloodType(String value) {
    bloodType = value;
    errors['bloodType'] = validateNotEmpty(value, fieldName: 'Grupo y factor de la madre');
    notifyListeners();
  }

  void markDataAsSaved() {
    isDataSaved = true;
    notifyListeners();
  }

  void enableEditing() {
    isDataSaved = false;
    notifyListeners();
  }



void loadMaternalData(Map<String, dynamic> data, String patientId) {
  final maternalData = MaternalData.fromMap(data);

  firstName = maternalData.firstName;
  lastName = maternalData.lastName;
  idType = maternalData.idType;
  idNumber = maternalData.idNumber;
  age = maternalData.age;
  locality = maternalData.locality;
  address = maternalData.address;
  email = maternalData.email;
  phoneNumber = maternalData.phoneNumber;
  gravidity = maternalData.gravidity;
  parity = maternalData.parity;
  cesareans = maternalData.cesareans;
  abortions = maternalData.abortions;
  complications = maternalData.complications;  // Map<String, bool>
  testResults = maternalData.testResults;      // Map<String, String?>
  testDates = maternalData.testDates;          // Map<String, String?>
  serologies = maternalData.serologies;
  bloodType = maternalData.bloodType;
  isDataSaved = true;

  _originalData = maternalData;
  _loadedPatientId = patientId;

  notifyListeners();
}

void discardChangesAndRestore(String patientId) {
  if (_originalData != null && _loadedPatientId == patientId) {
    loadMaternalData(_originalData!.toMap(), patientId);
  } else {
    reset();
  }
}

  // Validación para las pruebas de la primera mitad
  bool validateFirstHalfTests() {
    return testResults.values.take(5).every((result) => result != null && result.isNotEmpty) &&
           testDates.values.take(5).every((date) => date != null && date.isNotEmpty);
  }

  // Validación para las pruebas de la segunda mitad
  bool validateSecondHalfTests() {
    return testResults.values.skip(5).take(4).every((result) => result != null && result.isNotEmpty) &&
           testDates.values.skip(5).take(4).every((date) => date != null && date.isNotEmpty);
  }

  // Validación de los diferentes steps antes de avanzar a la siguiente pantalla
  bool validateStep1() {
    errors['firstName'] = validateNotEmpty(firstName, fieldName: 'Nombre');
    errors['lastName'] = validateNotEmpty(lastName, fieldName: 'Apellido');
    errors['idType'] = validateNotEmpty(idType, fieldName: 'Tipo de documento');
    errors['idNumber'] = validateNumeric(idNumber, fieldName: 'Número de documento');
    errors['age'] = validateNumeric(age, fieldName: 'Edad');
    errors['locality'] = validateNotEmpty(locality, fieldName: 'Localidad');
    errors['address'] = validateNotEmpty(address, fieldName: 'Domicilio');
    errors['email'] = validateEmail(email);
    errors['phoneNumber'] = validateNumeric(phoneNumber, fieldName: 'Teléfono');

    notifyListeners();

    // Retornamos true si no hay errores (todos los valores nulos)
    return errors.values.every((error) => error == null);
  }

  bool validateStep2() {
    errors['gravidity'] = validateNumeric(gravidity, fieldName: 'Cantidad de gestas');
    errors['parity'] = validateNumeric(parity, fieldName: 'Cantidad de partos');
    errors['cesareans'] = validateNumeric(cesareans, fieldName: 'Cantidad de cesáreas');
    errors['abortions'] = validateNumeric(abortions, fieldName: 'Cantidad de abortos');

    notifyListeners();

    return errors.values.every((error) => error == null);
  }

  // Validación completa para las pruebas
  bool validateTests() {
    bool isValid = true;

    // Validar que todos los resultados estén seleccionados
    for (var key in testResults.keys) {
      if (testResults[key] == null || testResults[key]!.isEmpty) {
        isValid = false;
      }
    }

    // Validar que todas las fechas estén seleccionadas
    for (var key in testDates.keys) {
      if (testDates[key] == null || testDates[key]!.isEmpty) {
        isValid = false;
      }
    }

    return isValid;
  }

  bool validateStep4() {
  errors['bloodType'] = validateNotEmpty(bloodType, fieldName: 'Grupo sanguíneo');
  notifyListeners();
  return errors['bloodType'] == null;
}

  // Método para validar todo antes de guardar
  bool validateAll() {
    bool isValidStep1 = validateStep1();
    bool isValidStep2 = validateStep2();
    bool isValidTests = validateTests();
    bool isValidStep4 = validateStep4();
    return isValidStep1 && isValidStep2 && isValidTests && isValidStep4;
  }

  // Método para resetear formulario
  void reset() {
    firstName = '';
    lastName = '';
    idType = '';
    idNumber = '';
    age = '';
    locality = '';
    address = '';
    email = '';
    phoneNumber = '';
    gravidity = '';
    parity = '';
    cesareans = '';
    abortions = '';
    complications.clear();
    testResults.clear(); 
    testDates.clear();  
    serologies = '';
    bloodType = '';
    isDataSaved = false;
    errors.clear();
    notifyListeners();
  }

// Envía los datos completos a Firebase bajo el paciente indicado
  Future<void> submitMaternalData(String patientId) async {
    // Primero validar todo
    if (!validateAll()) {
      throw Exception('Hay errores en el formulario, por favor revisa los campos');
    }

  // Crear un objeto MaternalData con los datos del formulario
  final maternalData = MaternalData(
    firstName: firstName,
    lastName: lastName,
    idType: idType,
    idNumber: idNumber,
    age: age,
    locality: locality,
    address: address,
    email: email,
    phoneNumber: phoneNumber,
    gravidity: gravidity,
    parity: parity,
    cesareans: cesareans,
    abortions: abortions,
    complications: complications,  // Map<String, bool>
    testResults: testResults,      // Map<String, String?>
    testDates: testDates,          // Map<String, String?>
    serologies: serologies,
    bloodType: bloodType,
  );

  try {
    // Guardamos los datos en Firestore
    final docRef = FirebaseFirestore.instance.collection('dischargeDataPatient').doc(patientId);
    
    await docRef.set({
      'maternalData': maternalData.toMap(),
    }, SetOptions(merge: true)); // merge para no borrar otros campos del paciente
    
    markDataAsSaved(); // Marcamos los datos como guardados
  } catch (e) {
    throw Exception('Error al guardar datos maternos: $e');
  }
}
  
}

final maternalDataFormProvider = ChangeNotifierProvider.family<MaternalDataFormNotifier, String>((ref, patientId) {
  return MaternalDataFormNotifier();
});