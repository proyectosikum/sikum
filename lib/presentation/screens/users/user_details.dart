// lib/presentation/screens/users/user_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sikum/entities/user.dart';
import 'package:sikum/presentation/providers/user_provider.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

class UserDetailsScreen extends ConsumerWidget {
  final String? userId;
  const UserDetailsScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const green = Color(0xFF4F959D);

    // Si hay userId específico, usar userDetailsStreamProvider
    // Si no hay userId, usar userDetailsStreamProvider(null) que busca por email
    final detailAsync = ref.watch(userDetailsStreamProvider(userId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: detailAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: green)),
        error: (error, stack) {
          debugPrint('Error en UserDetailsScreen: $error');
          return const Center(child: Text('Error al cargar datos del usuario'));
        },
        data: (u) {
          if (u == null) {
            return const Center(child: Text('Usuario no encontrado'));
          }
          return _buildContent(context, ref, u, u.role);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    User u,
    String role,
  ) {
    const cream = Color(0xFFFFF8E1);
    const black = Colors.black87;
    const green = Color(0xFF4F959D);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              userId == null ? 'Mi Perfil' : 'Detalle usuario',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: black,
              ),
            ),
            const SizedBox(height: 32),
            _infoCard(u, cream, black),
            const SizedBox(height: 48),
            _buildActions(context, ref, u, role, green),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(User u, Color bg, Color border) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Nombre:', u.firstName),
            const SizedBox(height: 16),
            _buildRow('Apellido:', u.lastName),
            const SizedBox(height: 16),
            _buildRow('DNI:', u.dni),
            const SizedBox(height: 16),
            _buildRow('Email:', u.email),
            const SizedBox(height: 16),
            _buildRow('Teléfono:', u.phone),
            const SizedBox(height: 16),
            _buildRow('Matrícula prov.:', u.provReg),
            const SizedBox(height: 16),
            _buildRow('Especialidad:', u.specialty),
            const SizedBox(height: 16),
            _buildRow('Activo:', u.available ? 'Sí' : 'No'),
            const SizedBox(height: 16),
            _buildRow('Rol:', u.role),
          ],
        ),
      );

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    User u,
    String role,
    Color green,
  ) {
    // Si estamos viendo nuestro propio perfil (userId == null)
    final isOwnProfile = userId == null;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton(
          icon: Icons.arrow_back_rounded,
          color: green,
          onTap: () =>
              context.go(role == 'admin' ? '/usuarios' : '/pacientes'),
        ),
        // Solo mostrar acciones de admin si NO es el propio perfil Y el rol es admin
        if (!isOwnProfile && role == 'admin') ...[
          const SizedBox(width: 64),
          _circleButton(
            icon: Icons.edit,
            color: green,
            onTap: () => context.push('/usuario/editar', extra: u.id),
          ),
          const SizedBox(width: 64),
          _circleButton(
            icon: u.available ? Icons.delete : Icons.refresh,
            color: u.available ? Colors.redAccent : green,
            onTap: () async {
              await ref
                  .read(userActionsProvider)
                  .toggleAvailability(u.id, !u.available);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      u.available ? 'Usuario desactivado' : 'Usuario reactivado',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ],
    );
  }

  RichText _buildRow(String label, String value) => RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value.isEmpty ? 'No especificado' : value),
          ],
        ),
      );

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, size: 28, color: color),
        ),
      );
}
