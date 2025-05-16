import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/router/app_router.dart';
import 'package:sikum/services/auth_notifier.dart';
import 'package:sikum/presentation/providers/auth_provider.dart';

/// Exponemos tu AuthChangeNotifier (el de GoRouter) como provider para leer el rol
final authChangeProvider = Provider<AuthChangeNotifier>((ref) => authChangeNotifier);

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);

    final authChange = ref.watch(authChangeProvider);
    final role       = authChange.role;

    return AppBar(
      backgroundColor: green,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: InkWell(
        onTap: () {
          final target = role == 'admin' ? '/usuarios' : '/pacientes';
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
        if (role == 'admin')
          IconButton(
            iconSize: 28,
            icon: const Icon(Icons.logout, color: cream),
            onPressed: () async {
              // Usamos tu servicio de logout real
              await ref.read(authActionsProvider).logout();
              // El AuthChangeNotifier escuchará el authStateChanges y notificará al router
              context.go('/login');
            },
          )
        else
          Builder(
            builder: (ctx) => IconButton(
              iconSize: 28,
              icon: const Icon(Icons.menu, color: cream),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
