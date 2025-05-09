import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/core/theme/app_colors.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/labeled_text_field.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

class CreateUsers extends StatelessWidget{

  const CreateUsers({  super.key  });

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

            const LabeledTextField(label: 'Nombre Completo'),
            const LabeledTextField(label: 'DNI'),
            const LabeledTextField(label: 'Email'),
            const LabeledTextField(label: 'Teléfono'),
            const LabeledTextField(label: 'Matrícula Provincial'),

            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 4),
              child: Text(
                'Especialidad',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            DropdownButtonFormField<String>(
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
                // lógica al seleccionar
              },
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Lógica crear
              },
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
              onPressed: () => { context.pop() },
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