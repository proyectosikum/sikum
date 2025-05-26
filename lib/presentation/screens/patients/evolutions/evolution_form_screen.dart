import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/evolution_provider.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/screens/patients/evolutions/evolution_fields_config.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

class EvolutionFormScreen extends ConsumerStatefulWidget {
  final String patientId;
  const EvolutionFormScreen({super.key, required this.patientId});

  @override
  ConsumerState<EvolutionFormScreen> createState() => _EvolutionFormScreenState();
}

class _EvolutionFormScreenState extends ConsumerState<EvolutionFormScreen> {
  late String selectedSpec = evolutionFormConfig.keys.first;
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  int _page = 0;

  @override
  void initState() {
    super.initState();
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
  }

  void _resetFormForSpec(String spec) {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _formData.clear();

    final List<FieldConfig> fields = spec == 'neonatologia'
        ? [...neonatologyPage1, ...neonatologyPage2]
        : evolutionFormConfig[spec]!;
    for (final f in fields) {
      _initField(f);
    }
  }

  Future<void> _save() async {
    final List<FieldConfig> fields = selectedSpec == 'neonatologia'
        ? [...neonatologyPage1, ...neonatologyPage2]
        : evolutionFormConfig[selectedSpec]!;
    final Map<String, dynamic> details = {};
    for (final f in fields) {
      final v = _formData[f.key];
      details[f.key] = (f.type == FieldType.datetime && v is DateTime)
          ? Timestamp.fromDate(v)
          : v;
    }
    await ref
        .read(evolutionActionsProvider(widget.patientId))
        .addEvolution({'specialty': selectedSpec, 'details': details});
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4F959D);
    final patientAsync = ref.watch(patientDetailsStreamProvider(widget.patientId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: patientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: green)),
        error: (_, __) => const Center(child: Text('Error al cargar paciente')),
        data: (p) {
          if (p == null) return const Center(child: Text('Paciente no encontrado'));
          return _buildForm(context, p);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, Patient p) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);
    const black = Colors.black87;
    final isNeonato = selectedSpec == 'neonatologia';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Center(
              child: Text('Evolución', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black)),
            ),
          ),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: green)),
                child: Column(
                  children: [
                    _buildSpecSelector(green, cream),
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
                        setState(() => _page = 1);
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

  Widget _buildSpecSelector(Color green, Color cream) {
    return PopupMenuButton<String>(
      color: cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: green)),
      initialValue: selectedSpec,
      onSelected: (newSpec) {
        _resetFormForSpec(newSpec);
        setState(() {
          selectedSpec = newSpec;
          _page = 0;
        });
      },
      itemBuilder: (_) => evolutionFormConfig.keys.map((s) => PopupMenuItem(value: s, child: Text(_specLabel(s)))).toList(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: green)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_specLabel(selectedSpec)), const Icon(Icons.arrow_drop_down)]),
      ),
    );
  }

  String _specLabel(String key) {
    switch (key) {
      case 'enfermeria': return 'Enfermería';
      case 'enfermeria_fei': return 'Enfermería FEI';
      case 'enfermeria_test_saturacion': return 'Enfermería Test Saturación';
      case 'vacunatorio': return 'Vacunatorio';
      case 'fonoaudiologia': return 'Fonoaudiología';
      case 'puericultura': return 'Puericultura';
      case 'servicio_social': return 'Servicio Social';
      case 'interconsultor': return 'Interconsultor';
      case 'neonatologia': return 'Neonatología';
      case 'neonatologia_adicional': return 'Neonatología Adicional';
      default: return key[0].toUpperCase() + key.substring(1);
    }
  }

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
              Radio<String>(value: opt, groupValue: examValue, onChanged: (v) => setState(() => _formData['physicalExam'] = v)),
              Text(opt),
            ],
          );
        }).toList()),
        if (examValue == 'Anormal') ...[
          const SizedBox(height: 12),
          _buildFieldWidget(neonatologyPage1.firstWhere((f) => f.key == 'abnormalObservation')),
        ],
        const SizedBox(height: 16),
        for (final f in neonatologyPage1.where((f) => f.key != 'physicalExam' && f.key != 'abnormalObservation')) ...[
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
    switch (f.type) {
      case FieldType.text:
        return TextField(
          controller: _controllers[f.key],
          onChanged: (v) => _formData[f.key] = v,
          decoration: InputDecoration(labelText: f.label),
        );
      case FieldType.number:
        return TextField(
          controller: _controllers[f.key],
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => _formData[f.key] = num.tryParse(v) ?? 0,
          decoration: InputDecoration(labelText: f.label),
        );
      case FieldType.multiline:
        return TextField(
          controller: _controllers[f.key],
          maxLines: 3,
          onChanged: (v) => _formData[f.key] = v,
          decoration: InputDecoration(labelText: f.label),
        );
      case FieldType.checkbox:
        return CheckboxListTile(title: Text(f.label), value: _formData[f.key] as bool, onChanged: (v) => setState(() => _formData[f.key] = v));
      case FieldType.radio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f.label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        onChanged: (v) => setState(() => _formData[f.key] = v),
                      ),
                      Text(opt),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      case FieldType.datetime:
        return TextField(
          controller: _controllers[f.key],
          readOnly: true,
          decoration: InputDecoration(labelText: f.label),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _formData[f.key] ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              _formData[f.key] = picked;
              _controllers[f.key]!.text = DateFormat('dd/MM/yyyy').format(picked);
              setState(() {});
            }
          },
        );
    }
  }
}
