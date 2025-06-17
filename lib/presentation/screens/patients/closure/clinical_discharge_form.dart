// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:sikum/services/epicrisis_pdf_service.dart';

class ClinicalDischargeForm extends ConsumerStatefulWidget {
  final String patientId;

  const ClinicalDischargeForm({super.key, required this.patientId});

  @override
  ConsumerState<ClinicalDischargeForm> createState() => _ClinicalDischargeFormState();
}

class _ClinicalDischargeFormState extends ConsumerState<ClinicalDischargeForm> {
  final _formKey = GlobalKey<FormState>();
  bool _needsOphthalmology = false;
  bool _needsAudiology = false;
  bool _isSubmitting = false;
  String? _physicalExamination;
  final _physicalExaminationDetailsController = TextEditingController();
  final _weightController = TextEditingController();


  String? _feedingOption;
  final _formulaMlController = TextEditingController();
  DateTime? _nextControlDate;
  final _nextControlLocationController = TextEditingController();


  Future<void> _submitForm(Patient patient) async {
    setState(() => _isSubmitting = true);

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final closureData = {
      'date': Timestamp.now(),
      'createdBy': uid,
      'reason': 'clinical_discharge',
      'feedingOption': _feedingOption,
      'formulaMl': _feedingOption == 'leche_formula' ? int.tryParse(_formulaMlController.text) : null,
      'needsOphthalmology': _needsOphthalmology,
      'needsAudiology': _needsAudiology,
      'nextControlDate': _nextControlDate != null ? Timestamp.fromDate(_nextControlDate!) : null,
      'nextControlLocation': _nextControlLocationController.text.trim(),
      'physicalExamination': _physicalExamination,
      'physicalExaminationDetails': _physicalExamination == 'otros'
          ? _physicalExaminationDetailsController.text.trim()
          : null,
      'weight': int.tryParse(_weightController.text),
    };

    try {
      final patientActions = ref.read(patientActionsProvider);
      await patientActions.closeHospitalization(widget.patientId, closureData);
      _showSuccessDialog(patient);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }


  void _showSuccessDialog(Patient patient) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cierre de internación realizado'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/pacientes');
            },
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              EpicrisisPdfService.downloadEpicrisisPdf(patient);
              context.go('/pacientes');
            },
            child: const Text('Descargar Epicrisis'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);
    final asyncPatient = ref.watch(patientDetailsStreamProvider(widget.patientId));

    return Scaffold(
      backgroundColor: cream,
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: SafeArea(
        child: asyncPatient.when(
          loading: () => const Center(child: CircularProgressIndicator(color: green)),
          error: (_, __) => const Center(child: Text('Error al cargar paciente')),
          data: (patient) {
            if (patient == null) {
              return const Center(child: Text('Paciente no encontrado'));
            }

            return Column(
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
                                'Alta clínica',
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
                                'Datos requeridos para el alta del paciente.',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              // Alimentación
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cream,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: green, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Alimentación al alta', style: TextStyle(fontWeight: FontWeight.bold)),
                                    FormField<String>(
                                      validator: (value) {
                                        if (_feedingOption == null) {
                                          return 'Este campo es obligatorio';
                                        }
                                        return null;
                                      },
                                      builder: (field) {
                                        return InputDecorator(
                                          decoration: InputDecoration(
                                            errorText: field.errorText,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              RadioListTile<String>(
                                                title: const Text('Pecho a libre demanda'),
                                                value: 'pecho',
                                                groupValue: _feedingOption,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _feedingOption = val;
                                                    field.didChange(val);
                                                  });
                                                },
                                              ),
                                              RadioListTile<String>(
                                                title: const Text('Leche de fórmula a libre demanda'),
                                                value: 'leche_formula',
                                                groupValue: _feedingOption,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _feedingOption = val;
                                                    field.didChange(val);
                                                  });
                                                },
                                              ),
                                              RadioListTile<String>(
                                                title: const Text('Combinación de ambas'),
                                                value: 'combinado',
                                                groupValue: _feedingOption,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _feedingOption = val;
                                                    field.didChange(val);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    if (_feedingOption == 'leche_formula')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: TextFormField(
                                          controller: _formulaMlController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: '¿Cuántos ml?',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (_feedingOption == 'leche_formula') {
                                              if (value == null || value.trim().isEmpty) {
                                                return 'Este campo es obligatorio';
                                              }
                                              if (int.tryParse(value) == null) {
                                                return 'Ingrese un número válido';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),

  
                              const SizedBox(height: 16),

                              // Solicitar turnos
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cream,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: green, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Solicitar turnos', style: TextStyle(fontWeight: FontWeight.bold)),
                                    CheckboxListTile(
                                      title: const Text('¿Pedir turno oftalmológico?'),
                                      value: _needsOphthalmology,
                                      onChanged: (value) {
                                        setState(() => _needsOphthalmology = value ?? false);
                                      },
                                      activeColor: green,
                                      controlAffinity: ListTileControlAffinity.trailing,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    CheckboxListTile(
                                      title: const Text('¿Pedir turno audiológico?'),
                                      value: _needsAudiology,
                                      onChanged: (value) {
                                        setState(() => _needsAudiology = value ?? false);
                                      },
                                      activeColor: green,
                                      controlAffinity: ListTileControlAffinity.trailing,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Fecha del próximo control
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cream,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: green, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('¿Cuándo es el próximo control?', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    FormField<DateTime>(
                                      validator: (value) {
                                        if (_nextControlDate == null) {
                                          return 'Este campo es obligatorio';
                                        }
                                        return null;
                                      },
                                      builder: (field) => InputDecorator(
                                        decoration: InputDecoration(
                                          errorText: field.errorText,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            final selectedDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                              lastDate: DateTime.now().add(const Duration(days: 365)),
                                            );
                                            if (selectedDate != null) {
                                              setState(() {
                                                _nextControlDate = selectedDate;
                                                field.didChange(selectedDate);
                                              });
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'Seleccionar fecha',
                                            ),
                                            child: Text(
                                              _nextControlDate != null
                                                  ? '${_nextControlDate!.day}/${_nextControlDate!.month}/${_nextControlDate!.year}'
                                                  : 'dd/mm/aaaa',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),


                              const SizedBox(height: 16),

                              // Lugar del próximo control
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cream,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: green, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('¿Dónde es el próximo control?', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _nextControlLocationController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Este campo es obligatorio';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
  
                              const SizedBox(height: 24),

                              // Examen físico al alta
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cream,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: green, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Examen físico al alta', style: TextStyle(fontWeight: FontWeight.bold)),
                                    FormField<String>(
                                      validator: (value) {
                                        if (_physicalExamination == null) {
                                          return 'Este campo es obligatorio';
                                        }
                                        return null;
                                      },
                                      builder: (field) => InputDecorator(
                                        decoration: InputDecoration(
                                          errorText: field.errorText,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            RadioListTile<String>(
                                              title: const Text('Normal'),
                                              value: 'normal',
                                              groupValue: _physicalExamination,
                                              onChanged: (val) {
                                                setState(() {
                                                  _physicalExamination = val;
                                                  field.didChange(val);
                                                });
                                              },
                                            ),
                                            RadioListTile<String>(
                                              title: const Text('Otros'),
                                              value: 'otros',
                                              groupValue: _physicalExamination,
                                              onChanged: (val) {
                                                setState(() {
                                                  _physicalExamination = val;
                                                  field.didChange(val);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (_physicalExamination == 'otros')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: TextFormField(
                                          controller: _physicalExaminationDetailsController,
                                          decoration: const InputDecoration(
                                            hintText: 'Detalles del examen físico',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (_physicalExamination == 'otros' &&
                                                (value == null || value.trim().isEmpty)) {
                                              return 'Debe completar este campo';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),


                              const SizedBox(height: 16),

                              // Peso al alta
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cream,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: green, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Peso al alta (g)', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _weightController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Este campo es obligatorio';
                                        }
                                        final intValue = int.tryParse(value);
                                        if (intValue == null || intValue < 1900 || intValue > 6000) {
                                          return 'Debe ser un número entre 1900 y 6000';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Botón de guardar
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () {
                                          final isFormValid = _formKey.currentState!.validate();

                                          if (!isFormValid) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Por favor, chequee los errores en los campos indicados'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          _submitForm(patient);
                                        },
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
            );
          },
        ),
      ),
    );
  }
}
