import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/entities/user.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/screen_subtitle.dart';
import 'package:sikum/presentation/widgets/search_field.dart';
import 'package:sikum/presentation/widgets/filter_buttons.dart';
import 'package:sikum/presentation/widgets/user_card.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool showAssets = true;
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenSubtitle(text: 'Usuarios'),
            SearchField(
              onChanged: (value) => setState(() => searchText = value),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterButtons(
                  showAssets: showAssets,
                  onChanged: (v) => setState(() => showAssets = v),
                ),
                FloatingActionButton(
                  heroTag: 'addUserBtn',
                  onPressed: () => context.push('/usuarios/crear'),
                  backgroundColor: const Color(0xFF4F959D),
                  mini: true,
                  child: const Icon(Icons.add, color: Color(0xFFFFF8E1)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No se encontraron usuarios.'));
                  }

                  // mapeo a nuestra entidad
                  final allUsers = snap.data!.docs
                      .map((doc) => User.fromDoc(doc))
                      .toList();

                  // filtrado local
                  final filtered = allUsers.where((u) {
                    final matchesState = u.available == showAssets;
                    final matchesSearch =
                        u.name.toLowerCase().contains(searchText.toLowerCase()) ||
                        u.dni.contains(searchText);
                    return matchesState && matchesSearch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                        child: Text('No se encontraron usuarios.'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      return UserCard(user: filtered[i]);
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
