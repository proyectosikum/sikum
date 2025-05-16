// lib/presentation/screens/evolution_form_screen.dart

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

  @override
  void initState() {
    super.initState();
    // Inicializa valores por defecto
    for (final spec in evolutionFormConfig.keys) {
      for (final f in evolutionFormConfig[spec]!) {
        _formData[f.key] = f.type == FieldType.checkbox
            ? false
            : f.type == FieldType.radio
                ? null
                : '';
      }
    }
  }

  Future<void> _save() async {
    final payload = {
      'specialty': selectedSpec,
      'details': _formData,
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
          if (p == null) {
            return const Center(child: Text('Paciente no encontrado'));
          }
          return _buildForm(context, p);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, Patient p) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);
    const black = Colors.black87;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TÍTULO
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
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // DATOS DEL PACIENTE
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'DNI: ${p.dni}',
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

          // FORMULARIO
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
                    // Selector de especialidad
                    PopupMenuButton<String>(
                      color: cream,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: green),
                      ),
                      initialValue: selectedSpec,
                      onSelected: (v) => setState(() => selectedSpec = v),
                      itemBuilder: (_) => evolutionFormConfig.keys.map((s) {
                        final label = s == 'enfermeria'
                            ? 'Enfermería'
                            : s == 'puericultura_servsocial'
                                ? 'Puericultura / Servicio Social'
                                : s[0].toUpperCase() + s.substring(1);
                        return PopupMenuItem(value: s, child: Text(label));
                      }).toList(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: cream,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: green),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedSpec == 'enfermeria'
                                  ? 'Enfermería'
                                  : selectedSpec ==
                                          'puericultura_servsocial'
                                      ? 'Puericultura / Servicio Social'
                                      : selectedSpec[0].toUpperCase() +
                                          selectedSpec.substring(1),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Campos dinámicos con espacio uniforme
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
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

          // BOTONES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: green),
                    onPressed: _save,
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
            Text(
              f.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // Fila horizontal de opciones
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                    const SizedBox(width: 16), // espacio entre opciones
                  ],
                );
              }).toList(),
            ),
          ],
        );
    }
  }
}
