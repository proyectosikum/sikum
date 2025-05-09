import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/filter_buttons.dart';
import 'package:sikum/presentation/widgets/patient_card.dart';
import 'package:sikum/presentation/widgets/screen_subtitle.dart';
import 'package:sikum/presentation/widgets/search_field.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

class Patients extends ConsumerStatefulWidget {
  const Patients({super.key});

  @override
  ConsumerState<Patients> createState() => _PatientsState();
}

class _PatientsState extends ConsumerState<Patients> {
  bool showAssets = true;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    ref.read(patientProvider.notifier).getAllPatients();
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientProvider);

    final filteredPatients = patients.where((u) {
      final matchesState = u.available == showAssets;
      final matchesSearch = u.name.toLowerCase().contains(searchText.toLowerCase()) ||
          u.lastName.toLowerCase().contains(searchText.toLowerCase()) ||
          u.dni.toString().contains(searchText);
      return matchesState && matchesSearch;
    }).toList();

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
            SearchField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterButtons(
                  showAssets: showAssets,
                  onChanged: (value) {
                    setState(() {
                      showAssets = value;
                    });
                  },
                ),
                FloatingActionButton(
                  heroTag: 'addUserBtn',
                  onPressed: () {
                    /*
                    final newPatient = Patient(
                      id: 'test-id',
                      name: 'Juan',
                      lastName: 'Pérez',
                      dni: '12345678',
                      isActive: true,
                    );
                    ref.read(patientProvider.notifier).addPatient(newPatient);*/
                  },
                  backgroundColor: const Color(0xFF4F959D),
                  mini: true,
                  child: const Icon(Icons.add, color: Color(0xFFFFF8E1)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredPatients.isEmpty
                  ? const Center(child: Text('No se encontraron pacientes.'))
                  : ListView.builder(
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        return PatientCard(patient: filteredPatients[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
