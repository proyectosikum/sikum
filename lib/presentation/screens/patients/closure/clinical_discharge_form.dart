import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

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

  String? _feedingOption;
  final _formulaMlController = TextEditingController();
  DateTime? _nextControlDate;
  final _nextControlLocationController = TextEditingController();

  bool _validateCustomFields() {
    if (_feedingOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una opción de alimentación')),
      );
      return false;
    }

    if (_feedingOption == 'leche_formula' &&
        (_formulaMlController.text.isEmpty || int.tryParse(_formulaMlController.text) == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un valor numérico válido para los ml')),
      );
      return false;
    }

    if (_nextControlDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar la fecha del próximo control')),
      );
      return false;
    }

    return true;
  }

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
    };

    try {
      final docRef = FirebaseFirestore.instance.collection('dischargeDataPatient').doc(widget.patientId);
      await docRef.set({
        'closureOfHospitalization': closureData,
        'available': false,
      }, SetOptions(merge: true));

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
        content: const Text('Motivo: Alta clínica'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/pacientes/${patient.id}');
            },
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadEpicrisisPdf(patient);
            },
            child: const Text('Descargar Epicrisis'),
          ),
        ],
      ),
    );
  }

  void _downloadEpicrisisPdf(Patient p) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de descarga aún no implementada en esta pantalla')),
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
                                    RadioListTile<String>(
                                      title: const Text('Pecho a libre demanda'),
                                      value: 'pecho',
                                      groupValue: _feedingOption,
                                      onChanged: (val) => setState(() => _feedingOption = val),
                                    ),
                                    RadioListTile<String>(
                                      title: const Text('Leche de fórmula a libre demanda'),
                                      value: 'leche_formula',
                                      groupValue: _feedingOption,
                                      onChanged: (val) => setState(() => _feedingOption = val),
                                    ),
                                    RadioListTile<String>(
                                      title: const Text('Combinación de ambas'),
                                      value: 'combinado',
                                      groupValue: _feedingOption,
                                      onChanged: (val) => setState(() => _feedingOption = val),
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

                              // Checkboxes
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: cream,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: green, width: 1),
                                ),
                                child: Column(
                                  children: [
                                    CheckboxListTile(
                                      title: const Text('¿Pedir turno oftalmológico?'),
                                      value: _needsOphthalmology,
                                      onChanged: (value) {
                                        setState(() => _needsOphthalmology = value ?? false);
                                      },
                                      activeColor: green,
                                    ),
                                    CheckboxListTile(
                                      title: const Text('¿Pedir turno audiológico?'),
                                      value: _needsAudiology,
                                      onChanged: (value) {
                                        setState(() => _needsAudiology = value ?? false);
                                      },
                                      activeColor: green,
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
                                    InkWell(
                                      onTap: () async {
                                        final selectedDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                          lastDate: DateTime.now().add(const Duration(days: 365)),
                                        );
                                        if (selectedDate != null) {
                                          setState(() => _nextControlDate = selectedDate);
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
                                child: TextFormField(
                                  controller: _nextControlLocationController,
                                  decoration: const InputDecoration(
                                    labelText: '¿Dónde es el próximo control?',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Este campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Botón de guardar
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () {
                                          final isFormValid = _formKey.currentState!.validate();
                                          final areCustomFieldsValid = _validateCustomFields();

                                          if (!isFormValid || !areCustomFieldsValid) {
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
