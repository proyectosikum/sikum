import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/providers/discharge_status_provider.dart';
import 'package:sikum/presentation/screens/patients/discharge_status_evaluator.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/discharge_dialog.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

class ClosureChoiceScreen extends ConsumerWidget {
  final String patientId;

  const ClosureChoiceScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientDetailsStreamProvider(patientId));
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);

    return Scaffold(
      backgroundColor: cream,
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: SafeArea(
        child: patientAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (_, __) => const Center(child: Text('Error al cargar paciente')),
          data: (patient) {
            if (patient == null) {
              return const Center(child: Text('Paciente no encontrado'));
            }

            final dischargeStatus = ref.watch(dischargeStatusProvider(patient));

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Cierre de Historia Clínica',
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
                  _buildPatientHeader(patient),
                  const SizedBox(height: 32),
                  dischargeStatus.when(
                    loading: () => const CircularProgressIndicator(),
                    error:
                        (_, __) =>
                            const Text('Error al evaluar estado de alta'),
                    data:
                        (status) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.logout),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                foregroundColor: cream,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: () {
                                context.push(
                                  '/pacientes/$patientId/cerrar/egreso',
                                );
                              },
                              label: const Text('Egreso sin alta médica'),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.transfer_within_a_station),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                foregroundColor: cream,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: () {
                                context.push(
                                  '/pacientes/$patientId/cerrar/derivacion',
                                );
                              },
                              label: const Text('Derivación de sector'),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    status.status == DischargeStatus.ready
                                        ? green
                                        : Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                foregroundColor: cream,
                              ),
                              onPressed:
                                  status.status == DischargeStatus.ready
                                      ? () => context.push(
                                        '/pacientes/$patientId/cerrar/alta',
                                      )
                                      : null,
                              label: const Text('Alta clínica'),
                            ),
                            const SizedBox(height: 32),
                            if (status.status != DischargeStatus.ready)
                              TextButton.icon(
                                onPressed:
                                    () => showDischargeDetails(
                                      context,
                                      status.status,
                                      status.missingItems,
                                    ),
                                icon: const Icon(
                                  Icons.info_outline,
                                  color: Colors.redAccent,
                                ),
                                label: const Text(
                                  'Ver requisitos pendientes para el alta',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                          ],
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPatientHeader(Patient p) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: green, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${p.lastName}, ${p.firstName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            'DNI: ${p.dni}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
