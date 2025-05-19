// lib/presentation/providers/maternal_data_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/utils/validators.dart';

class MaternalDataFormNotifier extends ChangeNotifier {
  // Campos del formulario
  String firstName = '';
  String lastName = '';
  String idType = '';
  String idNumber = '';
  String age = '';
  String locality = '';
  String address = '';
  String email = '';
  String phoneNumber = '';


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

  // Validación completa antes de guardar o avanzar a la siguiente pantalla
  bool validateAll() {
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

  // Opcional: método para resetear formulario
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
    errors.clear();
    notifyListeners();
  }
}

final maternalDataFormProvider = ChangeNotifierProvider<MaternalDataFormNotifier>((ref) {
  return MaternalDataFormNotifier();
});
