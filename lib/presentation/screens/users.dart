import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../../core/data/users_fake.dart';
import '../widgets/user_card.dart';
import '../widgets/search_field.dart';
import '../widgets/filter_buttons.dart';
import '../widgets/screen_subtitle.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<Users> {
  bool showAssets = true;
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final filteredUsers = userList.where((u) {
      final matchesState = u.isActive == showAssets;
      final matchesSearch = u.name.toLowerCase().contains(searchText.toLowerCase()) ||
          u.dni.contains(searchText);
      return matchesState && matchesSearch;
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
                  child: const Icon(Icons.add, color: Color(0xFFFFF8E1)),
                  mini: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(child: Text('No se encontraron usuarios.'))
                  : ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        return UserCard(user: filteredUsers[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
