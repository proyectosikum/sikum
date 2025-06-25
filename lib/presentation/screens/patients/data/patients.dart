import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/screens/patients/data/add_patients.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/filter_buttons.dart';
import 'package:sikum/presentation/widgets/patient_card.dart';
import 'package:sikum/presentation/widgets/screen_subtitle.dart';
import 'package:sikum/presentation/widgets/search_field.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:sikum/presentation/providers/discharge_status_provider.dart';

class Patients extends ConsumerStatefulWidget {
  const Patients({super.key});

  @override
  ConsumerState<Patients> createState() => _PatientsState(); //devuelve instancia de la clase que va a manejar el estado
}

class _PatientsState extends ConsumerState<Patients> {
  bool showAssets = true;
  String searchText = '';

  void _onSearchChanged(String value) {
    setState(() => searchText = value);
  }

  void _onFilterChanged(bool value) {
    setState(() => showAssets = value);
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenSubtitle(text: 'Pacientes'),

            SearchField(onChanged: _onSearchChanged),
            const SizedBox(height: 8),

            //Filtros y boton de agregar paciente
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterButtons(
                  showAssets: showAssets,
                  onChanged: _onFilterChanged,
                ),
                FloatingActionButton(
                  heroTag: 'addUserBtn',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddPatientsScreen(),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFF4F959D),
                  mini: true,
                  child: const Icon(Icons.add, color: Color(0xFFFFF8E1)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            
            Expanded(
              child: patientsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) =>
                        Center(child: Text('Error al cargar pacientes: $e')),
                data: (allPatients) {
                  final filtered =
                      allPatients.where((u) {
                        final matchesState = u.available == showAssets;
                        final matchesSearch =
                            u.firstName.toLowerCase().contains(
                              searchText.toLowerCase(),
                            ) ||
                            u.lastName.toLowerCase().contains(
                              searchText.toLowerCase(),
                            ) ||
                            u.dni.toString().contains(searchText);
                        return matchesState && matchesSearch;
                      }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron pacientes.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      final dischargeStatusAsync = ref.watch(
                        dischargeStatusProvider(p),
                      );

                      return dischargeStatusAsync.when(
                        data:
                            (dischargeResult) => PatientCard(
                              patient: p,
                              onTap:
                                  () =>
                                      context.push('/paciente/detalle/${p.id}'),
                              status: dischargeResult.status,
                              missingItems: dischargeResult.missingItems,
                            ),
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (e, _) => ListTile(
                              title: Text('${p.firstName} ${p.lastName}'),
                              subtitle: const Text(
                                'Error al evaluar estado de alta',
                              ),
                              trailing: const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
