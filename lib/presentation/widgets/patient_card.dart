import 'package:flutter/material.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/screens/patients/discharge_status_evaluator.dart';// VANE

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;
  final DischargeStatus status; 
  final List<String> missingItems;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
    required this.status, 
    this.missingItems = const [],
  });


  Color getStatusColor() {
  switch (status) {
    case DischargeStatus.ready:
      return Colors.green;
    case DischargeStatus.blocked:
      return Colors.red;
    case DischargeStatus.notReady:
      return Colors.grey;
  }
}

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF8E1),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text('${patient.firstName} ${patient.lastName}'),
        subtitle: Text('DNI: ${patient.dni}'),
        trailing: SizedBox(
          width: patient.available ? 100 : 50, // Ajusta el ancho según si muestra o no el estado // Aumentar este valor para más espacio hacia la derecha
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye),
                onPressed: onTap,
              ),
              if (patient.available) 
              IconButton(
                icon: Icon(Icons.circle, color: getStatusColor()),
                onPressed: () =>
                  _showDischargeDetails(context, status, missingItems), 
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showDischargeDetails(BuildContext context, DischargeStatus status, List<String> missingItems) {
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
