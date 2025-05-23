// lib/presentation/screens/create_users.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:sikum/core/theme/app_colors.dart';
import 'package:sikum/presentation/providers/user_provider.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/labeled_text_field.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

class CreateUsers extends ConsumerStatefulWidget {
  const CreateUsers({super.key});

  @override
  ConsumerState<CreateUsers> createState() => _CreateUsersState();
}

class _CreateUsersState extends ConsumerState<CreateUsers> {
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
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final dni = _dniController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final provReg = _provRegController.text.trim();
    final specialty = _selectedSpecialty;
    final adminPassword = _adminPasswordController.text.trim();

    // Email del admin actual
    final adminEmail = fb_auth.FirebaseAuth.instance.currentUser?.email;

    if (firstName.isEmpty ||
        lastName.isEmpty  ||
        dni.isEmpty       ||
        email.isEmpty     ||
        specialty == null ||
        adminPassword.isEmpty ||
        adminEmail == null
    ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá todos los campos obligatorios')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(userActionsProvider).createUser(
        firstName: firstName,
        lastName: lastName,
        dni: dni,
        email: email,
        phone: phone,
        provReg: provReg,
        specialty: specialty,
        role: 'user',
        adminEmail: adminEmail,
        adminPassword: adminPassword,
      );

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/usuarios');
        });
      }
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
    return Scaffold(
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Nuevo Usuario',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                LabeledTextField(label: 'Nombre', controller: _firstNameController),
                LabeledTextField(label: 'Apellido', controller: _lastNameController),
                LabeledTextField(
                  label: 'DNI',
                  controller: _dniController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                LabeledTextField(label: 'Email', controller: _emailController),
                LabeledTextField(
                  label: 'Teléfono',
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                LabeledTextField(label: 'Matrícula Provincial', controller: _provRegController),

                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Especialidad',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Neonatología', child: Text('Neonatología')),
                    DropdownMenuItem(value: 'Enfermería', child: Text('Enfermería')),
                    DropdownMenuItem(value: 'Fonoaudiología', child: Text('Fonoaudiología')),
                    DropdownMenuItem(value: 'Interconsultor', child: Text('Interconsultor')),
                  ],
                  onChanged: (value) => setState(() => _selectedSpecialty = value),
                ),

                // Campo de contraseña de admin
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Ingresá tu contraseña para confirmar',
                  controller: _adminPasswordController,
                  obscureText: true,
                ),

                const SizedBox(height: 20),
                _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _createUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F959D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Crear'),
                      ),
                    ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: Colors.black),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Cancelar'),
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
