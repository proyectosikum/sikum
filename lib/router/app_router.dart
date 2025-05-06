import 'package:go_router/go_router.dart';
import 'package:sikum/services/auth_notifier.dart';
import 'package:sikum/presentation/screens/login/login.dart';

final authNotifier = AuthNotifier();

final GoRouter appRouter = GoRouter(
  refreshListenable: authNotifier,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    // GoRoute(path: '/home',  builder: (_, __) => const HomeScreen()),
  ],
  redirect: (context, state) {
    final loggedIn  = authNotifier.isLoggedIn;
    final loggingIn = state.matchedLocation == '/login';

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn)  return '/home';
    return null;
  },
);
