import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/birth_data_provider.dart';
import 'package:sikum/presentation/providers/evolution_provider.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/screens/patients/evolutions/evolution_fields_config.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:sikum/router/app_router.dart';
import 'package:sikum/utils/string_utils.dart';

const Map<String, List<String>> _labelToKeys = {
  'Enfermería': [
    'enfermeria',
    'enfermeria_fei',
    'enfermeria_test_saturacion',
    'enfermeria_cambio_pulsera',
  ],
  'Neonatología': [
    'neonatologia',
    'neonatologia_adicional',
  ]
};

class EvolutionFormScreen extends ConsumerStatefulWidget {
  final String patientId;
  const EvolutionFormScreen({super.key, required this.patientId});

  @override
  ConsumerState<EvolutionFormScreen> createState() => _EvolutionFormScreenState();
}

class _EvolutionFormScreenState extends ConsumerState<EvolutionFormScreen> {
  List<String> _allowedSpecs = [];
  String selectedSpec = '';

  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _validationErrors = {}; // Para errores de validación
  int _page = 0;

  @override
  void initState() {
    super.initState();

    final userSpecLabel = authChangeNotifier.specialty ?? '';

    if (_labelToKeys.containsKey(userSpecLabel)) {
      _allowedSpecs = _labelToKeys[userSpecLabel]!;
    } else {
      final match = evolutionFormConfig.keys.firstWhere(
        (key) => getSpecialtyDisplayName(key) == userSpecLabel,
        orElse: () => evolutionFormConfig.keys.first,
      );
      _allowedSpecs = [match];
    }

    selectedSpec = _allowedSpecs.first;
    _resetFormForSpec(selectedSpec);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initField(FieldConfig f) {
    switch (f.type) {
      case FieldType.checkbox:
        _formData[f.key] = false;
        break;
      case FieldType.radio:
        _formData[f.key] = null;
        break;
      case FieldType.datetime:
        _formData[f.key] = null;
        _controllers[f.key] = TextEditingController();
        break;
      case FieldType.text:
      case FieldType.number:
      case FieldType.multiline:
        _formData[f.key] = '';
        _controllers[f.key] = TextEditingController();
        break;
    }
    // Limpiar cualquier error de validación previo
    _validationErrors[f.key] = null;
  }

  void _resetFormForSpec(String spec) {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _formData.clear();
    _validationErrors.clear();

    final fields = spec == 'neonatologia'
        ? [...neonatologyPage1, ...neonatologyPage2]
        : evolutionFormConfig[spec]!;
    for (final f in fields) {
      _initField(f);
    }
  }

  /// Valida todos los campos obligatorios y comprueba rangos en los FieldType.number
  bool _validateForm() {
    _validationErrors.clear();
    bool isValid = true;

    // 1) Recoge los FieldConfig según la especialidad
    final fields = selectedSpec == 'neonatologia'
        ? [...neonatologyPage1, ...neonatologyPage2]
        : evolutionFormConfig[selectedSpec] ?? [];

    final examValue = _formData['physicalExam'] as String?;

    for (final f in fields) {
      if (selectedSpec == 'neonatologia') {
        if (f.key == 'abnormalObservation' && examValue != 'Anormal') {
          continue;
        }
        if (f.key == 'lfMlQuantity' &&
            (_formData['lf'] as bool? ?? false) == false) {
          continue;
        }
        if (f.key == 'feedingMlQuantity' &&
            (_formData['feedingPmldComplement'] as bool? ?? false) == false) {
          continue;
        }
      }

      final val = _formData[f.key];
      bool empty = false;

      // 2) Chequeo de obligatoriedad
      switch (f.type) {
        case FieldType.text:
        case FieldType.multiline:
          empty = (val as String?)?.trim().isEmpty ?? true;
          break;
        case FieldType.number:
          empty = val == null || val.toString().isEmpty;
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
        continue; // no chequeamos rango si está vacío
      }

      // 3) Si es numérico, chequea min/max
      if (f.type == FieldType.number && val != null && val.toString().isNotEmpty) {
        final numVal = val is num ? val : num.tryParse(val.toString());
        if (numVal != null) {
          if ((f.min != null && numVal < f.min!) ||
              (f.max != null && numVal > f.max!)) {
            _validationErrors[f.key] =
                'Debe estar entre ${f.min} y ${f.max}';
            isValid = false;
          }
        }
      }
    }

    setState(() {}); // refresca los errores en pantalla
    return isValid;
  }

  /// Valida los campos obligatorios de neonatología (página 1)
  bool _validateNeonatologyPage1() {
    bool isValid = true;
    _validationErrors.clear();

    final examValue = _formData['physicalExam'] as String?;

    for (final f in neonatologyPage1) {
      if (!f.isRequired) continue;

      // Si es abnormalObservation pero no estamos en “Anormal”, lo omitimos
      if (f.key == 'abnormalObservation' && examValue != 'Anormal') continue;

      final val = _formData[f.key];
      bool empty;
      switch (f.type) {
        case FieldType.text:
        case FieldType.multiline:
          empty = (val as String?)?.trim().isEmpty ?? true;
          break;
        case FieldType.number:
        case FieldType.datetime:
        case FieldType.radio:
          empty = val == null;
          break;
        case FieldType.checkbox:
          empty = false;
          break;
      }
      if (empty) {
        _validationErrors[f.key] = 'Este campo es obligatorio';
        isValid = false;
      }
    }

    setState(() {}); // refrescará los errores visibles
    return isValid;
  }

  Future<void> _save() async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los errores en el formulario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 1) Reúne los datos
    final fields = selectedSpec == 'neonatologia'
        ? [...neonatologyPage1, ...neonatologyPage2]
        : evolutionFormConfig[selectedSpec]!;
    final details = <String, dynamic>{};
    for (final f in fields) {
      final v = _formData[f.key];
      details[f.key] = (f.type == FieldType.datetime && v is DateTime)
          ? Timestamp.fromDate(v)
          : v;
    }

