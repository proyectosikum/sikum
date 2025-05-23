import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikum/presentation/screens/create_users.dart';
import 'package:sikum/presentation/screens/patients/evolutions/evolution_details.dart';
import 'package:sikum/presentation/screens/patients/evolutions/evolution_form_screen.dart';
import 'package:sikum/presentation/screens/login.dart';
import 'package:sikum/presentation/screens/forgot_password.dart';
import 'package:sikum/presentation/screens/change_password.dart';
import 'package:sikum/presentation/screens/patients/data/patient_details.dart';
import 'package:sikum/presentation/screens/patients/data/patients.dart';
import 'package:sikum/presentation/screens/user_details.dart';
import 'package:sikum/presentation/screens/users.dart';
import 'package:sikum/services/auth_notifier.dart';
import 'package:sikum/presentation/screens/patients/maternal/maternal_form.dart';

final authChangeNotifier = AuthChangeNotifier();

final GoRouter appRouter = GoRouter(
  refreshListenable: authChangeNotifier,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login',           builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/usuarios',        builder: (_, __) => const UsersScreen()),
    GoRoute(path: '/perfil',          builder: (_, __) => const UserDetailsScreen(),
    ),
    GoRoute(
      path: '/usuario/detalle/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return UserDetailsScreen(userId: id);
      },
    ),
    GoRoute(path: '/usuarios/crear',  builder: (_, __) => const CreateUsers()),
    GoRoute(path: '/pacientes',       builder: (_, __) => const Patients()),
    GoRoute(path: '/forgot',          builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/change',          builder: (_, __) => const ChangePasswordScreen()),
    GoRoute(
      path: '/paciente/detalle/:patientId',
      builder: (context, state) {
        final id = state.pathParameters['patientId']!;
        return PatientDetailsScreen(patientId: id);
      },
    ),
    GoRoute(
      path: '/paciente/evolucionar/:patientId',
      builder: (context, state) {
        final id = state.pathParameters['patientId']!;
        return EvolutionFormScreen(patientId: id);
      },
    ),

//vaneeee
GoRoute(
  path: '/pacientes/:patientId/maternos',
  builder: (context, state) {
    final id = state.pathParameters['patientId']!;
    return MaternalForm(patientId: id);
  },
),
//
// Agregar esta ruta a tu configuración de GoRouter existente
  GoRoute(
  path: '/pacientes/:patientId/evolutions/:evolutionId',
  builder: (context, state) {
    final patientId = state.pathParameters['patientId']!;
    final evolutionId = state.pathParameters['evolutionId']!;
    return EvolutionDetailsScreen(
      patientId: patientId,
      evolutionId: evolutionId,
    );
  },
),



  ],
  redirect: (context, state) {
    final user     = FirebaseAuth.instance.currentUser;
    final loggedIn = user != null;
    final loc      = state.matchedLocation;

    const publicPaths = ['/login','/forgot','/change', '/confirmacion'];

    if (!loggedIn && !publicPaths.contains(loc)) {
      return '/login';
    }

    if (loggedIn) {
      if (loc == '/login') {
        if (authChangeNotifier.needsChange) return '/change';
        return authChangeNotifier.role == 'admin'
          ? '/usuarios'
          : '/pacientes';
      }

      final isAdmin = authChangeNotifier.role == 'admin';
      final okAdmin = [
        '/usuarios',
        '/usuarios/crear',
        '/perfil',
        '/change',
        '/forgot'
      ].any((p) => p == loc) || loc.startsWith('/usuario/detalle');

      if (isAdmin && !okAdmin) {
        return '/usuarios';
      }

      final okUser = [
        '/pacientes',
        '/perfil',
        '/change',
        '/forgot',
      ].any((p) => p == loc)
        || loc.startsWith('/paciente/detalle')
        || loc.startsWith('/paciente/evolucionar')
        || loc.startsWith('/pacientes') && (loc.contains('/maternos') || loc.contains('/evolutions'));

      if (!isAdmin && !okUser) {
        return '/pacientes';
      }
    }

    return null;
  }
);
