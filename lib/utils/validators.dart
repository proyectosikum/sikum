String? validateNotEmpty(String? value, {String fieldName = 'Este campo'}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName es obligatorio';
  }
  return null;
}

String? validateEmail(String? value) {
  final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
  if (value == null || value.trim().isEmpty) {
    return 'Email es obligatorio';
  }
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Email inválido';
  }
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Teléfono es obligatorio';
  }
  if (value.trim().length < 10) {
    return 'Teléfono inválido';
  }
  return null;
}

String? validateNumeric(String? value, {String fieldName = 'Campo'}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName es obligatorio';
  }
  if (int.tryParse(value.trim()) == null) {
    return '$fieldName debe ser un número válido';
  }
  return null;
}

// Nueva validación para número de documento
String? validateIdNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Número de documento es obligatorio';
  }
  
  final cleanValue = value.trim();
  
  // Verificar rango de longitud (7-8 caracteres)
  if (cleanValue.length < 7 || cleanValue.length > 8) {
    return 'Número de documento debe tener entre 7 y 8 dígitos';
  }
  
  return null;
}

// Nueva validación para edad
String? validateAge(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Edad es obligatoria';
  }
  
  final age = int.parse(value.trim());
  
  // Verificar rango de edad (12-55)
  if (age < 12 || age > 55) {
    return 'Edad debe estar entre 12 y 55 años';
  }
  
  return null;
}