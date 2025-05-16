import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/providers/evolution_provider.dart';
import 'package:sikum/presentation/widgets/evolution_card.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

class PatientDetailsScreen extends ConsumerWidget {
  final String patientId;
  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(patientDetailsStreamProvider(patientId));
    const green = Color(0xFF4F959D);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: green)),
        error:   (_, __) => const Center(child: Text('Error al cargar paciente')),
        data:    (p) {
          if (p == null) {
            return const Center(child: Text('Paciente no encontrado'));
          }
          return _buildContent(context, ref, p);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Patient p) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);
    const black = Colors.black87;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Detalle de paciente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'DNI: ${p.dni}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLink(context, 'Datos maternos', '/pacientes/${p.id}/maternos', green),
                        const SizedBox(height: 8),
                        _buildLink(context, 'Datos de nacimiento', '/pacientes/${p.id}/nacimiento', green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Evolución',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: black),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Evoluciones dinámicas en tiempo real
                  Consumer(
                    builder: (ctx, ref, _) {
                      final evolutionsAsync = ref.watch(evolutionsStreamProvider(p.id));
                      return evolutionsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator(color: green)),
                        error:   (_, __) => const Center(child: Text('Error al cargar evoluciones')),
                        data:    (list) {
                          if (list.isEmpty) {
                            return const Center(child: Text('Sin evoluciones registradas'));
                          }
                          return Column(
                            children: list
                              .map((e) => EvolutionCard(evolution: e, patientId: p.id))
                              .toList(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Menú de acciones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: PopupMenuButton<String>(
              color: cream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: green),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'evolucionar':
                    context.push('/pacientes/${p.id}/evolucionar');
                    break;
                  case 'cerrar':
                    // Lógica cerrar HC
                    break;
                  case 'descargar':
                    // Lógica descargar HC
                    break;
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: green, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Seleccione una acción...', style: TextStyle(fontSize: 16)),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'evolucionar', child: Text('Evolucionar')),
                PopupMenuItem(value: 'cerrar', child: Text('Cerrar HC')),
                PopupMenuItem(value: 'descargar', child: Text('Descargar HC')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLink(BuildContext context, String text, String route, Color color) {
    return InkWell(
      onTap: () => context.push(route),
      child: Row(
        children: [
          Icon(Icons.chevron_right, color: color, size: 20),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
