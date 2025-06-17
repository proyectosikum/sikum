// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SectorTransferForm extends ConsumerStatefulWidget {
  final String patientId;

  const SectorTransferForm({super.key, required this.patientId});

  @override
  ConsumerState<SectorTransferForm> createState() => _SectorTransferFormState();
}


class _SectorTransferFormState extends ConsumerState<SectorTransferForm> {
  final _formKey = GlobalKey<FormState>();
  final _sectorController = TextEditingController();
  final _commentsController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    final closureData = {
      'date': Timestamp.now(),
      'createdBy': uid,
      'reason': 'sector_transfer',
      'sector': _sectorController.text.trim(),
      'comments': _commentsController.text.trim(),
    };

    try {
      final patientActions = ref.read(patientActionsProvider);
      await patientActions.closeHospitalization(widget.patientId, closureData);

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cierre de internación realizado'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/pacientes/${widget.patientId}');
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);

    return Scaffold(
      backgroundColor: cream,
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Título con flecha de atrás
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                        ),
                        const Expanded(
                          child: Text(
                            'Derivación de sector',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Formulario
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Complete los campos requeridos para registrar la derivación del paciente.',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          
                          // Campo de sector
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: cream,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: green, width: 1),
                            ),
                            child: TextFormField(
                              controller: _sectorController,
                              decoration: const InputDecoration(
                                labelText: 'Sector',
                                labelStyle: TextStyle(color: Colors.black87),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Campo de comentarios
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: cream,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: green, width: 1),
                            ),
                            child: TextFormField(
                              controller: _commentsController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Comentarios (opcional)',
                                labelStyle: TextStyle(color: Colors.black87),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Botón de guardar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Guardar cierre',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}