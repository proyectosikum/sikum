import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikum/presentation/screens/login/login.dart';
import 'package:sikum/presentation/screens/auth/forgot_password_screen.dart';
import 'package:sikum/presentation/screens/auth/change_password_screen.dart';
import 'package:sikum/services/auth_notifier.dart';

final authChangeNotifier = AuthChangeNotifier();

final GoRouter appRouter = GoRouter(
  refreshListenable: authChangeNotifier,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login',     builder: (_, __) => const LoginScreen()),
    // GoRoute(path: '/home',      builder: (_, __) => const HomeScreen()),
    // GoRoute(path: '/homeAdmin', builder: (_, __) => const HomeAdminScreen()),
    GoRoute(path: '/forgot',    builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/change',    builder: (_, __) => const ChangePasswordScreen()),
  ],
  redirect: (context, state) {
    final user     = FirebaseAuth.instance.currentUser;
    final loggedIn = user != null;
    final loc      = state.matchedLocation;
    const publicPaths = ['/login','/forgot','/change'];

    if (!loggedIn && !publicPaths.contains(loc)) return '/login';

    if (loggedIn && loc == '/login') {
      if (authChangeNotifier.needsChange) return '/change';
      return authChangeNotifier.role=='admin' ? '/homeAdmin' : '/home';
    }

    return null;
  }
);
