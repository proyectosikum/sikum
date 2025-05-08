import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikum/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _usuarioController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final user = _usuarioController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (user.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu usuario')),
      );
      return;
    }
    setState(() => _loading = true);

    // 1) Buscamos el email en Firestore
    final query = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('user', isEqualTo: user)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      setState(() => _loading = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Usuario no encontrado')),
      );
      return;
    }

    final email = query.docs.first.data()['email'] as String?;

    if (email == null) {
      setState(() => _loading = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Email no vinculado a usuario')),
      );
      return;
    }

    // 2) Enviamos email de recuperación
    final success =
        await AuthService.instance.sendPasswordResetEmail(email);
    setState(() => _loading = false);

    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Revisa tu correo para restablecer tu contraseña'),
        ),
      );
      context.go('/login');
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Error al enviar el correo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const green       = Color(0xFF4F959D);
    const cream       = Color(0xFFFFF8E1);
    const borderColor = Color(0xFFB2D4E1);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        leading: const BackButton(color: cream),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'Olvidé mi contraseña',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: green,
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: green,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Usuario',
                          style: TextStyle(
                            color: cream,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Input de usuario
                      TextField(
                        controller: _usuarioController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: cream,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: OutlinedButton(
                                onPressed:
                                    _loading ? null : () => context.pop(),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: green,
                                  side: BorderSide(color: cream),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(25),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: const Text('Cancelar',
                                    style: TextStyle(color: cream)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                onPressed: _loading
                                    ? null
                                    : _sendResetEmail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cream,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: _loading
                                    ? const CircularProgressIndicator()
                                    : Text('Aceptar',
                                        style: TextStyle(color: green)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
