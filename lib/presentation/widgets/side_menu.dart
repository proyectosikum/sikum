import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/router/app_router.dart';
import 'package:sikum/services/auth_service.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFF8E1);
    const green = Color(0xFF4F959D);
    const borderGrey = Color(0xFFB2D4E1);

    final displayName = authChangeNotifier.displayName;

    return Drawer(
      elevation: 0,
      child: Container(
        color: cream,
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

            // Opciones de menú
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              label: 'Perfil',
              onTap: () => context.go('/perfil'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.people_alt_outlined,
              label: 'Pacientes',
              onTap: () => context.go('/pacientes'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.show_chart_outlined,
              label: 'Evolucionar',
              onTap: () => context.go('/evolucionar'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.bar_chart_outlined,
              label: 'Estadísticas',
              onTap: () => context.go('/estadisticas'),
            ),

            const Spacer(),

            // Logout
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await AuthService.instance.logout();
                    context.go('/login');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
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
