import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/core/theme/app_colors.dart';
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
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSpecialty == null) {
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
        role: 'user'
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario creado exitosamente'),
            duration: Duration(seconds: 2),
          ),
        );

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
                decoration: const InputDecoration(
                  labelText: 'Nombre:',
                  labelStyle: TextStyle(color: AppColors.green),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido:',
                  labelStyle: TextStyle(color: AppColors.green),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese un apellido' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _dniController,
                decoration: const InputDecoration(
                  labelText: 'DNI:',
                  labelStyle: TextStyle(color: AppColors.green),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v == null || v.isEmpty ? 'Ingrese el DNI' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email:',
                  labelStyle: TextStyle(color: AppColors.green),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese un email' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono:',
                  labelStyle: TextStyle(color: AppColors.green),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _provRegController,
                decoration: const InputDecoration(
                  labelText: 'Matrícula Provincial:',
                  labelStyle: TextStyle(color: AppColors.green),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v == null || v.isEmpty ? 'Ingrese la matrícula provincial' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Especialidad:',
                  labelStyle: TextStyle(color: AppColors.green),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                value: _selectedSpecialty,
                items: const [
                  DropdownMenuItem(value: 'Neonatología', child: Text('Neonatología')),
                  DropdownMenuItem(value: 'Enfermería', child: Text('Enfermería')),
                  DropdownMenuItem(value: 'Fonoaudiología', child: Text('Fonoaudiología')),
                  DropdownMenuItem(value: 'Interconsultor', child: Text('Interconsultor')),
                  DropdownMenuItem(value: 'Puericultura', child: Text('Puericultura')),
                  DropdownMenuItem(value: 'Servicio Social', child: Text('Servicio Social')),
                  DropdownMenuItem(value: 'Vacunatorio', child: Text('Vacunatorio')),
                ],
                onChanged: (v) => setState(() => _selectedSpecialty = v),
                validator: (v) => v == null ? 'Selecciona una especialidad' : null,
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.green)
                      ),
                    
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
