// lib/presentation/screens/create_users.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:sikum/presentation/providers/user_provider.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

class CreateUsers extends ConsumerStatefulWidget {
  const CreateUsers({super.key});

  @override
  ConsumerState<CreateUsers> createState() => _CreateUsersState();
}

class _CreateUsersState extends ConsumerState<CreateUsers> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provRegController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  String? _selectedSpecialty;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _provRegController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    final adminEmail = fb_auth.FirebaseAuth.instance.currentUser?.email;
    if (_selectedSpecialty == null || adminEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos obligatorios')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(userActionsProvider).createUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dni: _dniController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        provReg: _provRegController.text.trim(),
        specialty: _selectedSpecialty!,
        role: 'user',
        adminEmail: adminEmail,
        adminPassword: _adminPasswordController.text.trim(),
      );
      if (!mounted) return;
      context.go('/usuarios');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear usuario: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4F959D);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Center(
                child: Text(
                  'Nuevo Usuario',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Nombre:'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido:'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese un apellido' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _dniController,
                decoration: const InputDecoration(labelText: 'DNI:'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v == null || v.isEmpty ? 'Ingrese el DNI' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email:'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese un email' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono:'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _provRegController,
                decoration: const InputDecoration(labelText: 'Matrícula Provincial:'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Especialidad:'),
                value: _selectedSpecialty,
                items: const [
                  DropdownMenuItem(value: 'Neonatología', child: Text('Neonatología')),
                  DropdownMenuItem(value: 'Enfermería', child: Text('Enfermería')),
                  DropdownMenuItem(value: 'Fonoaudiología', child: Text('Fonoaudiología')),
                  DropdownMenuItem(value: 'Interconsultor', child: Text('Interconsultor')),
                ],
                onChanged: (v) => setState(() => _selectedSpecialty = v),
                validator: (v) => v == null ? 'Selecciona una especialidad' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _adminPasswordController,
                decoration: const InputDecoration(labelText: 'Ingrese su contraseña para confirmar:'),
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Requiere contraseña' : null,
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isLoading ? null : _createUser,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Crear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
