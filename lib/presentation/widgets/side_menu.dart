// lib/presentation/widgets/side_menu.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/presentation/providers/auth_provider.dart';
import 'package:sikum/services/auth_notifier.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const cream = Color(0xFFFFF8E1);
    const green = Color(0xFF4F959D);
    const borderGrey = Color(0xFFB2D4E1);

    final authChange = ref.watch(authChangeProvider);
    final displayName = authChange.displayName;
    final role        = authChange.role ?? 'user';

    return Drawer(
      child: Container(
        color: cream,
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.person, color: green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, color: green),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: borderGrey, height: 32, thickness: 1),

            // Menú
            _buildMenuItem(context, icon: Icons.person_outline, label: 'Perfil', onTap: () => context.go('/perfil')),
            if (role == 'admin') ...[
              _buildMenuItem(context, icon: Icons.people_alt_outlined, label: 'Usuarios', onTap: () => context.go('/usuarios')),
              _buildMenuItem(context, icon: Icons.person_add_alt, label: 'Crear usuario', onTap: () => context.go('/usuarios/crear')),
            ] else ...[
              _buildMenuItem(context, icon: Icons.people_alt_outlined, label: 'Pacientes', onTap: () => context.go('/pacientes')),
              _buildMenuItem(context, icon: Icons.show_chart_outlined, label: 'Evolucionar', onTap: () => context.go('/pacientes')),
            ],
            _buildMenuItem(context, icon: Icons.bar_chart_outlined, label: 'Estadísticas', onTap: () => context.go('/estadisticas')),

            const Spacer(),

            // Logout
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await ref.read(authActionsProvider).logout();
                    context.go('/login');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Cerrar sesión', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.exit_to_app, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(label, style: const TextStyle(color: Colors.black87)),
      trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.black54),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}
