import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/evolution_provider.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/evolution_card.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:sikum/router/app_router.dart';
import 'package:sikum/services/epicrisis_pdf_service.dart';
import 'package:sikum/utils/string_utils.dart';

class PatientDetailsScreen extends ConsumerStatefulWidget {
  final String patientId;
  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends ConsumerState<PatientDetailsScreen> {
  String selectedSpecialty = 'Todas';

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(patientDetailsStreamProvider(widget.patientId));
    const green = Color(0xFF4F959D);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: green)),
        error: (_, __) => const Center(child: Text('Error al cargar paciente')),
        data: (p) {
          if (p == null) {
            return const Center(child: Text('Paciente no encontrado'));
          }
          return _buildContent(context, p);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Patient p) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);
    const black = Colors.black87;
    final userSpecLabel = authChangeNotifier.specialty ?? '';

    final evolutionsAsync = ref.watch(evolutionsStreamProvider(p.id));

    final closure = p.closureOfHospitalization;
    final bool allowEpicrisis = closure != null && closure['reason'] == 'clinical_discharge';

    final bool showActions = p.available || allowEpicrisis;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
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
                          'Detalle de paciente',
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLink(context, 'Datos maternos', '/pacientes/${p.id}/maternos', green),
                              const SizedBox(height: 8),
                              _buildLink(context, 'Datos de nacimiento', '/pacientes/${p.id}/nacimiento', green),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/pacientes/editar/${p.id}'),
                          style: TextButton.styleFrom(
                            foregroundColor: green,
                          ),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Editar paciente'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      const Text(
                        'Evolución',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: black),
                      ),
                      const Spacer(),
                      evolutionsAsync.when(
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                        data: (list) {
                          final specs = <String>{ for (var e in list) e.specialty }..removeWhere((s) => s.isEmpty);
                          final options = ['Todas', ...specs.toList()..sort()];
                          if (!options.contains(selectedSpecialty)) {
                            selectedSpecialty = 'Todas';
                          }
                          return PopupMenuButton<String>(
                            color: cream,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: green),
                            ),
                            initialValue: selectedSpecialty,
                            onSelected: (value) {
                              setState(() => selectedSpecialty = value);
                            },
                            itemBuilder: (_) {
                              return options.map((s) {
                                final label = getSpecialtyDisplayName(s);
                                return PopupMenuItem(
                                  value: s,
                                  child: Text(label),
                                );
                              }).toList();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cream,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: green, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    selectedSpecialty == 'Todas'
                                      ? 'Todas'
                                      : getSpecialtyDisplayName(selectedSpecialty),
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  evolutionsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: green)),
                    error: (_, __) => const Center(child: Text('Error al cargar evoluciones')),
                    data: (list) {
                      final filtered = selectedSpecialty == 'Todas'
                          ? list
                          : list.where((e) => e.specialty == selectedSpecialty).toList();
                      if (filtered.isEmpty) {
                        return const Center(child: Text('Sin evoluciones registradas'));
                      }
                      return Column(
                        children: filtered
                            .map((e) => EvolutionCard(evolution: e, patientId: p.id))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          if (showActions)
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
                      context.push('/paciente/evolucionar/${p.id}');
                      break;
                    case 'cerrar':
                      context.push('/pacientes/${p.id}/cerrar');
                      break;
                    case 'descargar_epicrisis':
                      EpicrisisPdfService.downloadEpicrisisPdf(p);
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
                    children: const [
                      Text('Seleccione una acción...', style: TextStyle(fontSize: 16)),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                itemBuilder: (_) {
                  if (!p.available) {
                    return const [
                      PopupMenuItem(
                        value: 'descargar_epicrisis',
                        child: Text('Descargar Epicrisis'),
                      ),
                    ];
                  }
                  final items = <PopupMenuEntry<String>>[
                    const PopupMenuItem(value: 'evolucionar', child: Text('Evolucionar')),
                  ];
                  if (userSpecLabel == 'Neonatología') {
                    items.add(const PopupMenuItem(value: 'cerrar', child: Text('Cerrar HC')));
                  }
                  return items;
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLink(BuildContext context, String text, String route, Color color) {
    return InkWell(
      onTap: () => GoRouter.of(context).push(route),
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
