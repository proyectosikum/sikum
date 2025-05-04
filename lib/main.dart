import 'package:flutter/material.dart';
import 'package:sikum/features/presentation/screens/crear_usuarios_screens.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CrearUsuariosScreens(),
    );
  }
}
