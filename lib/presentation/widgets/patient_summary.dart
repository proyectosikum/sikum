import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/core/theme/app_colors.dart';
import 'package:sikum/entities/patient.dart';

class PatientSummary extends StatelessWidget{
  final Patient patient;
  const PatientSummary({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
                    'Datos de Nacimiento',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  textAlign: TextAlign.center,
                  )
                ),
                const SizedBox(width: 48),              
            ]
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.green, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${patient.lastName}, ${patient.firstName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'DNI: ${patient.dni}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}


