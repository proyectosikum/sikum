import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showText = true;
  bool _loading = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordView() => setState(() => _showText = !_showText);

  Future<void> _onLogin() async {
    final messenger = ScaffoldMessenger.of(context);
    final usuario = _usuarioController.text.trim();
    final pass = _passwordController.text;

    if (usuario.isEmpty || pass.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Por favor completa ambos campos')),
      );
      return;
    }

    setState(() => _loading = true);
    final result = await AuthService.instance.login(usuario, pass);
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña inválidos')),
      );
      return;
    }

    if (result.needsChange) {
      context.push('/change');
      return;
    }

    if (result.role == 'admin') {
      context.go('/homeAdmin');
    } else {
      context.go('/home');
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

                  // Título
                  Text(
                    'Sikum',
                    style: GoogleFonts.kronaOne(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Campo Usuario
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Usuario',
                      style: TextStyle(
                        color: labelColor,
                        fontSize: labelSize,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usuarioController,
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

                  // Campo Contraseña
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Contraseña',
                      style: TextStyle(
                        color: labelColor,
                        fontSize: labelSize,
                      ),
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
                          _showText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: _togglePasswordView,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Botón Ingresar
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
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(buttonColor),
                              ),
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

                  // Link Olvidé mi contraseña
                  TextButton(
                    onPressed: () => context.push('/forgot'),
                    child: const Text(
                      'Olvidé mi contraseña',
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 14
                      ),
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
