import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/evolution_provider.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/providers/user_provider.dart';
import 'package:sikum/presentation/screens/patients/evolutions/evolution_fields_config.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:sikum/utils/string_utils.dart';

class EvolutionDetailsScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String evolutionId;

  const EvolutionDetailsScreen({
    super.key,
    required this.patientId,
    required this.evolutionId,
  });

  @override
  ConsumerState<EvolutionDetailsScreen> createState() => _EvolutionDetailsScreenState();
}

class _EvolutionDetailsScreenState extends ConsumerState<EvolutionDetailsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool isEditing = false;
  int _page = 0; // Para neonatología, controla página 0 o 1
  final Map<String, dynamic> _formData = {};
  String? _currentSpecialty;
  final Map<String, String?> _validationErrors = {};

  /// Valida todos los campos con isRequired==true según la especialidad actual,
  /// y además comprueba los rangos en los campos de tipo número.
  bool _validateForm() {
    _validationErrors.clear();
    final spec = _currentSpecialty!;
    final fields = spec == 'neonatologia'
        ? [...neonatologyPage1, ...neonatologyPage2]
        : (evolutionFormConfig[spec] ?? []);
    bool isValid = true;

    for (final f in fields) {
      final val = _formData[f.key];

      // 1) Chequeo de obligatoriedad
      bool empty = false;
      switch (f.type) {
        case FieldType.text:
        case FieldType.multiline:
          empty = val == null || (val as String).trim().isEmpty;
          break;
        case FieldType.number:
          empty = val == null;
          break;
        case FieldType.datetime:
        case FieldType.radio:
          empty = val == null;
          break;
        case FieldType.checkbox:
          empty = false;
          break;
      }
      if (f.isRequired && empty) {
        _validationErrors[f.key] = 'Este campo es obligatorio';
        isValid = false;
        // no `continue` aquí, queremos también chequear rango si pasa la obligación
      }

      if (f.type == FieldType.number) {
        num? numVal;
        if (val is num) {
          numVal = val;
        } else if (val is String) {
          numVal = num.tryParse(val);
        }
        if (numVal != null) {
          if (f.min != null && numVal < f.min!) {
            _validationErrors[f.key] = 'Debe estar entre ${f.min} y ${f.max ?? ''}';
            isValid = false;
          }
          if (f.max != null && numVal > f.max!) {
            _validationErrors[f.key] = 'Debe estar entre ${f.min ?? ''} y ${f.max}';
            isValid = false;
          }
        }
      }
    }

    setState(() {}); // para refrescar los errores en pantalla
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final patientAsync = ref.watch(patientDetailsStreamProvider(widget.patientId));
    final evolutionAsync = ref.watch(evolutionDetailsProvider(widget.evolutionId));
    const green = Color(0xFF4F959D);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: patientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: green)),
        error: (_, __) => const Center(child: Text('Error al cargar paciente')),
        data: (patient) {
          if (patient == null) {
            return const Center(child: Text('Paciente no encontrado'));
          }

          return evolutionAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: green)),
            error: (_, __) => const Center(child: Text('Error al cargar evolución')),
            data: (evolution) {
              if (evolution == null) {
                return const Center(child: Text('Evolución no encontrada'));
              }
              return _buildContent(context, patient, evolution);
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Patient patient, Map<String, dynamic> evolution) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);
    const black = Colors.black87;

    final String specialty = evolution['specialty'] as String;
    _currentSpecialty ??= specialty;
    final Map<String, dynamic> details = evolution['details'] as Map<String, dynamic>;
    final dynamic createdAt = evolution['createdAt'];
    final String createdByUserId = evolution['createdByUserId'] as String;

    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    DateTime? createdDateTime;
    if (createdAt is Timestamp) {
      createdDateTime = createdAt.toDate();
    } else if (createdAt is DateTime) {
      createdDateTime = createdAt;
    } else {
      try {
        createdDateTime = DateTime.parse(createdAt.toString());
      } catch (_) {
        createdDateTime = null;
      }
    }

    bool withinOneHour = false;
    if (createdDateTime != null) {
      final DateTime limite = createdDateTime.add(const Duration(hours: 1));
      withinOneHour = DateTime.now().isBefore(limite);
    }

    final bool canEdit = (currentUserId != null)
        && (currentUserId == createdByUserId)
        && withinOneHour
        && specialty != 'enfermeria_cambio_pulsera';

    if (_formData.isEmpty) {
      details.forEach((key, value) {
        _formData[key] = value is Timestamp ? value.toDate() : value;
      });
    }

    final List<FieldConfig> fields = specialty == 'neonatologia'
        ? [...neonatologyPage1, ...neonatologyPage2]
        : evolutionFormConfig[specialty] ?? [];

    final bool isNeonato = specialty == 'neonatologia';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Detalle de Evolución',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                if (canEdit || isEditing) ...[
                  IconButton(
                    icon: Icon(isEditing ? Icons.save : Icons.edit),
                    onPressed: isEditing ? _saveChanges : _toggleEdit,
                  ),
                ] else
                  const SizedBox(width: 48),
              ],
            ),
          ),

          // Datos del paciente
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: green),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${patient.lastName}, ${patient.firstName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'DNI: ${patient.dni}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Detalles de evolución
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: green),
                ),
                child: Column(
                  children: [
                    _buildProfessionalInfo(createdByUserId, specialty, createdAt),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: isEditing && isNeonato
                              ? (_page == 0 ? _buildNeonatoPage1() : _buildNeonatoPage2())
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (specialty == 'enfermeria_cambio_pulsera') ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Número de pulsera anterior',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              details['braceletNumberOld']?.toString() ?? 'No especificado',
                                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                                            ),                                          
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],

                                    // Resto de los campos (por si en el futuro se agregan más a esta especialidad)
                                    for (final field in fields) ...[
                                      _buildFieldWidget(field, details),
                                      const SizedBox(height: 16),
                                    ],
                                  ],
                                ),
                        ),

                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botones de acción
          if (isEditing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (isNeonato && _page == 1) {
                          setState(() => _page = 0);
                        } else {
                          _cancelEdit();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: green,
                        side: const BorderSide(color: green),
                      ),
                      child: Text(isNeonato && _page == 1 ? 'Atrás' : 'Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: cream,
                        side: const BorderSide(color: green),
                      ),
                      onPressed: () {
                        if (isNeonato && _page == 0) {
                          setState(() => _page = 1);
                        } else {
                          _saveChanges();
                        }
                      },
                      child: Text(isNeonato && _page == 0 ? 'Siguiente' : 'Guardar'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }


  ///
  /// Construye la sección fija con la información del profesional que creó la evolución.
  ///
  Widget _buildProfessionalInfo(String createdByUserId, String specialty, dynamic createdAt) {
    // Si el userId está vacío, mostramos un error
    if (createdByUserId.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF4F959D), width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profesional: ID de usuario vacío',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            Text(
              'Especialidad: ${getSpecialtyDisplayName(specialty)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (createdAt != null)
              Text(
                'Fecha: ${_formatDate(createdAt)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      );
    }

    // Obtenemos los datos del usuario-profesional mediante el provider correspondiente
    final userAsync = ref.watch(userByIdStreamProvider(createdByUserId));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF4F959D), width: 1),
        ),
      ),
      child: userAsync.when(
        loading: () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cargando información del profesional...'),
            Text(
              'Especialidad: ${getSpecialtyDisplayName(specialty)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (createdAt != null)
              Text(
                'Fecha: ${_formatDate(createdAt)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        error: (error, stackTrace) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profesional: Error - ${error.toString()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              Text(
                'UserID: $createdByUserId',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Especialidad: ${getSpecialtyDisplayName(specialty)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              if (createdAt != null)
                Text(
                  'Fecha: ${_formatDate(createdAt)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
            ],
          );
        },
        data: (user) {
          final professionalName = user != null
              ? '${user.lastName}, ${user.firstName}'
              : 'Profesional no encontrado';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 14),
                  children: [
                    const TextSpan(
                      text: 'Profesional: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: professionalName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 14),
                  children: [
                    const TextSpan(
                      text: 'Especialidad: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: getSpecialtyDisplayName(specialty),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              if (createdAt != null)
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 14),
                    children: [
                      const TextSpan(
                        text: 'Fecha: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '${_formatDate(createdAt)} hs.',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // MÉTODOS PARA NEONATOLOGÍA (Página 1 y Página 2) Igual que tu código
  Widget _buildNeonatoPage1() {
    final examValue = _formData['physicalExam'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Examen físico', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(spacing: 16, children: ['Normal', 'Anormal'].map((opt) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<String>(
                value: opt,
                groupValue: examValue,
                onChanged: (v) => setState(() => _formData['physicalExam'] = v),
              ),
              Text(opt),
            ],
          );
        }).toList()),
        if (examValue == 'Anormal') ...[
          const SizedBox(height: 12),
          _buildEditableField(neonatologyPage1.firstWhere((f) => f.key == 'abnormalObservation'), _formData['abnormalObservation']),
        ],
        const SizedBox(height: 16),
        for (final f in neonatologyPage1.where((f) => f.key != 'physicalExam' && f.key != 'abnormalObservation')) ...[
          _buildEditableField(f, _formData[f.key]),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildNeonatoPage2() {
    const titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Indicaciones', style: titleStyle),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('PMLD'),
          value: _formData['pmld'] as bool? ?? false,
          onChanged: (v) => setState(() => _formData['pmld'] = v ?? false)
        ),
        CheckboxListTile(
          title: const Text('CSV por turno'),
          value: _formData['csvByShift'] as bool? ?? false,
          onChanged: (v) => setState(() => _formData['csvByShift'] = v ?? false)
        ),
        const SizedBox(height: 16),
        Text('Alimentación', style: titleStyle),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('PMLD'),
          value: _formData['feedingPmld'] as bool? ?? false,
          onChanged: (v) => setState(() => _formData['feedingPmld'] = v ?? false)
        ),
        CheckboxListTile(
          title: const Text('PMLD + complemento'),
          value: _formData['feedingPmldComplement'] as bool? ?? false,
          onChanged: (v) => setState(() => _formData['feedingPmldComplement'] = v ?? false)
        ),
        if (_formData['feedingPmldComplement'] as bool? ?? false) ...[
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 8),
            child: _buildEditableField(
              neonatologyPage2.firstWhere((f) => f.key == 'feedingMlQuantity'),
              _formData['feedingMlQuantity']
            )
          ),
        ],
        CheckboxListTile(
          title: const Text('LF'),
          value: _formData['lf'] as bool? ?? false,
          onChanged: (v) => setState(() => _formData['lf'] = v ?? false)
        ),
        if (_formData['lf'] as bool? ?? false) ...[
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 8),
            child: _buildEditableField(
              neonatologyPage2.firstWhere((f) => f.key == 'lfMlQuantity'),
              _formData['lfMlQuantity']
            )
          ),
        ],
        const SizedBox(height: 16),
        _buildEditableField(neonatologyPage2.firstWhere((f) => f.key == 'phototherapy'), _formData['phototherapy']),
        const SizedBox(height: 16),
        _buildEditableField(neonatologyPage2.firstWhere((f) => f.key == 'medication'), _formData['medication']),
        const SizedBox(height: 16),
        _buildEditableField(neonatologyPage2.firstWhere((f) => f.key == 'observations'), _formData['observations']),
      ],
    );
  }

  // Dado un FieldConfig y el valor actual (details[field.key]), decide si dibuja _buildEditableField o _buildReadOnlyField
  Widget _buildFieldWidget(FieldConfig field, Map<String, dynamic> details) {
    final value = details[field.key];

    if (isEditing) {
      return _buildEditableField(field, value);
    } else {
      return _buildReadOnlyField(field, value);
    }
  }

  Widget _buildReadOnlyField(FieldConfig field, dynamic value) {
    String displayValue = '';

    switch (field.type) {
      case FieldType.text:
      case FieldType.number:
      case FieldType.multiline:
        displayValue = value?.toString() ?? '';
        break;
      case FieldType.checkbox:
        displayValue = (value == true) ? 'Sí' : 'No';
        break;
      case FieldType.radio:
        displayValue = value?.toString() ?? 'No seleccionado';
        break;
      case FieldType.datetime:
        if (value != null) {
          // Convertir a DateTime
          DateTime date;
          if (value is DateTime) {
            date = value;
          } else if (value is Timestamp) {
            date = value.toDate();
          } else {
            try {
              date = DateTime.parse(value.toString());
            } catch (_) {
              date = DateTime.now();
            }
          }
          // Formatear solo fecha
          displayValue = DateFormat('dd/MM/yyyy').format(date);
        } else {
          displayValue = 'No especificado';
        }
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue.isEmpty ? 'No especificado' : displayValue,
            style: TextStyle(
              fontSize: 16,
              color: displayValue.isEmpty ? Colors.grey : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(FieldConfig field, dynamic value) {
    switch (field.type) {
      case FieldType.text:
        return TextFormField(
          initialValue: value?.toString() ?? '',
          onChanged: (v) => _formData[field.key] = v,
          decoration: InputDecoration(
            labelText: field.label,
            errorText: _validationErrors[field.key],
            border: const OutlineInputBorder(),
          ),
        );

      case FieldType.number:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controllers[field.key] ??= TextEditingController(text: value?.toString() ?? ''),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) {
                if (v.trim().isEmpty) {
                  _formData[field.key] = null;
                  if (field.isRequired) {
                    _validationErrors[field.key] = 'Este campo es obligatorio';
                  }
                } else {
                  final parsed = num.tryParse(v);
                  if (parsed != null) {
                    _formData[field.key] = parsed;

                    if ((field.min != null && parsed < field.min!) ||
                        (field.max != null && parsed > field.max!)) {
                      _validationErrors[field.key] = 'Debe estar entre ${field.min} y ${field.max}';
                    } else {
                      _validationErrors[field.key] = null;
                    }
                  } else {
                    _formData[field.key] = null;
                    _validationErrors[field.key] = 'Ingrese un número válido';
                  }
                }
                setState(() {});
              },

              decoration: InputDecoration(
                labelText: field.label,
                errorText: _validationErrors[field.key],
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: _validationErrors[field.key] != null ? Colors.red : Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _validationErrors[field.key] != null ? Colors.red : Colors.grey),
                ),
              ),
            ),
          ],
        );

      case FieldType.multiline:
        return TextFormField(
          initialValue: value?.toString() ?? '',
          maxLines: 3,
          onChanged: (v) => _formData[field.key] = v,
          decoration: InputDecoration(
            labelText: field.label,
            errorText: _validationErrors[field.key],
            border: const OutlineInputBorder(),
          ),
        );

      case FieldType.checkbox:
        return CheckboxListTile(
          title: Text(field.label),
          value: _formData[field.key] as bool? ?? (value == true),
          onChanged: (v) => setState(() => _formData[field.key] = v ?? false),
        );

      case FieldType.radio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 16,
                runSpacing: 8,
                children: field.options!.map((option) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: option,
                        groupValue:
                            _formData[field.key] as String? ?? value?.toString(),
                        onChanged: (v) => setState(() => _formData[field.key] = v),
                      ),
                      Text(option),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );

      case FieldType.datetime:
        // 1) Convertir value a DateTime sin hora
        DateTime? currentDate;
        if (value != null) {
          DateTime raw;
          if (value is DateTime) {
            raw = value;
          } else {
            try {
              raw = (value as Timestamp).toDate();
            } catch (_) {
              raw = DateTime.parse(value.toString());
            }
          }
          // Descartamos la hora, quedamos solo con la parte de fecha
          currentDate = DateTime(raw.year, raw.month, raw.day);
        }
        // Si el usuario ya editó esa fecha, la preferimos (también sin hora)
        if (_formData[field.key] != null) {
          final edited = _formData[field.key] as DateTime;
          currentDate = DateTime(edited.year, edited.month, edited.day);
        }

        // 2) Calculamos hoy sin hora
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // 3) Elegimos initialDate = currentDate (si existe y no pasa de hoy) o hoy
        DateTime initial = currentDate ?? today;
        if (initial.isAfter(today)) {
          initial = today;
        }

        // 4) Preparamos el controlador con texto inicial
        final ctrl = _controllers[field.key] ??= TextEditingController(
          text: currentDate != null ? DateFormat('dd/MM/yyyy').format(currentDate) : '',
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Seleccionar fecha',
                errorText: _validationErrors[field.key],
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _validationErrors[field.key] != null ? Colors.red : Colors.grey,
                  ),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: DateTime(2000),
                  lastDate: today,
                );
                if (picked != null) {
                  setState(() {
                    // Guardamos solo la parte fecha
                    final clean = DateTime(picked.year, picked.month, picked.day);
                    _formData[field.key] = clean;
                    ctrl.text = DateFormat('dd/MM/yyyy').format(clean);
                    _validationErrors.remove(field.key);
                  });
                }
              },
            ),
          ],
        );
    }
  }

  /// Activa el modo edición (resetea la página de neonatología a 0)
  void _toggleEdit() {
    setState(() {
      isEditing = true;
      _page = 0; // Empezar en la primera página de neonatología
    });
  }

  /// Cancela la edición y revierte cambios
  void _cancelEdit() {
    setState(() {
      isEditing = false;
      _page = 0; // Resetear a la primera página
      _formData.clear(); // Volver a los detalles originales
    });
  }

  /// Guarda los cambios en Firestore mediante tu acción definida en el provider
  Future<void> _saveChanges() async {
    // 1) Validar todos los campos obligatorios y rangos
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los errores en el formulario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2) Reúne los datos…
    final spec = _currentSpecialty!;
    final fields = spec == 'neonatologia'
        ? [...neonatologyPage1, ...neonatologyPage2]
        : evolutionFormConfig[spec] ?? [];
    final details = <String, dynamic>{};
    for (final f in fields) {
      final v = _formData[f.key];
      details[f.key] = (f.type == FieldType.datetime && v is DateTime)
          ? Timestamp.fromDate(v)
          : v;
    }

    try {
      // 3) Guarda en Firestore
      await ref
          .read(evolutionActionsProvider(widget.patientId))
          .updateEvolution(widget.evolutionId, details);

      // 4) Al éxito, salimos del modo edición
      setState(() {
        isEditing = false;
        _page = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evolución actualizada correctamente')),
        );
      }
    } catch (e) {
      // 5) En caso de error al guardar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  /// Formatea un valor de tipo Timestamp / DateTime a "dd/MM/yyyy hh:mm"
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '';
    try {
      DateTime date;
      if (dateValue is DateTime) {
        date = dateValue;
      } else {
        // Asumimos que es un Timestamp de Firestore
        date = dateValue.toDate();
      }
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateValue.toString();
    }
  }
}
