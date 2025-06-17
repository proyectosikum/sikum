// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/core/theme/app_colors.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/birth_data_provider.dart';

class PatientSummary extends ConsumerWidget {
  final Patient patient;
  const PatientSummary({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Puede ser null al inicio, así que le damos un default true (modo vista)
    final data = ref.watch(birthDataProvider);
    final isViewMode = data?.isDataSaved ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (isViewMode) {
                  // modo vista: salir sin confirmación
                  context.pop();
                  return;
                }
                // modo edición: pedir confirmación
                final discard = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirmar cancelación'),
                    content: const Text(
                      'Si sales, perderás los cambios no guardados. ¿Continuar?'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Confirmar'),
                      ),
                    ],
                  ),
                );
                if (discard == true) {
                  ref.read(birthDataProvider.notifier).reset();
                  context.pop();
                }
              },
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
              ),
            ),
            const SizedBox(width: 48),
          ],
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
