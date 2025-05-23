import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/router/app_router.dart';
import 'package:sikum/services/auth_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);

    return AnimatedBuilder(
      animation: authChangeNotifier,
      builder: (context, _) {
        final role = authChangeNotifier.role;
        return AppBar(
          backgroundColor: green,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: InkWell(
            onTap: () {
              final target = (role == 'admin') ? '/usuarios' : '/pacientes';
              context.go(target);
            },
            child: Text(
              'Sikum',
              style: GoogleFonts.kronaOne(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cream,
              ),
            ),
          ),
          actions: [
            if (role == 'admin') ...[
              IconButton(
                iconSize: 28,
                icon: const Icon(Icons.logout, color: cream),
                onPressed: () async {
                  await AuthService.instance.logout();
                  context.go('/login');
                },
              ),
            ] else ...[
              Builder(
                builder: (ctx) => IconButton(
                  iconSize: 28,
                  icon: const Icon(Icons.menu, color: cream),
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                ),
              ),
            ],
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
