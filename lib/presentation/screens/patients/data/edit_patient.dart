import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/core/theme/app_colors.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';

class EditPatient extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const EditPatient({
    Key? key,
    required this.patientId,
    required this.patientData,
  }) : super(key: key);

  @override
  State<EditPatient> createState() => _EditPatientState();
}

class _EditPatientState extends State<EditPatient> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController dniController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.patientData['firstName']);
    lastNameController = TextEditingController(text: widget.patientData['lastName']);
    dniController = TextEditingController(text: widget.patientData['dni'].toString());
  }

  Future<void> _guardarCambios(BuildContext context) async {
  final updatedData = {
    'firstName': firstNameController.text.trim(),
    'lastName': lastNameController.text.trim(),
    'dni': int.tryParse(dniController.text.trim()) ?? 0,
    'modifiedAt': DateTime.now(),
  };

  try {
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .update(updatedData);

    if (context.mounted) {
      context.pop();
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar los cambios: $e')),
      );
    }
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.cream,
    appBar: CustomAppBar(),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: firstNameController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: lastNameController,
            decoration: const InputDecoration(labelText: 'Apellido'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: dniController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'DNI provisorio'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _guardarCambios(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Guardar'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    ),
  );
}
}