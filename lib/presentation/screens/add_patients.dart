import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

class _SuccessDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFF8E1),
      title: const Text("Alta registrada con éxito ✅"),
      content: const Text("El paciente ha sido dado de alta correctamente."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}

class _ErrorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFF8E1),
      title: const Text("Error al registrar al paciente"),
      content: const Text(
        "Se produjo un problema al intentar registrar el alta del paciente.\n"
        "Por favor, verifica la conexión o los datos ingresados.\n"
        "Si el problema persiste, contacta al soporte técnico.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}

class AddPatientsScreen extends ConsumerStatefulWidget {
  const AddPatientsScreen({super.key});

  @override
  ConsumerState<AddPatientsScreen> createState() => _AddPatientsScreenState();
}

class _AddPatientsScreenState extends ConsumerState<AddPatientsScreen> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String dni = '';
  bool isSubmitting = false;

Future<int> _getNextMedicalRecordNumber() async {
  await ref.read(patientProvider.notifier).getAllPatients(); 
  final patients = ref.read(patientProvider); 
  final maxNumber = patients.map((p) => p.medicalRecordNumber).fold<int>(
    0,
    (prev, curr) => curr > prev ? curr : prev,
  );
  return maxNumber + 1;
}

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      final newNumber = await _getNextMedicalRecordNumber();
      final newPatient = Patient(
        id: '',
        firstName: firstName,
        lastName: lastName,
        dni: int.parse(dni),
        medicalRecordNumber: newNumber,
        available: true,
        createdByUserId: 'EJEMPLO',
        createdAt: DateTime.now(),
      );

      await ref.read(patientProvider.notifier).addPatient(newPatient);

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => _SuccessDialog(),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => _ErrorDialog(),
        );
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Nuevo paciente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre:'),
                onChanged: (value) => firstName = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Apellido:'),
                onChanged: (value) => lastName = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un apellido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'DNI Provisorio:'),
                keyboardType: TextInputType.number,
                onChanged: (value) => dni = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese el DNI' : null,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F959D),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isSubmitting ? null : _submit,
                    child: const Text('Agregar'),
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
