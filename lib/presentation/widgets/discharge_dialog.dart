import 'package:flutter/material.dart';
import 'package:sikum/presentation/screens/patients/discharge_status_evaluator.dart';

void showDischargeDetails(BuildContext context, DischargeStatus status, List<String> missingItems) {
  final message = switch (status) {
    DischargeStatus.notReady =>
      'El paciente aún no cumplió las 48 horas desde su ingreso.',
    DischargeStatus.blocked =>
        missingItems.isNotEmpty 
        ? 'Para que el paciente pueda ser dado de alta, falta completar:\n\n${missingItems.map((item) => '• $item').join('\n')}'
        : 'El paciente cumplió las 48 horas, pero falta información pendiente.',
    DischargeStatus.ready =>
      'El paciente ya cumplió 48 horas y tiene toda la información necesaria para el alta.',
  };

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Estado de Alta'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}
