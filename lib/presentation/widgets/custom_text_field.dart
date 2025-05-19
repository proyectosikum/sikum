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

  const CustomTextField({
    super.key,
    required this.label,
    this.initialValue,
    this.errorText,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.isEmail = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        autofillHints: isEmail ? [AutofillHints.email] : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: errorText,
        ),
        onChanged: onChanged,
        inputFormatters: inputFormatters,
      ),
    );
  }
}

