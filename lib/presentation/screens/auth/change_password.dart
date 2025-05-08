import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikum/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final messenger = ScaffoldMessenger.of(context);
    final oldPass = _oldPassController.text;
    final newPass = _newPassController.text;
    final confirm = _confirmController.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }
    if (newPass != confirm) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _loading = true);
    final success =
        await AuthService.instance.changePassword(oldPass, newPass);
    setState(() => _loading = false);

    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada')),
      );

      await FirebaseAuth.instance.signOut();
      context.go('/login');
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Contraseña actual incorrecta')),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'Cambiar contraseña',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: green,
                  ),
                ),

                const SizedBox(height: 32),

                // Card con fondo verde
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
                      // Contraseña actual
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Contraseña actual',
                          style: TextStyle(
                            color: cream,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _oldPassController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cream,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Nueva contraseña
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Nueva contraseña',
                          style: TextStyle(
                            color: cream,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newPassController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cream,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Repetir contraseña...
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Repetir contraseña',
                          style: TextStyle(
                            color: cream,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cream,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
                                onPressed: _loading ? null : () => context.pop(),
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
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(color: cream),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _changePassword,
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
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: green,
                                        ),
                                      )
                                    : const Text(
                                        'Aceptar',
                                        style: TextStyle(color: green),
                                      ),
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
