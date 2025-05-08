import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikum/presentation/screens/crear_usuarios_screens.dart';
import 'package:sikum/presentation/screens/login.dart';
import 'package:sikum/presentation/screens/forgot_password.dart';
import 'package:sikum/presentation/screens/change_password.dart';
import 'package:sikum/presentation/screens/pacientes.dart';
import 'package:sikum/presentation/screens/usuarios_screen.dart';
import 'package:sikum/services/auth_notifier.dart';

final authChangeNotifier = AuthChangeNotifier();

final GoRouter appRouter = GoRouter(
  refreshListenable: authChangeNotifier,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login',        builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/usuarios',     builder: (_, __) => const UsuariosScreen()),
    GoRoute(path: '/altaUsuarios', builder: (_, __) => const CrearUsuariosScreen()),
    GoRoute(path: '/pacientes',    builder: (_, __) => const Pacientes()),
    GoRoute(path: '/forgot',       builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/change',       builder: (_, __) => const ChangePasswordScreen()),
  ],
  redirect: (context, state) {
    final user     = FirebaseAuth.instance.currentUser;
    final loggedIn = user != null;
    final loc      = state.matchedLocation;
    const publicPaths = ['/login','/forgot','/change'];

    if (!loggedIn && !publicPaths.contains(loc)) return '/login';

    if (loggedIn && loc == '/login') {
      if (authChangeNotifier.needsChange) return '/change';
      return authChangeNotifier.role=='admin' ? '/usuarios' : '/pacientes';
    }

    return null;
  }
);
