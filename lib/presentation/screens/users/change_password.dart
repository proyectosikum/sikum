import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/presentation/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  bool _showOld = true;
  bool _showNew = true;
  bool _showConfirm = true;

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
    if (newPass.length < 6) {
      messenger.showSnackBar(
        const SnackBar(content: Text('La nueva contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }
    if (newPass != confirm) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    if (oldPass == newPass) {
      messenger.showSnackBar(
        const SnackBar(content: Text('La nueva contraseña no puede ser igual a la actual')),
      );
      return;
    }

    setState(() => _loading = true);

    final success = await ref.read(authActionsProvider).changePassword(oldPass, newPass);

    setState(() => _loading = false);

    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada')),
      );

      await ref.read(authActionsProvider).logout();
      context.go('/login');
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Contraseña actual incorrecta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);
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
                      _buildPasswordField(
                        label: 'Contraseña actual',
                        controller: _oldPassController,
                        showText: _showOld,
                        onToggle: () => setState(() => _showOld = !_showOld),
                        fillColor: cream,
                        textColor: Colors.black87,
                        labelColor: cream,
                      ),

                      const SizedBox(height: 16),

                      // Nueva contraseña
                      _buildPasswordField(
                        label: 'Nueva contraseña',
                        controller: _newPassController,
                        showText: _showNew,
                        onToggle: () => setState(() => _showNew = !_showNew),
                        fillColor: cream,
                        textColor: Colors.black87,
                        labelColor: cream,
                      ),

                      const SizedBox(height: 16),

                      // Repetir contraseña
                      _buildPasswordField(
                        label: 'Repetir contraseña',
                        controller: _confirmController,
                        showText: _showConfirm,
                        onToggle: () => setState(() => _showConfirm = !_showConfirm),
                        fillColor: cream,
                        textColor: Colors.black87,
                        labelColor: cream,
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
                                  side: const BorderSide(color: cream),
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
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 24, height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(cream),
                                          ),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool showText,
    required VoidCallback onToggle,
    required Color fillColor,
    required Color textColor,
    required Color labelColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: labelColor, fontSize: 18),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: showText,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                showText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
