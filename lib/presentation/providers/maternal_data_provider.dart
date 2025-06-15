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
  String gravidity = '';
  String parity = '';
  String cesareans = '';
  String abortions = '';
  Map<String, bool> complications = {};

  // step3
  Map<String, String?> testResults = {};
  Map<String, String?> testDates = {};

  // step4
  String serologies = '';
  String bloodType = '';

  // Estados de control
  bool isDataSaved = false;
  MaternalData? _originalData;
  String? _loadedPatientId;
  
  // Mapa de errores para cada campo
  final Map<String, String?> errors = {};
  
  // Errores específicos para las pruebas
  final Map<String, String?> testErrors = {};

  MaternalDataFormNotifier() {
    for (final name in allTests) {
      testResults[name] = '';
      testDates[name] = '';
    }
  }

  bool get isLoadedForCurrentPatient => _loadedPatientId != null;

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
    errors['idNumber'] = validateIdNumber(value);
    notifyListeners();
  }

  void updateAge(String value) {
    age = value;
    errors['age'] = validateAge(value);
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
    errors['phoneNumber'] = validatePhone(value);
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
    // Limpiar error específico cuando se actualiza
    testErrors.remove('${key}_result');

    // Si el resultado no requiere fecha, limpiar la fecha y su error
    if (!_requiresDate(value)) {
      testDates[key] = null;
      testErrors.remove('${key}_date');
    }

    notifyListeners();
  }

  void updateTestDate(String key, String date) {
    testDates[key] = date;
    // Limpiar error específico cuando se actualiza
    testErrors.remove('${key}_date');
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
    complications = Map<String, bool>.from(maternalData.complications);
    testResults = Map<String, String?>.from(maternalData.testResults);
    testDates = Map<String, String?>.from(maternalData.testDates);
    serologies = maternalData.serologies;
    bloodType = maternalData.bloodType;
    isDataSaved = true;

    _originalData = maternalData;
    _loadedPatientId = patientId;

    // Limpiar errores al cargar datos
    errors.clear();
    testErrors.clear();

    notifyListeners();
  }

  void discardChangesAndRestore(String patientId) {
    if (_originalData != null && _loadedPatientId == patientId) {
      loadMaternalData(_originalData!.toMap(), patientId);
    } else {
      reset();
    }
  }

  // VALIDACIONES MEJORADAS PARA STEP 3

  bool validateFirstHalfTests() {
    testErrors.clear(); // Limpiar errores anteriores
    bool isValid = true;
    
    final firstHalfTests = allTests.take(5).toList();
    
    for (final testName in firstHalfTests) {
      // Validar resultado
      if (testResults[testName] == null || testResults[testName]!.isEmpty) {
        testErrors['${testName}_result'] = 'Seleccione un resultado para $testName';
        isValid = false;
      }

      // Validar fecha solo si el resultado requiere fecha
      final result = testResults[testName];
      if (_requiresDate(result)) {
        if (testDates[testName] == null || testDates[testName]!.isEmpty) {
          testErrors['${testName}_date'] = 'Seleccione una fecha para $testName';
          isValid = false;
        }
      } else {
        // Si no requiere fecha, limpiar la fecha guardada
        testDates[testName] = null;
      }

    }
    
    notifyListeners();
    return isValid;
  }

  bool validateSecondHalfTests() {
    // Solo limpiar errores de la segunda mitad
    final secondHalfTests = allTests.skip(5).toList();
    for (final testName in secondHalfTests) {
      testErrors.remove('${testName}_result');
      testErrors.remove('${testName}_date');
    }
    
    bool isValid = true;
    
    for (final testName in secondHalfTests) {
      // Validar resultado
      if (testResults[testName] == null || testResults[testName]!.isEmpty) {
        testErrors['${testName}_result'] = 'Seleccione un resultado para $testName';
        isValid = false;
      }

      // Validar fecha solo si el resultado requiere fecha
      final result = testResults[testName];
      if (_requiresDate(result)) {
        if (testDates[testName] == null || testDates[testName]!.isEmpty) {
          testErrors['${testName}_date'] = 'Seleccione una fecha para $testName';
          isValid = false;
        }
      } else {
        // Si no requiere fecha, limpiar la fecha guardada
        testDates[testName] = null;
      }
    }
    
    notifyListeners();
    return isValid;
  }

  // Método auxiliar para determinar si un resultado requiere fecha
  bool _requiresDate(String? result) {
    if (result == null || result.isEmpty) return false;
    return result.toLowerCase() == 'positiva' || result.toLowerCase() == 'negativa';
  }

  // Método para obtener errores específicos de pruebas
  String? getTestError(String testName, String type) {
    return testErrors['${testName}_$type'];
  }
  //Verificar si un test tiene errores (para resaltado)
  bool hasTestError(String testName) {
    return testErrors.containsKey('${testName}_result') || 
           testErrors.containsKey('${testName}_date');
  }

  bool validateStep1() {
    errors['firstName'] = validateNotEmpty(firstName, fieldName: 'Nombre');
    errors['lastName'] = validateNotEmpty(lastName, fieldName: 'Apellido');
    errors['idType'] = validateNotEmpty(idType, fieldName: 'Tipo de documento');
    errors['idNumber'] = validateIdNumber(idNumber);
    errors['age'] = validateAge(age);
    errors['locality'] = validateNotEmpty(locality, fieldName: 'Localidad');
    errors['address'] = validateNotEmpty(address, fieldName: 'Domicilio');
    errors['email'] = validateEmail(email);
    errors['phoneNumber'] = validatePhone(phoneNumber);

    notifyListeners();
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

  bool validateTests() {
    testErrors.clear();
    bool isValid = true;

    for (var testName in allTests) {
      if (testResults[testName] == null || testResults[testName]!.isEmpty) {
        testErrors['${testName}_result'] = 'Seleccione un resultado';
        isValid = false;
      } else {
        // Solo validar fecha si el resultado la requiere
        final result = testResults[testName];
        if (_requiresDate(result)) {
          if (testDates[testName] == null || testDates[testName]!.isEmpty) {
            testErrors['${testName}_date'] = 'Seleccione una fecha';
            isValid = false;
          }
        } else {
          // Si no requiere fecha, asegurar que esté en null
          testDates[testName] = null;
        }
      }
    }

    notifyListeners();
    return isValid;
  }

  bool validateStep4() {
    errors['bloodType'] = validateNotEmpty(bloodType, fieldName: 'Grupo sanguíneo');
    notifyListeners();
    return errors['bloodType'] == null;
  }

  bool validateAll() {
    bool isValidStep1 = validateStep1();
    bool isValidStep2 = validateStep2();
    bool isValidTests = validateTests();
    bool isValidStep4 = validateStep4();
    return isValidStep1 && isValidStep2 && isValidTests && isValidStep4;
  }

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
    testErrors.clear();
    _originalData = null;
    _loadedPatientId = null;
    
    // Reinicializar mapas de pruebas
    for (final name in allTests) {
      testResults[name] = '';
      testDates[name] = '';
    }
    
    notifyListeners();
  }

  Future<void> submitMaternalData(String patientId) async {
    if (!validateAll()) {
      throw Exception('Hay errores en el formulario, por favor revisa los campos');
    }

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
      complications: complications,
      testResults: testResults,
      testDates: testDates,
      serologies: serologies,
      bloodType: bloodType,
    );

    try {
      final docRef = FirebaseFirestore.instance.collection('dischargeDataPatient').doc(patientId);
      
      await docRef.set({
        'maternalData': maternalData.toMap(),
      }, SetOptions(merge: true));
      
      markDataAsSaved();
    } catch (e) {
      throw Exception('Error al guardar datos maternos: $e');
    }
  }
}

final maternalDataFormProvider = ChangeNotifierProvider.family<MaternalDataFormNotifier, String>((ref, patientId) {
  return MaternalDataFormNotifier();
});