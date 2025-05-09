import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:sikum/router/app_router.dart';

class UserDetailsScreen extends StatelessWidget {
  final String? userId;

  const UserDetailsScreen({super.key, this.userId});

  Future<DocumentSnapshot<Map<String, dynamic>>> _loadUserDoc() {
    final firestore = FirebaseFirestore.instance;

    if (userId != null) {
      // Traer por id de documento
      return firestore.collection('users').doc(userId!).get();
    }

    // Si no, por email del logged-in
    final email = FirebaseAuth.instance.currentUser?.email;
    return firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get()
        .then((q) => q.docs.first);
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);
    const black = Colors.black87;
    final role = authChangeNotifier.role;

    return Scaffold(
      backgroundColor: cream,
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _loadUserDoc(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Error al cargar datos'));
          }

          final doc    = snap.data!;
          final data   = doc.data()!;
          final name      = data['name']      as String? ?? '';
          final surname   = data['surname']   as String? ?? '';
          final dni       = data['dni']       as String? ?? '';
          final email     = data['email']     as String? ?? '';
          final phone     = data['phone']     as String? ?? '';
          final provReg   = data['provReg']   as String? ?? '';
          final specialty = data['specialty'] as String? ?? '';
          final available = data['available'] as bool?   ?? false;
          final id        = doc.id;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Detalle usuario',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: black, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow('Nombre:', name),
                        const SizedBox(height: 16),
                        _buildRow('Apellido:', surname),
                        const SizedBox(height: 16),
                        _buildRow('DNI:', dni),
                        const SizedBox(height: 16),
                        _buildRow('Email:', email),
                        const SizedBox(height: 16),
                        _buildRow('Teléfono:', phone),
                        const SizedBox(height: 16),
                        _buildRow('Matrícula provincial:', provReg),
                        const SizedBox(height: 16),
                        _buildRow('Especialidad:', specialty),
                        const SizedBox(height: 16),
                        _buildRow('Activo:', available ? 'Sí' : 'No'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  if (role == 'admin') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Volver
                        _circleButton(
                          icon: Icons.arrow_back_rounded,
                          color: green,
                          onTap: () {
                            final destino = role == 'admin'
                                ? '/usuarios'
                                : '/pacientes';
                            context.go(destino);
                          },
                        ),
                        const SizedBox(width: 64),

                        // Editar
                        _circleButton(
                          icon: Icons.edit,
                          color: green,
                          onTap: () =>
                              context.push('/usuario/editar', extra: id),
                        ),
                        const SizedBox(width: 64),

                        // Borrar o Reactivar
                        _circleButton(
                          icon: available
                              ? Icons.delete
                              : Icons.refresh,       // icono de reactivar
                          color: available
                              ? Colors.redAccent
                              : green,               // color acorde
                          onTap: () async {
                            // Actualiza el campo 'available'
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(id)
                                .update({'available': !available});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  available
                                      ? 'Usuario desactivado'
                                      : 'Usuario reactivado',
                                ),
                              ),
                            );
                            // recargo la misma ruta para refrescar datos
                            final currentLocation = GoRouter.of(context).location;
                            context.go(currentLocation);
                          },
                        ),
                      ],
                    ),
                  ] else ...[
                    // Usuario normal: solo volver
                    _circleButton(
                      icon: Icons.arrow_back_rounded,
                      color: green,
                      onTap: () {
                        final destino = role == 'admin'
                            ? '/usuarios'
                            : '/pacientes';
                        context.go(destino);
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    const cream = Color(0xFFFFF8E1);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: cream,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, size: 28, color: color),
      ),
    );
  }
}
