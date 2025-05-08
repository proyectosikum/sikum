import 'package:flutter/material.dart';
import 'package:sikum/core/data/patient_fake.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/filter_buttons.dart';
import 'package:sikum/presentation/widgets/patient_card.dart';
import 'package:sikum/presentation/widgets/screen_subtitle.dart';
import 'package:sikum/presentation/widgets/search_field.dart';

class Patients extends StatefulWidget {
  const Patients({super.key});

  @override
  State<Patients> createState() => _PacientesState();
}


class _PacientesState extends State<Patients> {
  bool showAssets = true;
  String searchText = '';


  @override
  Widget build(BuildContext context) {

    final filteredPatients = patientList.where((u) {
      final matchesState = u.isActive == showAssets;
      final matchesSearch = u.name.toLowerCase().contains(searchText.toLowerCase()) || u.lastName.toLowerCase().contains(searchText.toLowerCase()) ||
          u.dni.contains(searchText); 
      return matchesState && matchesSearch;
    }).toList();


    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: CustomAppBar(
        onLogout: () {

        }
        ),
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
                    // Acción de agregar usuario
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
      )

    );
  }
}