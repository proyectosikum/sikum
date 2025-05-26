import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String label;
  final void Function(String?) onChanged;
  final String? errorText;
  final bool readOnly;

  const CustomDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    required this.label,
    this.value,
    this.errorText,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: errorText,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: readOnly ? null : onChanged,  // Deshabilitamos la interacción si es solo lectura
      // Si es solo lectura, deshabilitamos el campo
      icon: readOnly ? null : const Icon(Icons.arrow_drop_down),
    );
  }
}

