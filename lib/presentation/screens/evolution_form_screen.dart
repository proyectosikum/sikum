import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/evolution_provider.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/screens/evolution_fields_config.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

class EvolutionFormScreen extends ConsumerStatefulWidget {
  final String patientId;
  const EvolutionFormScreen({super.key, required this.patientId});

  @override
  ConsumerState<EvolutionFormScreen> createState() =>
      _EvolutionFormScreenState();
}

class _EvolutionFormScreenState extends ConsumerState<EvolutionFormScreen> {
  late String selectedSpec = evolutionFormConfig.keys.first;
  final Map<String, dynamic> _formData = {};
  int _page = 0; // For Neonatology: 0=page1, 1=page2

  @override
  void initState() {
    super.initState();
    // initialize defaults for all specialties
    for (final spec in evolutionFormConfig.keys) {
      for (final f in evolutionFormConfig[spec]!) {
        _formData[f.key] =
            f.type == FieldType.checkbox ? false : f.type == FieldType.radio ? null : '';
      }
    }
    // Neonatology page1
    for (final f in neonatologyPage1) {
      _formData[f.key] =
          f.type == FieldType.checkbox ? false : f.type == FieldType.radio ? null : '';
    }
    // Neonatology page2
    for (final f in neonatologyPage2) {
      _formData[f.key] =
          f.type == FieldType.checkbox ? false : f.type == FieldType.radio ? null : '';
    }
  }

  Future<void> _save() async {
    // Build only the fields relevant to the selected specialty:
    Map<String, dynamic> details;
    if (selectedSpec == 'neonatologia') {
      // include both pages' keys
      details = {
        for (final f in [...neonatologyPage1, ...neonatologyPage2])
          f.key: _formData[f.key],
      };
    } else {
      details = {
        for (final f in evolutionFormConfig[selectedSpec]!)
          f.key: _formData[f.key],
      };
    }

    final payload = {
      'specialty': selectedSpec,
      'details': details,
    };
    await ref
        .read(evolutionActionsProvider(widget.patientId))
        .addEvolution(payload);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final patientAsync =
        ref.watch(patientDetailsStreamProvider(widget.patientId));
    const green = Color(0xFF4F959D);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: patientAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: green)),
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
          // TITLE
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Center(
              child: Text(
                'Evolución',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: black,
                ),
              ),
            ),
          ),

          // PATIENT INFO
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
                      '${p.lastName}, ${p.firstName}',
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'DNI: ${p.dni}',
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // FORM
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: green),
                ),
                child: Column(
                  children: [
                    _buildSpecSelector(green, cream),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: isNeonato
                            ? (_page == 0
                                ? _buildNeonatoPage1()
                                : _buildNeonatoPage2())
                            : Column(
                                children: [
                                  for (final f
                                      in evolutionFormConfig[selectedSpec]!) ...[
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

          // BUTTONS
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
                        context.pop();
                      }
                    },
                    child: Text(isNeonato && _page == 1 ? 'Atrás' : 'Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: green),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: green),
      ),
      initialValue: selectedSpec,
      onSelected: (v) {
        setState(() {
          selectedSpec = v;
          _page = 0;
        });
      },
      itemBuilder: (_) => evolutionFormConfig.keys.map((s) {
        String label;
        switch (s) {
          case 'enfermeria':
            label = 'Enfermería';
            break;
          case 'vacunatorio':
            label = 'Vacunatorio';
            break;
          case 'fonoaudiologia':
            label = 'Fonoaudiología';
            break;
          case 'puericultura':
            label = 'Puericultura';
            break;
          case 'servicio social':
            label = 'Servicio Social';
            break;
          case 'interconsultor':
            label = 'Interconsultor';
            break;
          case 'neonatologia':
            label = 'Neonatología';
            break;
          default:
            label = s[0].toUpperCase() + s.substring(1);
        }
        return PopupMenuItem(value: s, child: Text(label));
      }).toList(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: green),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedSpec == 'neonatologia'
                  ? 'Neonatología'
                  : selectedSpec[0].toUpperCase() + selectedSpec.substring(1),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  /// Neonatology page 1: show textarea only on "Anormal"
  Widget _buildNeonatoPage1() {
    final examValue = _formData['physicalExam'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Physical exam radio
        Text('Examen físico', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 16,
          children: ['Normal', 'Anormal'].map((opt) {
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
          }).toList(),
        ),

        // only if "Anormal"
        if (examValue == 'Anormal') ...[
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(labelText: '¿Qué observo?'),
            onChanged: (v) => _formData['abnormalObservation'] = v,
          ),
        ],

        const SizedBox(height: 16),
        // rest of page1
        for (final f in neonatologyPage1
            .where((f) => f.key != 'physicalExam' && f.key != 'abnormalObservation')) ...[
          _buildFieldWidget(f),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  /// Neonatology page 2
  Widget _buildNeonatoPage2() {
    const titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Indicaciones', style: titleStyle),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('PMLD'),
          value: _formData['pmld'] as bool,
          onChanged: (v) => setState(() => _formData['pmld'] = v),
        ),
        CheckboxListTile(
          title: const Text('CSV por turno'),
          value: _formData['csvByShift'] as bool,
          onChanged: (v) => setState(() => _formData['csvByShift'] = v),
        ),

        const SizedBox(height: 16),
        Text('Alimentación', style: titleStyle),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('PMLD'),
          value: _formData['feedingPmld'] as bool,
          onChanged: (v) => setState(() => _formData['feedingPmld'] = v),
        ),
        CheckboxListTile(
          title: const Text('PMLD + complemento'),
          value: _formData['feedingPmldComplement'] as bool,
          onChanged: (v) => setState(() => _formData['feedingPmldComplement'] = v),
        ),
        if (_formData['feedingPmldComplement'] as bool) ...[
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 8),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Cantidad de ML/3hs'),
              onChanged: (v) => _formData['feedingMlQuantity'] = v,
            ),
          ),
        ],
        CheckboxListTile(
          title: const Text('LF'),
          value: _formData['lf'] as bool,
          onChanged: (v) => setState(() => _formData['lf'] = v),
        ),
        if (_formData['lf'] as bool) ...[
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 8),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Cantidad de ML/3hs'),
              onChanged: (v) => _formData['lfMlQuantity'] = v,
            ),
          ),
        ],

        const SizedBox(height: 16),
        _buildFieldWidget(
            neonatologyPage2.firstWhere((f) => f.key == 'phototherapy')),
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
          onChanged: (v) => _formData[f.key] = v,
          decoration: InputDecoration(labelText: f.label),
        );
      case FieldType.number:
        return TextField(
          keyboardType: TextInputType.number,
          onChanged: (v) => _formData[f.key] = v,
          decoration: InputDecoration(labelText: f.label),
        );
      case FieldType.multiline:
        return TextField(
          maxLines: 3,
          onChanged: (v) => _formData[f.key] = v,
          decoration: InputDecoration(labelText: f.label),
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
    }
  }
}
