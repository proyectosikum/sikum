import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/presentation/providers/user_provider.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

class EditUser extends ConsumerStatefulWidget {
  final String userId;

  const EditUser({required this.userId, super.key});

  @override
  ConsumerState<EditUser> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUser> {
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
  void initState() {
    super.initState();
    _loadUserData();
  }

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

  Future<void> _loadUserData() async {
    try {
      final user = await ref.read(userActionsProvider).getUserById(widget.userId);
      setState(() {
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _dniController.text = user.dni;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _provRegController.text = user.provReg;
        _selectedSpecialty = user.specialty;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el usuario: $e')),
        );
      }
    }
  }

  Future<bool> _isDniOrEmailDuplicated(String dni, String email) async {
  final allUsers = await ref.read(userActionsProvider).getAllUsers();
  return allUsers.any((user) =>
    user.id != widget.userId &&
    (user.dni == dni || user.email.toLowerCase() == email.toLowerCase()));
  }


  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    final dni = _dniController.text.trim();
    final email = _emailController.text.trim();

    final duplicated = await _isDniOrEmailDuplicated(dni, email);
    if (duplicated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El DNI o el email ya están en uso por otro usuario.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(userActionsProvider).updateUser(
        id: widget.userId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dni: dni,
        email: email,
        phone: _phoneController.text.trim(),
        provReg: _provRegController.text.trim(),
        specialty: _selectedSpecialty!,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFFFFF8E1),
          title: const Text("Usuario actualizado con éxito ✅"),
          content: const Text("Los datos del usuario se han actualizado correctamente."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/usuarios');
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el usuario: $e')),
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
                  'Editar Usuario',
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
                  DropdownMenuItem(value: 'Interconsultor', child: Text('Puericultura')),
                  DropdownMenuItem(value: 'Interconsultor', child: Text('Servicio Social')),
                  DropdownMenuItem(value: 'Vacunatorio', child: Text('Vacunatorio'))
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialty = value;
                  });
                },
                validator: (value) => value == null ? 'Selecciona una especialidad' : null,
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
                    onPressed: _isLoading ? null : _updateUser,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Aceptar'),
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