import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../../core/data/usuarios_fake.dart';
import '../widgets/user_card.dart';
import '../widgets/search_field.dart';
import '../widgets/filter_buttons.dart';
import '../widgets/screen_subtitle.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  bool mostrarActivos = true;
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final usuariosFiltrados = usuarioList.where((u) {
      final coincideEstado = u.activo == mostrarActivos;
      final coincideBusqueda = u.nombre.toLowerCase().contains(searchText.toLowerCase()) ||
          u.dni.contains(searchText);
      return coincideEstado && coincideBusqueda;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: CustomAppBar(
        //title: 'Usuarios',
        onLogout: () {
          // Lógica de cerrar sesión
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenSubtitle(text: 'Usuarios'),
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
                  child: const Icon(Icons.add, color: Color(0xFFFFF8E1)),
                  mini: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: usuariosFiltrados.isEmpty
                  ? const Center(child: Text('No se encontraron usuarios.'))
                  : ListView.builder(
                      itemCount: usuariosFiltrados.length,
                      itemBuilder: (context, index) {
                        return UserCard(usuario: usuariosFiltrados[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
