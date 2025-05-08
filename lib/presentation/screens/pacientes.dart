import 'package:flutter/material.dart';
import 'package:sikum/core/data/pacientes_fake.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/filter_buttons.dart';
import 'package:sikum/presentation/widgets/paciente_card.dart';
import 'package:sikum/presentation/widgets/screen_subtitle.dart';
import 'package:sikum/presentation/widgets/search_field.dart';

class Pacientes extends StatefulWidget {
  const Pacientes({super.key});

  @override
  State<Pacientes> createState() => _PacientesState();
}


class _PacientesState extends State<Pacientes> {
  bool mostrarActivos = true;
  String searchText = '';


  @override
  Widget build(BuildContext context) {

    final pacientesFiltrados = pacienteList.where((u) {
      final coincideEstado = u.estaActivo == mostrarActivos;
      final coincideBusqueda = u.nombre.toLowerCase().contains(searchText.toLowerCase()) || u.apellido.toLowerCase().contains(searchText.toLowerCase()) ||
          u.dni.contains(searchText); 
      return coincideEstado && coincideBusqueda;
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
                  mostrarActivos: mostrarActivos,
                  onChanged: (value) {
                    setState(() {
                      mostrarActivos = value;
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
              child: pacientesFiltrados.isEmpty
                  ? const Center(child: Text('No se encontraron pacientes.'))
                  : ListView.builder(
                      itemCount: pacientesFiltrados.length,
                      itemBuilder: (context, index) {
                        return PacienteCard(paciente: pacientesFiltrados[index]);
                      },
                    ),
            ),
          ],
        ),
      )

    );
  }
}