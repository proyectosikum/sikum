// lib/presentation/screens/patients/evolutions/evolution_details.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/evolution_provider.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/providers/user_provider.dart';     // Ya lo tenías
import 'package:sikum/presentation/screens/patients/evolutions/evolution_fields_config.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

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
  bool isEditing = false;
  int _page = 0; // Para neonatología, controla página 0 o 1
  final Map<String, dynamic> _formData = {};

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

    // ----------------------------------------------------------------------------------------------------
    // 1) Extraemos de la evolución: specialty, details, createdAt y createdByUserId
    final String specialty = evolution['specialty'] as String;
    final Map<String, dynamic> details = evolution['details'] as Map<String, dynamic>;
    final dynamic createdAt = evolution['createdAt'];                    // Suele ser un Timestamp de Firestore
    final String createdByUserId = evolution['createdByUserId'] as String;
    // ----------------------------------------------------------------------------------------------------

    // ----------------------------------------------------------------------------------------------------
    // 2) Obtenemos el usuario logueado actual
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    // ----------------------------------------------------------------------------------------------------

    // ----------------------------------------------------------------------------------------------------
    // 3) Calculamos si estamos DENTRO de la hora desde createdAt:
    DateTime? createdDateTime;
    if (createdAt is Timestamp) {
      createdDateTime = createdAt.toDate();
    } else if (createdAt is DateTime) {
      createdDateTime = createdAt;
    } else {
      // Si no es Timestamp ni DateTime, intentamos parsear (por si guardaste String)
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
    // ----------------------------------------------------------------------------------------------------

    // ----------------------------------------------------------------------------------------------------
    // 4) Determinamos si el usuario puede editar:
    //    - Debe estar logueado (currentUserId != null)
    //    - Debe coincidir currentUserId == createdByUserId
    //    - Debe estar dentro de la hora
    final bool canEdit = (currentUserId != null)
        && (currentUserId == createdByUserId)
        && withinOneHour;
    // ----------------------------------------------------------------------------------------------------

    // ----------------------------------------------------------------------------------------------------
    // 5) Inicializamos _formData con los datos de "details" la primera vez (si viene vacío)
    if (_formData.isEmpty) {
      _formData.addAll(details);
    }
    // ----------------------------------------------------------------------------------------------------

    // ----------------------------------------------------------------------------------------------------
    // 6) Definimos los campos a mostrar según la especialidad
    final List<FieldConfig> fields = specialty == 'neonatologia'
        ? [...neonatologyPage1, ...neonatologyPage2]
        : evolutionFormConfig[specialty] ?? [];

    final bool isNeonato = specialty == 'neonatologia';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TÍTULO
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

                // ──────────────────────────────────────────────────────────────────────────────────────────────
                // Si canEdit == true O si ya estamos en modo edición (isEditing), mostramos el IconButton. Si no, dejamos un SizedBox (para mantener simetría).
                if (canEdit || isEditing) ...[
                  IconButton(
                    icon: Icon(isEditing ? Icons.save : Icons.edit),
                    onPressed: isEditing
                        ? _saveChanges
                        : (canEdit
                            ? () {
                                _toggleEdit();
                              }
                            : null),
                  ),
                ] else ...[
                  // Espacio vacío para mantener la alineación (aprox. 48px de ancho para el icono)
                  const SizedBox(width: 48),
                ],
                // ──────────────────────────────────────────────────────────────────────────────────────────────
              ],
            ),
          ),

          // DATOS DEL PACIENTE (Solo nombre y DNI)
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'DNI: ${patient.dni}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // CONTENIDO DE LA EVOLUCIÓN CON INFO DEL PROFESIONAL
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
                    // INFORMACIÓN DEL PROFESIONAL (Fija arriba)
                    _buildProfessionalInfo(createdByUserId, specialty, createdAt),

                    // FORMULARIO (Scrolleable)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: isEditing && isNeonato
                              ? (_page == 0 ? _buildNeonatoPage1() : _buildNeonatoPage2())
                              : Column(
                                  children: [
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

          // BOTONES DE "Cancelar / Guardar" O "Atrás / Siguiente" (solo si estamos en modo edición)
          if (isEditing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // Botón "Atrás" (para neonatología) o "Cancelar"
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (isNeonato && _page == 1) {
                          setState(() => _page = 0);
                        } else {
                          _cancelEdit();
                        }
                      },
                      child: Text(isNeonato && _page == 1 ? 'Atrás' : 'Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Botón "Siguiente" (para neonatología) o "Guardar"
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F959D)),
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
              'Especialidad: ${_getSpecialtyDisplayName(specialty)}',
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
              'Especialidad: ${_getSpecialtyDisplayName(specialty)}',
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
                'Especialidad: ${_getSpecialtyDisplayName(specialty)}',
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
                      text: _getSpecialtyDisplayName(specialty),
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
          displayValue = _formatDate(value);
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
            border: const OutlineInputBorder(),
          ),
        );

      case FieldType.number:
        return TextFormField(
          initialValue: value?.toString() ?? '',
          keyboardType: TextInputType.number,
          onChanged: (v) => _formData[field.key] = v,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
        );

      case FieldType.multiline:
        return TextFormField(
          initialValue: value?.toString() ?? '',
          maxLines: 3,
          onChanged: (v) => _formData[field.key] = v,
          decoration: InputDecoration(
            labelText: field.label,
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
        // Obtener el valor actual de fecha
        DateTime? currentDate;
        if (value != null) {
          if (value is DateTime) {
            currentDate = value;
          } else {
            try {
              // Si es un Timestamp de Firestore
              currentDate = value.toDate();
            } catch (e) {
              // Si es un String, intentar parsearlo
              try {
                currentDate = DateTime.parse(value.toString());
              } catch (e) {
                currentDate = null;
              }
            }
          }
        }

        // Si hay un valor en _formData, lo usamos
        if (_formData[field.key] != null) {
          currentDate = _formData[field.key] as DateTime;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: currentDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: currentDate != null
                        ? TimeOfDay.fromDateTime(currentDate)
                        : TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    final DateTime finalDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    setState(() {
                      _formData[field.key] = finalDateTime;
                    });
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      currentDate != null
                          ? _formatDate(currentDate)
                          : 'Seleccionar fecha y hora',
                      style: TextStyle(
                        fontSize: 16,
                        color: currentDate != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
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
    try {
      await ref
          .read(evolutionActionsProvider(widget.patientId))
          .updateEvolution(widget.evolutionId, _formData);

      setState(() {
        isEditing = false;
        _page = 0; // Resetear página
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evolución actualizada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  /// Convierte nombres de especialidades con guiones bajos a título
  String _getSpecialtyDisplayName(String specialty) {
    return specialty.isNotEmpty
        ? specialty
            .replaceAll('_', ' ')
            .toLowerCase()
            .replaceFirst(specialty.replaceAll('_', ' ').toLowerCase()[0],
              specialty.replaceAll('_', ' ').toLowerCase()[0].toUpperCase())
        : specialty;
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
