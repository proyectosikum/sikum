import 'package:flutter/material.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/screens/patients/discharge_status_evaluator.dart';// VANE

class PatientCard extends StatelessWidget {
  final Patient patient;

  final VoidCallback onTap;

  final DischargeStatus status; // VANE

  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
    required this.status, // VANE
  });

//VANE
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
          width: 100, // Aumentá este valor si querés más espacio hacia la derecha
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye),
                onPressed: onTap,
              ),
              IconButton(
                icon: Icon(Icons.circle, color: getStatusColor()),//VANE
                onPressed: () =>
                  _showDischargeDetails(context, status), //VANE
                
              ),
            ],
          ),
        ),


      ),
    );
  }
}
  //VANE
  void _showDischargeDetails(BuildContext context, DischargeStatus status) {
    final message = switch (status) {
      DischargeStatus.notReady =>
        'El paciente aún no cumplió las 48 horas desde su ingreso.',
      DischargeStatus.blocked =>
        'El paciente cumplió las 48 horas, pero falta información:\n'
        '- Algún estudio de la madre está incompleto o sin dato\n'
        '- Datos de nacimiento incompletos\n'
        '- Evolución de FEI incompleta o ausente\n',
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
