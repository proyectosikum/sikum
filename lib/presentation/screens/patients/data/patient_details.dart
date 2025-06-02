import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/providers/evolution_provider.dart';
import 'package:sikum/presentation/widgets/evolution_card.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PatientDetailsScreen extends ConsumerStatefulWidget {
  final String patientId;
  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends ConsumerState<PatientDetailsScreen> {
  String selectedSpecialty = 'Todas';

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(patientDetailsStreamProvider(widget.patientId));
    const green = Color(0xFF4F959D);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: green)),
        error: (_, __) => const Center(child: Text('Error al cargar paciente')),
        data: (p) {
          if (p == null) {
            return const Center(child: Text('Paciente no encontrado'));
          }
          return _buildContent(context, p);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Patient p) {
    const green = Color(0xFF4F959D);
    const cream = Color(0xFFFFF8E1);
    const black = Colors.black87;

    final evolutionsAsync = ref.watch(evolutionsStreamProvider(p.id));

    return SafeArea(
      child: Column(
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
                          'Detalle de paciente',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // SizedBox para balancear el espacio que ocupa el IconButton
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: green, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLink(context, 'Datos maternos', '/pacientes/${p.id}/maternos', green),
                        const SizedBox(height: 8),
                        _buildLink(context, 'Datos de nacimiento', '/pacientes/${p.id}/nacimiento', green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Título + PopupMenuButton de especialidades
                  Row(
                    children: [
                      const Text(
                        'Evolución',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: black),
                      ),
                      const Spacer(),
                      evolutionsAsync.when(
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                        data: (list) {
                          // construimos la lista de opciones
                          final specs = <String>{ for (var e in list) e.specialty }..removeWhere((s) => s.isEmpty);
                          final options = ['Todas', ...specs.toList()..sort()];
                          if (!options.contains(selectedSpecialty)) {
                            selectedSpecialty = 'Todas';
                          }
                          return PopupMenuButton<String>(
                            color: cream,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: green),
                            ),
                            initialValue: selectedSpecialty,
                            onSelected: (value) {
                              setState(() => selectedSpecialty = value);
                            },
                            itemBuilder: (_) {
                              return options.map((s) {
                                final label = s[0].toUpperCase() + s.substring(1).toLowerCase();
                                return PopupMenuItem(
                                  value: s,
                                  child: Text(label),
                                );
                              }).toList();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cream,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: green, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    selectedSpecialty == 'Todas'
                                      ? 'Todas'
                                      : (selectedSpecialty[0].toUpperCase() + selectedSpecialty.substring(1).toLowerCase()),
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Evoluciones filtradas
                  evolutionsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: green)),
                    error: (_, __) => const Center(child: Text('Error al cargar evoluciones')),
                    data: (list) {
                      final filtered = selectedSpecialty == 'Todas'
                          ? list
                          : list.where((e) => e.specialty == selectedSpecialty).toList();
                      if (filtered.isEmpty) {
                        return const Center(child: Text('Sin evoluciones registradas'));
                      }
                      return Column(
                        children: filtered
                            .map((e) => EvolutionCard(evolution: e, patientId: p.id))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Menú de acciones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: PopupMenuButton<String>(
              color: cream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: green),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'evolucionar':
                    context.push('/paciente/evolucionar/${p.id}');
                    break;
                  case 'cerrar':
                    break;
                  case 'descargar':
                    _downloadPdf(p);
                    break;
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: green, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Seleccione una acción...', style: TextStyle(fontSize: 16)),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'evolucionar', child: Text('Evolucionar')),
                PopupMenuItem(value: 'cerrar', child: Text('Cerrar HC')),
                PopupMenuItem(value: 'descargar', child: Text('Descargar HC')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLink(BuildContext context, String text, String route, Color color) {
    return InkWell(
      onTap: () => GoRouter.of(context).push(route),
      child: Row(
        children: [
          Icon(Icons.chevron_right, color: color, size: 20),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(Patient p) async {
    // 0) Pre-carga de datos fuera del build()
    final maternosSnap    = await _loadSubdoc(p.id, 'maternos');
    final nacimientoSnap  = await _loadSubdoc(p.id, 'nacimiento');
    final evolRows        = await _evolutionsRows(p.id);

    // 1) Crea el documento
    final doc = pw.Document();

    // 2) Añade la página SIN await en el build()
    doc.addPage(pw.MultiPage(build: (ctx) {
      return [
        // Cabecera paciente
        pw.Header(level: 0, text: 'Historia Clínica - ${p.firstName} ${p.lastName}'),
        pw.Paragraph(text: 'DNI: ${p.dni}'),
        pw.SizedBox(height: 12),

        // Datos Maternos
        pw.Header(level: 1, text: 'Datos Maternos'),
        ..._rowList(maternosSnap),

        // Datos Nacimiento
        pw.Header(level: 1, text: 'Datos de Nacimiento'),
        ..._rowList(nacimientoSnap),

        // Evoluciones
        pw.Header(level: 1, text: 'Evoluciones'),
        ...evolRows,
      ];
    }));

    // 3) Comparte/descarga
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'HC_${p.dni}.pdf',
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _loadSubdoc(String pid, String key) {
    return FirebaseFirestore.instance
      .collection('pacientes')
      .doc(pid)
      .collection(key)
      .doc('data')
      .get();
  }

  List<pw.Widget> _rowList(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists) return [pw.Text('No disponible')];
    return snap.data()!
        .entries
        .map((e) => pw.Bullet(text: '${e.key}: ${e.value}'))
        .toList();
  }

  Future<List<pw.Widget>> _evolutionsRows(String pid) async {
    // 1) Apuntamos a la colección raíz “evolutions”
    final snap = await FirebaseFirestore.instance
      .collection('evolutions')
      .where('patientId', isEqualTo: pid)
      .orderBy('createdAt')
      .get();

    if (snap.docs.isEmpty) {
      return [pw.Text('Sin evoluciones')];
    }

    return snap.docs.map((d) {
      final m = d.data();
      final details = m['details'] as Map<String, dynamic>;

      return pw.Column(children: [
        pw.Text(
          'Especialidad: ${m['specialty']}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        // Para cada clave/valor dentro de details
        for (final kv in details.entries)
          pw.Bullet(
            text: '${kv.key}: '
                  // aquí usamos comillas dobles para DateFormat
                  '${kv.value is Timestamp ? DateFormat("dd/MM/yyyy").format((kv.value as Timestamp).toDate()) : kv.value}',
          ),
        pw.Divider(),
      ]);
    }).toList();
  }
}
