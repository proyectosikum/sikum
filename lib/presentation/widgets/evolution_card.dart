import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sikum/entities/evolution.dart';

class EvolutionCard extends StatelessWidget {
  final Evolution evolution;
  final String patientId;
  const EvolutionCard({super.key, required this.evolution, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    // Capitaliza la primera letra de la especialidad
    final specialty = evolution.specialty.isNotEmpty
        ? '${evolution.specialty[0].toUpperCase()}${evolution.specialty.substring(1)}'
        : '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4F959D), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialty,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${formatter.format(evolution.createdAt)}hs'),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye),
            onPressed: () {
              context.push('/pacientes/$patientId/evolutions/${evolution.id}');
            },
          ),
        ],
      ),
    );
  }
}
