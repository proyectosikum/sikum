import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final String? errorText;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final bool isEmail;
  final List<TextInputFormatter>? inputFormatters;
  final FloatingLabelBehavior floatingLabelBehavior;
  final int maxLines;
   final bool readOnly; 

  const CustomTextField({
    super.key,
    required this.label,
    this.initialValue,
    this.errorText,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.isEmail = false,
    this.inputFormatters,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
    this.maxLines = 1,
    this.readOnly = false,

  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        autofillHints: isEmail ? [AutofillHints.email] : null,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: errorText,
          floatingLabelBehavior: floatingLabelBehavior,
        // Estilo para indicar que está en solo lectura
          enabled: !readOnly,  // Si es readOnly, el campo será deshabilitado
          suffixIcon: readOnly ? Icon(Icons.lock, color: Colors.grey) : null, // Ícono de bloqueo
        ),
        onChanged: readOnly ? null : onChanged,  // Deshabilitamos la interacción si es solo lectura
        inputFormatters: inputFormatters,
        readOnly: readOnly,  // Lo marcamos como solo lectura
      ),
    );
  }
}

