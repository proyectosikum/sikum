import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikum/presentation/screens/patients/birth/birth_data_form.dart';
import 'package:sikum/presentation/screens/patients/data/edit_patient.dart'; // Asegúrate de que el path sea correcto
import 'package:sikum/presentation/screens/statistics/statistics.dart';
import 'package:sikum/presentation/screens/users/create_users.dart';
import 'package:sikum/presentation/screens/patients/evolutions/evolution_details.dart';
import 'package:sikum/presentation/screens/patients/evolutions/evolution_form_screen.dart';
import 'package:sikum/presentation/screens/users/login.dart';
import 'package:sikum/presentation/screens/users/forgot_password.dart';
import 'package:sikum/presentation/screens/users/change_password.dart';
import 'package:sikum/presentation/screens/patients/data/patient_details.dart';
import 'package:sikum/presentation/screens/patients/data/patients.dart';
import 'package:sikum/presentation/screens/patients/maternal/maternal_form.dart';
import 'package:sikum/presentation/screens/users/edit_user.dart';
import 'package:sikum/presentation/screens/users/user_details.dart';
import 'package:sikum/presentation/screens/users/users.dart';
import 'package:sikum/services/auth_notifier.dart';

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
    GoRoute(
      path: '/usuario/editar',
      builder: (context, state) {
        final userId = state.extra as String;
        return EditUser(userId: userId);
      },
    ),
    GoRoute(path: '/pacientes',       builder: (_, __) => const Patients()),
    GoRoute(path: '/forgot',          builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/change',          builder: (_, __) => const ChangePasswordScreen()),
    GoRoute(
      path: '/pacientes/editar/:patientId',
      builder: (context, state) {
        final patientId = state.pathParameters['patientId']!;
        // Ya no necesitamos pasar patientData como extra
        // El nuevo widget obtiene los datos directamente del provider
        return EditPatientScreen(
          patientId: patientId,
        );
      },
    ),
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
    GoRoute(
      path: '/pacientes/:patientId/maternos',
      builder: (context, state) {
        final id = state.pathParameters['patientId']!;
        return MaternalForm(patientId: id);
      },
    ),
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
    GoRoute(
      path: '/pacientes/:patientId/nacimiento',
      builder: (context, state) {
        final id = state.pathParameters['patientId']!;
        return BirthDataForm(patientId: id);
      },
    ),
    GoRoute(
      path: '/estadisticas',
      builder: (_, __) => const Statistics(),
    ),
  ],
  redirect: (context, state) {
    final user     = FirebaseAuth.instance.currentUser;
    final loggedIn = user != null;
    final loc      = state.matchedLocation;

    const publicPaths = ['/login','/forgot','/change'];

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
        '/usuario/editar',
        '/perfil',
        '/change',
        '/forgot',
        '/estadisticas'
      ].any((p) => p == loc) || loc.startsWith('/usuario/detalle');

      if (isAdmin && !okAdmin) {
        return '/usuarios';
      }

      final okUser = [
        '/pacientes',
        '/perfil',
        '/change',
        '/forgot',
        '/estadisticas'
      ].any((p) => p == loc)
        || loc.startsWith('/paciente/detalle')
        || loc.startsWith('/paciente/evolucionar')
        || loc.startsWith('/pacientes') && (loc.contains('/maternos') || loc.contains('/evolutions') || loc.contains('/editar'))
        || loc.startsWith('/pacientes') && loc.contains('/nacimiento');

      if (!isAdmin && !okUser) {
        return '/pacientes';
      }
    }

    return null;
  }
);