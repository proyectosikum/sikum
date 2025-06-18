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
      title: const Text("Paciente actualizado con éxito ✅"),
      content: const Text("Los datos del paciente han sido actualizados correctamente."),
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
  final String message;

  const _ErrorDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFF8E1),
      title: const Text("Error al actualizar paciente"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}

class _DuplicateDniDialog extends StatelessWidget {
  final int dni;

  const _DuplicateDniDialog({required this.dni});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFF8E1),
      title: const Text("DNI ya registrado ⚠️"),
      content: Text(
        "Ya existe otro paciente registrado con el DNI: $dni\n\n"
        "Por favor, verifica el número de documento o consulta "
        "si existe duplicación en el sistema.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}

class EditPatientScreen extends ConsumerStatefulWidget {
  final String patientId;

  const EditPatientScreen({
    super.key,
    required this.patientId,
  });

  @override
  ConsumerState<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends ConsumerState<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dniController = TextEditingController();
  
  String firstName = '';
  String lastName = '';
  String dni = '';
  bool isSubmitting = false;
  bool isInitialized = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  /// Inicializa los controladores con los datos del paciente
  void _initializeForm(Patient patient) {
    if (!isInitialized) {
      _firstNameController.text = patient.firstName;
      _lastNameController.text = patient.lastName;
      _dniController.text = patient.dni.toString();
      firstName = patient.firstName;
      lastName = patient.lastName;
      dni = patient.dni.toString();
      isInitialized = true;
    }
  }

  /// Verifica si ya existe otro paciente con el DNI ingresado
  bool _isDniAlreadyExists(int dniToCheck, String currentPatientId) {
    final maybePatients = ref.read(patientsStreamProvider).value;
    final patients = maybePatients ?? [];

    return patients.any((patient) => 
        patient.dni == dniToCheck && patient.id != currentPatientId);
  }

  /// Capitaliza la primera letra de cada palabra
  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Future<void> _submit(Patient originalPatient) async {
    if (!_formKey.currentState!.validate()) return;

    // Verificar si el DNI ya existe (excluyendo el paciente actual)
    final dniInt = int.tryParse(dni);
    if (dniInt == null) {
      showDialog(
        context: context,
        builder: (_) => const _ErrorDialog(
          message: "El DNI debe ser un número válido."
        )
      );
      return;
    }

    if (_isDniAlreadyExists(dniInt, widget.patientId)) {
      showDialog(
        context: context,
        builder: (_) => _DuplicateDniDialog(dni: dniInt)
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Crear el paciente actualizado manteniendo los campos inmutables
      final updatedPatient = Patient(
        id: originalPatient.id,
        firstName: firstName,
        lastName: lastName,
        dni: dniInt,
        medicalRecordNumber: originalPatient.medicalRecordNumber, // No se modifica
        available: originalPatient.available,
        createdByUserId: originalPatient.createdByUserId,
        createdAt: originalPatient.createdAt,
      );

      // Usar el provider para actualizar
      await ref.read(patientActionsProvider).updatePatient(updatedPatient);

      if (mounted) {
        showDialog(context: context, builder: (_) => _SuccessDialog());
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const _ErrorDialog(
            message: "Se produjo un problema al intentar actualizar el paciente.\n"
                    "Por favor, verifica la conexión o los datos ingresados.\n"
                    "Si el problema persiste, contacta al soporte técnico."
          )
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  /// Validador personalizado para el campo DNI
  String? _validateDni(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese el DNI';
    }

    final dniInt = int.tryParse(value);
    if (dniInt == null) {
      return 'El DNI debe ser un número válido';
    }

    if (value.length < 7 || value.length > 8) {
      return 'El DNI debe tener entre 7 y 8 dígitos';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Obtener los datos del paciente específico
    final patientAsync = ref.watch(patientDetailsStreamProvider(widget.patientId));
    final patientsListAsync = ref.watch(patientsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: patientAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error al cargar el paciente',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
        data: (patient) {
          if (patient == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Paciente no encontrado',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          // Inicializar el formulario con los datos del paciente
          _initializeForm(patient);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Text(
                          'Editar paciente',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Para balancear el IconButton
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  /*const SizedBox(height: 20),*/

                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'Nombre:'),
                    onChanged: (value) {
                      final capitalizedValue = _capitalizeWords(value);
                      if (capitalizedValue != value) {
                        _firstNameController.value = TextEditingValue(
                          text: capitalizedValue,
                          selection: TextSelection.collapsed(offset: capitalizedValue.length),
                        );
                      }
                      firstName = capitalizedValue;
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese un nombre' : null,
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Apellido:'),
                    onChanged: (value) {
                      final capitalizedValue = _capitalizeWords(value);
                      if (capitalizedValue != value) {
                        _lastNameController.value = TextEditingValue(
                          text: capitalizedValue,
                          selection: TextSelection.collapsed(offset: capitalizedValue.length),
                        );
                      }
                      lastName = capitalizedValue;
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese un apellido' : null,
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _dniController,
                    decoration: const InputDecoration(
                      labelText: 'DNI Provisorio:',
                      helperText: 'Debe tener entre 7 y 8 dígitos',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => dni = value,
                    validator: _validateDni,
                  ),
                  const SizedBox(height: 30),

                  // Mostrar información de carga si los datos están cargando
                  patientsListAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Validando datos...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    error: (error, stack) => Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Error al validar datos: $error',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    data: (patients) => Container(), // No mostrar nada cuando los datos están cargados
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4F959D), // Color del texto
                          side: const BorderSide(color: Color(0xFF4F959D)), // Borde del botón
                        ),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F959D),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: (isSubmitting || patientsListAsync.isLoading) 
                            ? null 
                            : () => _submit(patient),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}