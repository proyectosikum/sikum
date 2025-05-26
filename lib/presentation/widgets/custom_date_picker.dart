import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  final String label;
  final String? initialDate;
  final ValueChanged<String> onDateChanged;
  final bool isDataSaved;

  const CustomDatePicker({
    super.key,
    required this.label,
    this.initialDate,
    required this.onDateChanged,
    required this.isDataSaved,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: initialDate ?? '');

    return GestureDetector(
      onTap: isDataSaved // Si los datos están guardados, no permite cambiar la fecha
          ? null // Si está guardado, no se puede interactuar
          : () async {
        DateTime initial = DateTime.now();
        if (initialDate != null && initialDate!.isNotEmpty) {
          try {
            initial = DateFormat('dd/MM/yyyy').parse(initialDate!);
          } catch (_) {}
        }

        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (picked != null) {
          final formatted = DateFormat('dd/MM/yyyy').format(picked);
          onDateChanged(formatted);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: isDataSaved, // Si los datos están guardados, el campo se vuelve de solo lectura
        ),
      ),
    );
  }
}

