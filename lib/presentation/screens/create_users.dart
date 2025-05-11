import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _nameController = TextEditingController();
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provRegController = TextEditingController();
  String? _selectedSpecialty;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _provRegController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    final name = _nameController.text.trim();
    final dni = _dniController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final provReg = _provRegController.text.trim();
    final specialty = _selectedSpecialty;

    if (name.isEmpty || dni.isEmpty || email.isEmpty || specialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá todos los campos obligatorios')),
      );
      return;
    }

    setState(() => _isLoading = true);

try {
  await ref.read(usersProvider.notifier).addUser(
        name: name,
        surname: '',
        dni: dni,
        email: email,
        phone: phone,
        provReg: provReg,
        specialty: specialty,
        role: 'usuario',
      );

  if (mounted) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/confirmacion');
    });
  }

} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al crear usuario: $e')),
    );
  }
} finally {
  if (mounted) {
    setState(() => _isLoading = false);
  }
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Nuevo Usuario',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            LabeledTextField(label: 'Nombre Completo', controller: _nameController),
            LabeledTextField(label: 'DNI', controller: _dniController),
            LabeledTextField(label: 'Email', controller: _emailController),
            LabeledTextField(label: 'Teléfono', controller: _phoneController),
            LabeledTextField(label: 'Matrícula Provincial', controller: _provRegController),

            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 4),
              child: Text(
                'Especialidad',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedSpecialty,
              decoration: const InputDecoration(
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
              onChanged: (value) {
                setState(() {
                  _selectedSpecialty = value;
                });
              },
            ),

            const SizedBox(height: 40),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _createUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F959D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Crear'),
                  ),

            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
