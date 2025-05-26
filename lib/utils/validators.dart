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
  if (value.trim().length < 6) {
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