import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikum/presentation/screens/create_users.dart';
import 'package:sikum/presentation/screens/login.dart';
import 'package:sikum/presentation/screens/forgot_password.dart';
import 'package:sikum/presentation/screens/change_password.dart';
import 'package:sikum/presentation/screens/patients.dart';
import 'package:sikum/presentation/screens/users.dart';
import 'package:sikum/services/auth_notifier.dart';

final authChangeNotifier = AuthChangeNotifier();

final GoRouter appRouter = GoRouter(
  refreshListenable: authChangeNotifier,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login',        builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/usuarios',     builder: (_, __) => const Users()),
    GoRoute(path: '/altaUsuarios', builder: (_, __) => const CreateUsers()),
    GoRoute(path: '/pacientes',    builder: (_, __) => const Patients()),
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
