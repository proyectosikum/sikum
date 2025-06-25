

import 'package:flutter/material.dart';

class CustomTimePicker extends StatelessWidget {
  final String label;
  final String? initialTime;
  final ValueChanged<String> onTimeChanged;
  final bool isDataSaved;

  const CustomTimePicker({
    super.key,
    required this.label,
    this.initialTime,
    required this.onTimeChanged,
    required this.isDataSaved,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: initialTime ?? '');

    return GestureDetector(
      onTap: isDataSaved // Si los datos están guardados, no permite cambiar la hora
          ? null 
          : () async {
        TimeOfDay initial = TimeOfDay.now();
        if (initialTime != null && initialTime!.isNotEmpty) {
          try {
            final parts = initialTime!.split(':');
            initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          } catch (_) {}
        }

        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: initial,
        );

        if (picked != null) {
          final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          onTimeChanged(formatted);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.access_time), // Icono de reloj
          ),
          readOnly: isDataSaved, // Si los datos están guardados, el campo se vuelve de solo lectura
        ),
      ),
    );
  }
}