    // 2) Lógica personalizada para cambio de pulsera
    if (selectedSpec == 'enfermeria_cambio_pulsera') {
      final birthDataNotifier = ref.read(birthDataProvider.notifier);
      final birthData = ref.read(birthDataProvider);
      final nuevoNumero = _formData['braceletNumberNew'] as int?;

      if (birthData != null && nuevoNumero != null) {
        final viejoNumero = birthData.braceletNumber;

        // Agregar datos al mapa de detalles
        details['braceletNumberOld'] = viejoNumero;
        details['braceletNumberNew'] = nuevoNumero;

        // Actualizar el número de pulsera en birthData
        birthDataNotifier.updateBraceletNumber(nuevoNumero);
      }
    }

    try {
      // 3) Guarda en Firestore
      await ref
          .read(evolutionActionsProvider(widget.patientId))
          .addEvolution({'specialty': selectedSpec, 'details': details});

      if (!mounted) return;

      // 4) Muestra el diálogo de éxito
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFFFFF8E1),
          title: const Text("Evolución registrada ✅"),
          content: const Text("La evolución se ha guardado correctamente."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // cerrar diálogo
                context.pop(); // volver atrás
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar evolución: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4F959D);

    // 1) Stream de paciente
    final patientAsync = ref.watch(patientDetailsStreamProvider(widget.patientId));
    // 2) Stream de evoluciones
    final evolutionsAsync = ref.watch(evolutionsStreamProvider(widget.patientId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: patientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: green)),
        error: (_, __) => const Center(child: Text('Error al cargar paciente')),
        data: (p) {
          if (p == null) return const Center(child: Text('Paciente no encontrado'));

          // Esperamos al stream de evoluciones
          return evolutionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: green)),
            // Si hay error, en lugar de bloquear con un Center(...), simplemente construimos el form con hasFei=false
            error: (_, __) => _buildForm(context, p, green, false),
            data: (evolutions) {
              final hasFei = evolutions.any((e) => e.specialty == 'enfermeria_fei');
              return _buildForm(context, p, green, hasFei);
            },
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, Patient p, Color green, bool hasFei) {
    const cream = Color(0xFFFFF8E1);
    const black = Colors.black87;

    if (_allowedSpecs.isEmpty) {
      // Programa la inicialización justo después de este frame
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          final userSpec = authChangeNotifier.specialty ?? '';
          _allowedSpecs = _labelToKeys[userSpec] ??
              [
                evolutionFormConfig.keys
                    .firstWhere((k) => getSpecialtyDisplayName(k) == userSpec,
                        orElse: () => evolutionFormConfig.keys.first)
              ];
          selectedSpec = _allowedSpecs.first;
          _resetFormForSpec(selectedSpec);
        });
      });
    }

    final isNeonato = selectedSpec == 'neonatologia';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Center(
              child: Text('Evolución', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black)),
            ),
          ),
          // Tarjeta paciente
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: green)),
              child: Row(
                children: [
                  Expanded(child: Text('${p.lastName}, ${p.firstName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  Text('DNI: ${p.dni}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Formulario
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: green)),
                child: Column(
                  children: [
                    _buildSpecSelector(green, cream, hasFei),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: isNeonato
                            ? (_page == 0 ? _buildNeonatoPage1() : _buildNeonatoPage2())
                            : Column(
                                children: [
                                  for (final f in evolutionFormConfig[selectedSpec]!) ...[
                                    _buildFieldWidget(f),
                                    const SizedBox(height: 16),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: green),
                      foregroundColor: green,
                    ),
                    onPressed: () {
                      if (isNeonato && _page == 1) {
                        setState(() => _page = 0);
                      } else {
                        context.pop();
                      }
                    },
                    child: Text(isNeonato && _page == 1 ? 'Atrás' : 'Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: cream,
                    ),
                    onPressed: () {
                      if (isNeonato && _page == 0) {
                        if (_validateNeonatologyPage1()) {
                          setState(() => _page = 1);
                        }
                      } else {
                        _save();
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

  Widget _buildSpecSelector(Color green, Color cream, bool hasFei) {
    // Filtramos la lista local de _allowedSpecs
    final specs = _allowedSpecs
        .where((s) => !(hasFei && s == 'enfermeria_fei'))
        .toList();

    if (specs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: green),
        ),
        child: const Text(
          'No hay especialidades disponibles',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Si el spec seleccionado ya no está en la lista, lo reasignamos
    if (!specs.contains(selectedSpec)) {
      selectedSpec = specs.first;
      _resetFormForSpec(selectedSpec);
    }

    return PopupMenuButton<String>(
      enabled: specs.length > 1,
      color: cream,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: green)),
      initialValue: selectedSpec,
      onSelected: (newSpec) {
        _resetFormForSpec(newSpec);
        setState(() {
          selectedSpec = newSpec;
          _page = 0;
        });
      },
      itemBuilder: (_) =>
          specs.map((s) => PopupMenuItem(value: s, child: Text(getSpecialtyDisplayName(s))))
              .toList(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: green)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(getSpecialtyDisplayName(selectedSpec)), const Icon(Icons.arrow_drop_down)],
        ),
      ),
    );
  }


  Widget _buildNeonatoPage1() {
    final examValue = _formData['physicalExam'] as String?;
    final hasExamError = _validationErrors['physicalExam'] != null;
    const errorColor = Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Examen físico',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: hasExamError ? errorColor : Colors.black,
          ),
        ),
        const SizedBox(height: 4),

        // Los radios
        Wrap(
          spacing: 16,
          children: ['Normal', 'Anormal'].map((opt) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: opt,
                  groupValue: examValue,
                  onChanged: (v) => setState(() {
                    _formData['physicalExam'] = v;
                    _validationErrors.remove('physicalExam');
                  }),
                ),
                Text(
                  opt,
                  style: TextStyle(
                    color: hasExamError
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
              ],
            );
          }).toList(),
        ),

        // Aquí mostramos el texto de error
        if (hasExamError) ...[
          const SizedBox(height: 4),
          Text(
            'Este campo es obligatorio',
            style: const TextStyle(color: errorColor, fontSize: 12),
          ),
        ],

        const SizedBox(height: 16),

        // Si eligió "Anormal", mostramos el textarea
        if (examValue == 'Anormal') ...[
          _buildFieldWidget(
            neonatologyPage1.firstWhere((f) => f.key == 'abnormalObservation')
          ),
          const SizedBox(height: 16),
        ],

        // El resto de campos de la página 1
        for (final f in neonatologyPage1.where((f) =>
            f.key != 'physicalExam' && f.key != 'abnormalObservation')) ...[
          _buildFieldWidget(f),
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
        CheckboxListTile(title: const Text('PMLD'), value: _formData['pmld'] as bool, onChanged: (v) => setState(() => _formData['pmld'] = v)),
        CheckboxListTile(title: const Text('CSV por turno'), value: _formData['csvByShift'] as bool, onChanged: (v) => setState(() => _formData['csvByShift'] = v)),
        const SizedBox(height: 16),
        Text('Alimentación', style: titleStyle),
        const SizedBox(height: 8),
        CheckboxListTile(title: const Text('PMLD'), value: _formData['feedingPmld'] as bool, onChanged: (v) => setState(() => _formData['feedingPmld'] = v)),
        CheckboxListTile(title: const Text('PMLD + complemento'), value: _formData['feedingPmldComplement'] as bool, onChanged: (v) => setState(() => _formData['feedingPmldComplement'] = v)),
        if (_formData['feedingPmldComplement'] as bool) ...[
          Padding(padding: const EdgeInsets.only(left: 15, bottom: 8), child: _buildFieldWidget(neonatologyPage2.firstWhere((f) => f.key == 'feedingMlQuantity'))),
        ],
        CheckboxListTile(title: const Text('LF'), value: _formData['lf'] as bool, onChanged: (v) => setState(() => _formData['lf'] = v)),
        if (_formData['lf'] as bool) ...[
          Padding(padding: const EdgeInsets.only(left: 15, bottom: 8), child: _buildFieldWidget(neonatologyPage2.firstWhere((f) => f.key == 'lfMlQuantity'))),
        ],
        const SizedBox(height: 16),
        _buildFieldWidget(neonatologyPage2.firstWhere((f) => f.key == 'phototherapy')),
        const SizedBox(height: 16),
        _buildFieldWidget(neonatologyPage2.firstWhere((f) => f.key == 'medication')),
        const SizedBox(height: 16),
        _buildFieldWidget(neonatologyPage2.firstWhere((f) => f.key == 'observations')),
      ],
    );
  }

  Widget _buildFieldWidget(FieldConfig f) {
    final hasError = _validationErrors[f.key] != null;
    final errorColor = Colors.red;

    switch (f.type) {
      case FieldType.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controllers[f.key],
              onChanged: (v) {
                _formData[f.key] = v;
                // Limpiar error si el usuario empieza a escribir
                if (hasError && v.trim().isNotEmpty) {
                  setState(() {
                    _validationErrors[f.key] = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: f.label,
                errorText: _validationErrors[f.key],
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: hasError ? errorColor : Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: hasError ? errorColor : Colors.grey),
                ),
              ),
            ),
          ],
        );
      case FieldType.number:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controllers[f.key],
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) {
                if (v.trim().isEmpty) {
                  // Vacío: marcar como nulo y dejar error si es requerido
                  _formData[f.key] = null;
                  if (f.isRequired) {
                    _validationErrors[f.key] = 'Este campo es obligatorio';
                  }
                } else {
                  final parsed = num.tryParse(v);
                  if (parsed != null) {
                    _formData[f.key] = parsed;

                    // Validación de rango
                    if ((f.min != null && parsed < f.min!) || (f.max != null && parsed > f.max!)) {
                      _validationErrors[f.key] = 'Debe estar entre ${f.min} y ${f.max}';
                    } else {
                      _validationErrors[f.key] = null;
                    }
                  } else {
                    _formData[f.key] = null;
                    _validationErrors[f.key] = 'Ingrese un número válido';
                  }
                }
                setState(() {});
              },

              decoration: InputDecoration(
                labelText: f.label,
                errorText: _validationErrors[f.key],
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: hasError ? errorColor : Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: hasError ? errorColor : Colors.grey),
                ),
              ),
            ),
          ],
        );

      case FieldType.multiline:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controllers[f.key],
              maxLines: 3,
              onChanged: (v) {
                _formData[f.key] = v;
                // Limpiar error si el usuario empieza a escribir
                if (hasError && v.trim().isNotEmpty) {
                  setState(() {
                    _validationErrors[f.key] = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: f.label,
                errorText: _validationErrors[f.key],
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: hasError ? errorColor : Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: hasError ? errorColor : Colors.grey),
                ),
              ),
            ),
          ],
        );
      case FieldType.checkbox:
        return CheckboxListTile(
          title: Text(f.label),
          value: _formData[f.key] as bool,
          onChanged: (v) => setState(() => _formData[f.key] = v),
        );
      case FieldType.radio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              f.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: hasError ? errorColor : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 16,
                runSpacing: 8,
                children: f.options!.map((opt) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: opt,
                        groupValue: _formData[f.key] as String?,
                        onChanged: (v) {
                          setState(() {
                            _formData[f.key] = v;
                            // Limpiar error cuando se selecciona una opción
                            if (hasError) {
                              _validationErrors[f.key] = null;
                            }
                          });
                        },
                      ),
                      Text(opt),
                    ],
                  );
                }).toList(),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 4),
              Text(
                _validationErrors[f.key]!,
                style: TextStyle(color: errorColor, fontSize: 12),
              ),
            ],
          ],
        );
      case FieldType.datetime:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controllers[f.key],
              readOnly: true,
              decoration: InputDecoration(
                labelText: f.label,
                errorText: _validationErrors[f.key],
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: hasError ? errorColor : Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: hasError ? errorColor : Colors.grey),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _formData[f.key] ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  _formData[f.key] = picked;
                  final ctrl = _controllers[f.key];
                  if (ctrl != null) {
                    ctrl.text = DateFormat('dd/MM/yyyy').format(picked);
                  }
                  // Limpiar error cuando se selecciona una fecha
                  if (hasError) {
                    setState(() {
                      _validationErrors[f.key] = null;
                    });
                  } else {
                    setState(() {});
                  }
                }
              },
            ),
          ],
        );
    }
  }
}
