import 'package:firebase_auth/firebase_auth.dart';
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
  final String message;
  
  const _ErrorDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFF8E1),
      title: const Text("Error al registrar al paciente"),
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
        "Ya existe un paciente registrado con el DNI: $dni\n\n"
        "Por favor, verifica el número de documento o consulta "
        "si el paciente ya se encuentra en el sistema.",
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

class AddPatientsScreen extends ConsumerStatefulWidget {
  const AddPatientsScreen({super.key});

  @override
  ConsumerState<AddPatientsScreen> createState() => _AddPatientsScreenState();
}

class _AddPatientsScreenState extends ConsumerState<AddPatientsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String firstName = '';
  String lastName = '';
  String dni = '';
  bool isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  /// Calcula el siguiente número de historia clínica a partir de la lista actual
  Future<int> _getNextMedicalRecordNumber() async {
    // Leemos la lista actual de pacientes (puede estar en loading; asumimos lista vacía)
    final maybePatients = ref.read(patientsStreamProvider).value;
    final patients = maybePatients ?? [];

    final maxNumber = patients
        .map((p) => p.medicalRecordNumber)
        .fold<int>(0, (prev, curr) => curr > prev ? curr : prev);
    return maxNumber + 1;
  }

  /// Verifica si ya existe un paciente con el DNI ingresado
  bool _isDniAlreadyExists(int dniToCheck) {
    final maybePatients = ref.read(patientsStreamProvider).value;
    final patients = maybePatients ?? [];
    
    return patients.any((patient) => patient.dni == dniToCheck);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Verificar si el DNI ya existe antes de proceder
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

    if (_isDniAlreadyExists(dniInt)) {
      showDialog(
        context: context, 
        builder: (_) => _DuplicateDniDialog(dni: dniInt)
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final newNumber = await _getNextMedicalRecordNumber();
      final newPatient = Patient(
        id: '', // Firestore asignará un ID
        firstName: firstName,
        lastName: lastName,
        dni: dniInt,
        medicalRecordNumber: newNumber,
        available: true,
        createdByUserId: '', // No se necesita especificar aca
        createdAt: DateTime.now(),
      );

      // Usamos el provider de acciones para agregar
      // El createdByUserId se asigna automáticamente en el provider
      await ref.read(patientActionsProvider).addPatient(newPatient);

      if (mounted) {
        showDialog(context: context, builder: (_) => _SuccessDialog());
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context, 
          builder: (_) => const _ErrorDialog(
            message: "Se produjo un problema al intentar registrar el alta del paciente.\n"
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
    // Escuchamos el stream de pacientes para tener los datos actualizados
    final patientsAsync = ref.watch(patientsStreamProvider);
    
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
              patientsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Cargando datos de pacientes...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                error: (error, stack) => Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error al cargar pacientes: $error',
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
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F959D),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: (isSubmitting || patientsAsync.isLoading) ? null : _submit,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Agregar'),
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