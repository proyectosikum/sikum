import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/presentation/providers/user_provider.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/filter_buttons.dart';
import 'package:sikum/presentation/widgets/search_field.dart';
import 'package:sikum/presentation/widgets/screen_subtitle.dart';
import 'package:sikum/presentation/widgets/user_card.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  bool showAvailable = true;
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersStreamProvider);

    // Perfil actual: usamos el provider de detalle con NULL para buscar por email
    final currentUserAsync = ref.watch(userDetailsStreamProvider(null));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error al cargar perfil')),
        data: (currentUser) {
          if (currentUser == null) {
            return const Center(child: Text('Perfil no encontrado'));
          }

          return usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, _) => Center(child: Text('Error al cargar usuarios: $e')),
            data: (users) {
              final filtered =
                  users.where((u) {
                    if (u.userId == currentUser.userId) return false;
                    if (u.role == 'admin') return false;
                    if (u.available != showAvailable) return false;

                    final fullName =
                        '${u.firstName} ${u.lastName}'.toLowerCase();
                    final query = searchText.toLowerCase();
                    final matchesName = fullName.contains(query);
                    final matchesDni = u.dni.toString().contains(searchText);
                    return searchText.isEmpty || matchesName || matchesDni;
                  }).toList();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScreenSubtitle(text: 'Usuarios'),
                    SearchField(
                      onChanged: (v) => setState(() => searchText = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FilterButtons(
                          showAssets: showAvailable,
                          onChanged: (v) => setState(() => showAvailable = v),
                        ),
                        FloatingActionButton(
                          heroTag: 'addUserBtn',
                          onPressed: () => context.push('/usuarios/crear'),
                          backgroundColor: const Color(0xFF4F959D),
                          mini: true,
                          child: const Icon(
                            Icons.add,
                            color: Color(0xFFFFF8E1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          filtered.isEmpty
                              ? const Center(
                                child: Text('No se encontraron usuarios.'),
                              )
                              : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder:
                                    (_, i) => UserCard(user: filtered[i]),
                              ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
