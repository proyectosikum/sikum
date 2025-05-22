import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _userController     = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showText = true;
  bool _loading  = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordView() => setState(() => _showText = !_showText);

  Future<void> _onLogin() async {
    final messenger = ScaffoldMessenger.of(context);
    final user = _userController.text.trim();
    final pass = _passwordController.text;

    if (user.isEmpty || pass.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Por favor completa ambos campos')),
      );
      return;
    }

    setState(() => _loading = true);

    // Aquí recibimos el LoginResult directamente
    final result = await ref.read(authActionsProvider).login(user, pass);

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result.status) {
      case LoginStatus.invalid:
        messenger.showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña inválidos')),
        );
        break;

      case LoginStatus.inactive:
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Usuario inactivo. Contacta al administrador.'),
          ),
        );
        break;

      case LoginStatus.success:
        if (result.needsChange) {
          context.go('/change');
          return;
        }
        if (result.role == 'admin') {
          context.go('/usuarios');
        } else {
          context.go('/pacientes');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF4F959D);
    const cardBorderColor = Color(0xFFB2D4E1);
    const fieldFillColor  = Color(0xFFF2F2F2);
    const buttonColor     = Color(0xFFFFF8E1);
    const titleColor      = Color(0xFFFFF8E1);
    const inputTextColor  = Colors.black87;
    const labelColor      = Color(0xFFFFF8E1);
    const labelSize       = 18.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: cardBorderColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Sikum',
                    style: GoogleFonts.kronaOne(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Usuario',
                      style: TextStyle(color: labelColor, fontSize: labelSize),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _userController,
                    style: TextStyle(color: inputTextColor),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: fieldFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Contraseña',
                      style: TextStyle(color: labelColor, fontSize: labelSize),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _showText,
                    style: TextStyle(color: inputTextColor),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: fieldFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: _togglePasswordView,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: buttonColor,
                              ),
                            )
                          : Text(
                              'Ingresar',
                              style: TextStyle(
                                color: backgroundColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextButton(
                    onPressed: () => context.go('/forgot'),
                    child: const Text(
                      'Olvidé mi contraseña',
                      style: TextStyle(color: labelColor, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
