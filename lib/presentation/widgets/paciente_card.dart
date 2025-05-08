import 'package:flutter/material.dart';
import 'package:sikum/entities/paciente.dart';

class PacienteCard extends StatelessWidget {
  final Paciente paciente;

  const PacienteCard({
    super.key,
    required this.paciente,
  });

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
        title: Text('${paciente.nombre} ${paciente.apellido}'),
        subtitle: Text('DNI: ${paciente.dni}'),
        trailing: SizedBox(
          width: 100, // Aumentá este valor si querés más espacio hacia la derecha
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye),
                onPressed: () {
                  // Acción ver detalles
                },
              ),
              IconButton(
                icon: const Icon(Icons.circle, color: Colors.red),
                onPressed: () {
                  // Acción círculo rojo
                },
              ),
            ],
          ),
        ),


      ),
    );
  }
}