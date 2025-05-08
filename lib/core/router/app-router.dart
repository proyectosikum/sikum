import 'package:go_router/go_router.dart';
import 'package:sikum/presentation/screens/pacientes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/pacientes',
  routes: [
  GoRoute(
    path: '/pacientes',
    builder: (context, state) => Pacientes(),)


]);