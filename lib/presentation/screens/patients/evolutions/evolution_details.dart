// lib/presentation/screens/patients/evolutions/evolution_details.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/evolution_provider.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/providers/user_provider.dart'; // Agregado
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

    final specialty = evolution['specialty'] as String;
    final details = evolution['details'] as Map<String, dynamic>;
    final createdAt = evolution['createdAt'];
    final createdByUserId = evolution['createdByUserId'] as String;
    
    // Inicializar formData si está vacío
    if (_formData.isEmpty) {
      _formData.addAll(details);
    }

    final fields = evolutionFormConfig[specialty] ?? [];

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
                IconButton(
                  icon: Icon(isEditing ? Icons.save : Icons.edit),
                  onPressed: isEditing ? _saveChanges : _toggleEdit,
                ),
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
                          child: Column(
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

          // BOTONES
          if (isEditing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelEdit,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F959D)),
                      onPressed: _saveChanges,
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

Widget _buildProfessionalInfo(String createdByUserId, String specialty, dynamic createdAt) {
  // DEBUG: Verificar datos de entrada
  print('=== DEBUG PROFESSIONAL INFO ===');
  print('createdByUserId: "$createdByUserId"');
  print('createdByUserId.isEmpty: ${createdByUserId.isEmpty}');
  print('specialty: "$specialty"');
  print('createdAt: $createdAt');
  print('===============================');
  
  // Si el userId está vacío, mostrar error específico
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
  
  // USAR EL NUEVO PROVIDER QUE ESPERA String (no String?)
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
        // MEJORAR EL MANEJO DE ERRORES
        print('ERROR en userByIdStreamProvider: $error');
        print('StackTrace: $stackTrace');
        
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
        print('DEBUG: Usuario cargado: ${user?.toString()}');
        
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
            Row(
              children: field.options!.map((option) {
                return Expanded(
                  child: RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _formData[field.key] as String? ?? value?.toString(),
                    onChanged: (v) => setState(() => _formData[field.key] = v),
                  ),
                );
              }).toList(),
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
        
        // Si hay un valor en _formData, usarlo
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

  void _toggleEdit() {
    setState(() {
      isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      isEditing = false;
      _formData.clear(); // Limpiar cambios
    });
  }

  Future<void> _saveChanges() async {
    try {
      await ref
          .read(evolutionActionsProvider(widget.patientId))
          .updateEvolution(widget.evolutionId, _formData);
      
      setState(() {
        isEditing = false;
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

  String _getSpecialtyDisplayName(String specialty) {
    switch (specialty) {
      case 'enfermeria':
        return 'Enfermería';
      case 'puericultura_servsocial':
        return 'Puericultura / Servicio Social';
      case 'fonoaudiologia':
        return 'Fonoaudiología';
      case 'vacunatorio':
        return 'Vacunatorio';
      case 'interconsultor':
        return 'Interconsultor';
      default:
        return specialty.isNotEmpty 
            ? '${specialty[0].toUpperCase()}${specialty.substring(1)}'
            : specialty;
    }
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '';
    
    try {
      DateTime date;
      if (dateValue is DateTime) {
        date = dateValue;
      } else {
        // Asumiendo que es un Timestamp de Firestore
        date = dateValue.toDate();
      }
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateValue.toString();
    }
  }
}