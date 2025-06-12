import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/providers/evolution_provider.dart';
import 'package:sikum/presentation/providers/patient_provider.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/evolution_card.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';

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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLink(context, 'Datos maternos', '/pacientes/${p.id}/maternos', green),
                              const SizedBox(height: 8),
                              _buildLink(context, 'Datos de nacimiento', '/pacientes/${p.id}/nacimiento', green),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/pacientes/editar/${p.id}'),
                          style: TextButton.styleFrom(
                            foregroundColor: green,
                          ),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Editar paciente'),
                        ),
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
                    context.push('/pacientes/${p.id}/cerrar');
                    break;
                  case 'descargar':
                    _downloadPdf(p);
                    break;
                  case 'descargar_epicrisis':
                    _downloadEpicrisisPdf(p);
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
                PopupMenuItem(value: 'descargar_epicrisis', child: Text('Descargar Epicrisis')),
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

    // 1) Creo el documento
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
        for (final kv in details.entries)
          pw.Bullet(
            text: '${kv.key}: '
                  '${kv.value is Timestamp ? DateFormat("dd/MM/yyyy").format((kv.value as Timestamp).toDate()) : kv.value}',
          ),
        pw.Divider(),
      ]);
    }).toList();
  }

  /// ─────────────────────────────────────────────────────────────
  ///  NUEVA FUNCIÓN: DESCARGAR “EPICRISIS” (formato avanzado)
  /// ─────────────────────────────────────────────────────────────
  Future<void> _downloadEpicrisisPdf(Patient p) async {
    // 0) Pre-carga de los datos de “dischargeDataPatient” (documento único):
    final dischargeDoc = await FirebaseFirestore.instance
        .collection('dischargeDataPatient')
        .doc(p.id)
        .get();
    final dischargeMap = dischargeDoc.exists ? dischargeDoc.data()! : {};

    // 1) Cargo el logo (opcional)
    Uint8List? logoBytes;
    try {
      final data = await rootBundle.load('assets/logo.png');
      logoBytes = data.buffer.asUint8List();
    } catch (_) {
      logoBytes = null;
    }

    // 2) Cargo datos de usuario (médico logueado) para firma
    String doctorName = '';
    String doctorProvReg = '';
    try {
      final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      if (currentEmail.isNotEmpty) {
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentEmail)
            .limit(1)
            .get();
        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          doctorName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}';
          doctorProvReg = userData['provReg'] ?? '';
        }
      }
    } catch (_) {
      // Si falla, queda en blanco
      doctorName = '';
      doctorProvReg = '';
    }

    // 3) Extraigo datos de “birthData”, “maternalData”, “medicalRecordNumber” y “datosAlta”
    final birthData     = (dischargeMap['birthData']  as Map<String, dynamic>?) ?? {};
    final maternalData  = (dischargeMap['maternalData'] as Map<String, dynamic>?) ?? {};
    final altaData      = (dischargeMap['datosAlta'] as Map<String, dynamic>?) ?? {};
    final hClinicNumber = dischargeMap['medicalRecordNumber']?.toString() ?? '';

    // 4) Creo el documento PDF
    final doc = pw.Document();

    // 5) Monto la página con el formato deseado
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) {
          return [
            // ─── Encabezado con borde y logo ───
            pw.Center(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoBytes != null) ...[
                      pw.Container(
                        width: 60,
                        height: 60,
                        child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
                      ),
                      pw.SizedBox(width: 12),
                    ],
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Resumen de Historia Clínica - Internación Conjunta',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Maternidad Nuestra Señora del Pilar',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Provincia de Buenos Aires',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 12),

            // ─── Línea divisoria ───
            pw.Divider(),

            // ─── Recién nacido / H.Clínica ───
            pw.Container(
              color: PdfColors.grey300,
              padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Recién nacido: ${p.lastName.toUpperCase()} ${p.firstName.toUpperCase()}',
                      style:
                          pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Text(
                    'H.Clínica n°: $hClinicNumber',
                    style:
                        pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // ─── Datos de Nacimiento (texto corrido) ───
            pw.Text(
              'Fecha de Nacimiento: ${birthData['fechaNacimiento'] ?? ''}   '
              'Hora de Nacimiento: ${birthData['horaNacimiento'] ?? ''}',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Lugar de Nacimiento: ${birthData['lugarNacimiento'] ?? ''}',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Sexo: ${birthData['sexo'] ?? ''}   '
              'Gemelar: ${birthData['gemelar'] ?? ''}',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Tipo: ${birthData['tipoParto'] ?? ''}   '
              'Presentación: ${birthData['presentacion'] ?? ''}   '
              'Rotura de membranas: ${birthData['roturaMembranas'] ?? ''}   '
              'Líquido amniótico: ${birthData['liquidoAmniotico'] ?? ''}',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),

            // ─── Tabla de datos numéricos ───
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: .5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Edad gestacional: ${birthData['edadGestacional'] ?? ''}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Grupo y factor de la madre: ${birthData['grupoFactorMadre'] ?? ''}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Peso: ${birthData['pesoNacer'] ?? ''}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Grupo y factor del RN: ${birthData['grupoFactorRN'] ?? ''}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Talla: ${birthData['talla'] ?? ''}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'PCD: ${birthData['pcd'] ?? ''}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Perímetro cefálico: ${birthData['perimetroCefalico'] ?? ''}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Apgar: ${birthData['apgar'] ?? ''}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            // ─── Ex. físico al nacer ───
            pw.Text(
              'Ex. físico al nacer: ${birthData['examenFisicoAlNacer'] ?? ''}',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),

            // ─── FILA: Vacunas/estudios vs Datos Maternos ───
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // IZQUIERDA: Vacunas y estudios complementarios
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Vacunas y estudios complementarios:',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('- FEI: cartón N° ${birthData['feiCarton'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Fecha realización: ${birthData['feiFecha'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Evaluación oftalmológica - Fondo de ojo: ${birthData['evaluacionOftalmologica'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Evaluación audiológica: ${birthData['evaluacionAudiologica'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Test de saturación: ${birthData['testSaturacion'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Vacuna BCG: ${birthData['vacunaBcg'] ?? ''}    Hepatitis B: ${birthData['vacunaHepatitisB'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Profilaxis Vitamina K 1 mg: ${birthData['profilaxisVitK'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Colirio profiláctico en ambos ojos: ${birthData['colirio'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Datos al alta:',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('- Fecha de alta: ${altaData['fechaAlta'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Días de vida: ${altaData['diasVida'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Peso al alta: ${altaData['pesoAlta'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Descenso de peso: ${altaData['descensoPeso'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Alimentación: ${altaData['alimentacion'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Ex. físico al alta: ${altaData['exFisicoAlta'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Laboratorio durante la internación: ${altaData['labInternacion'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Diagnóstico 1°: ${altaData['diagnostico1'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Diagnóstico 2°: ${altaData['diagnostico2'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 8),
                    ],
                  ),
                ),

                pw.SizedBox(width: 12),

                // DERECHA: Datos Maternos dentro de un recuadro
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: .5),
                    ),
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Línea: Madre y DNI
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Madre: ${maternalData['lastName']?.toString().toUpperCase() ?? ''} '
                                '${maternalData['firstName']?.toString().toUpperCase() ?? ''}',
                                style: pw.TextStyle(
                                    fontSize: 10, fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                            pw.Text(
                              'DNI: ${maternalData['DNI'] ?? ''}',
                              style: pw.TextStyle(
                                  fontSize: 10, fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),

                        // Edad / Localidad / G P C A:
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                'Edad: ${maternalData['age'] ?? ''}',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              flex: 3,
                              child: pw.Text(
                                'Localidad: ${maternalData['locality'] ?? ''}',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                'G: ${maternalData['gravidity'] ?? ''}',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                'P: ${maternalData['parity'] ?? ''}',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                'C: ${maternalData['cesareans'] ?? ''}',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                'A: ${maternalData['abortions'] ?? ''}',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),

                        // Antecedentes si existen
                        if ((maternalData['antecedentes'] as String?)?.isNotEmpty ?? false)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Antecedentes clínicos/obstétricos maternos:',
                                style: pw.TextStyle(
                                    fontSize: 10, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Paragraph(
                                text: '${maternalData['antecedentes']}',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                              pw.SizedBox(height: 4),
                            ],
                          ),

                        // Serologías maternas en tabla
                        pw.Text('Serologías maternas:',
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Table(
                          border: pw.TableBorder.all(color: PdfColors.black, width: .5),
                          columnWidths: {
                            0: const pw.FlexColumnWidth(1),
                            1: const pw.FlexColumnWidth(1),
                          },
                          children: _buildSerologiaRows(
                            (maternalData['testResults'] as Map<String, dynamic>?) ?? {},
                            (maternalData['testDates'] as Map<String, dynamic>?) ?? {},
                          ),
                        ),
                        pw.SizedBox(height: 4),

                        // Observaciones si existen
                        if ((maternalData['observations'] as String?)?.isNotEmpty ?? false) ...[
                          pw.Text('Observaciones:',
                              style: pw.TextStyle(
                                  fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Paragraph(
                            text: maternalData['observations'] ?? '',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.SizedBox(height: 4),
                        ],

                        // Indicaciones si existen
                        if ((maternalData['indicaciones'] as String?)?.isNotEmpty ?? false) ...[
                          pw.Text('Indicaciones:',
                              style: pw.TextStyle(
                                  fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Paragraph(
                            text: maternalData['indicaciones'] ?? '',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Indicaciones Generales (Casillas)
            pw.Container(
              color: PdfColors.grey300,
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Center(
                child: pw.Text(
                  'INDICACIONES',
                  style:
                      pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            if ((maternalData['indicaciones'] as String?)?.isNotEmpty ?? false)
              ..._buildCheckListFromIndicaciones(maternalData['indicaciones'] as String),
            pw.SizedBox(height: 12),

            // Texto informativo final (con hipervínculo en "Lavate bien las manos")
            pw.Text(
              '¿CUÁNDO CONSULTAR EN LA GUARDIA?\n'
              'Fiebre (temperatura axilar > 37,8°C), dificultad para respirar, agitación, '
              'marca las costillas, aleteo nasal, coloración azulada o amarilla de piel o mucosas, '
              'falta de orina, mucosas secas, irritabilidad, somnolencia, movimientos anormales.',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'PAUTAS DE SUEÑO SEGURO\n'
              'Dormir boca arriba, en su propia cuna, sin almohada, colchón firme, tapado hasta tórax dejando brazo afuera, '
              'ambiente ventilado, NO FUMAR.',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'CUIDADOS DEL CORDÓN UMBILICAL\n'
              'El cordón umbilical se seca y se cae solo 1 o 2 semanas después del nacimiento.\n'
              'Hasta ese momento, debes cuidarlo una vez por día:',
              style: pw.TextStyle(fontSize: 10),
            ),

            // Enlace con wrap
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2, right: 4),
                  child: pw.Text('-', style: pw.TextStyle(fontSize: 10)),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'Lavate bien las manos con agua y jabón, y pasá suavemente por la zona una gasa con agua limpia. '
                    'Después tirala, no la dejes sobre el cordón. Tampoco tapes el cordón con el pañal, no uses "ombligueras", ni fajes al bebé.',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),

            // Segunda línea con dash en lugar de bullet
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2, right: 4),
                  child: pw.Text('-', style: pw.TextStyle(fontSize: 10)),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'Antes de la caída del cordón umbilical te recomendamos no darle baños de inmersión, porque podría retrasar su secado y caída. '
                    'Durante ese período tiempo higienizalo por partes y limpia el cordón con agua y gasa solamente.',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 24),

            // Pie de página con nombre y matrícula del médico
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Dr./Dra. $doctorName', style: pw.TextStyle(fontSize: 10)),
                pw.Text('M.P.: $doctorProvReg', style: pw.TextStyle(fontSize: 10)),
              ],
            ),
          ];
        },
      ),
    );

    // Compartir/descargar Epicrisis
    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Epicrisis_${p.lastName}_${p.firstName}_${p.dni}.pdf',
    );
  }

  /// Construye las filas de serologías maternas en la tabla de dos columnas
  List<pw.TableRow> _buildSerologiaRows(
      Map<String, dynamic> results, Map<String, dynamic> dates) {
    final keys = <String>[
      'VDRL',
      'Chagas',
      'HIV',
      'Toxo IgG',
      'Hepatitis B',
      'Toxo IgM',
      'EGB',
      'TPHA'
    ];
    List<pw.TableRow> rows = [];
    for (int i = 0; i < keys.length; i += 2) {
      final key1 = keys[i];
      final key2 = (i + 1 < keys.length) ? keys[i + 1] : '';
      final res1 = results[key1] ?? 'Sin dato';
      final date1 = dates[key1] ?? '';
      final res2 = key2.isNotEmpty ? (results[key2] ?? 'Sin dato') : '';
      final date2 = key2.isNotEmpty ? (dates[key2] ?? '') : '';

      rows.add(
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                '$key1: $res1${date1 != '' ? '  $date1' : ''}',
                style: pw.TextStyle(fontSize: 9),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                key2.isNotEmpty ? '$key2: $res2${date2 != '' ? '  $date2' : ''}' : '',
                style: pw.TextStyle(fontSize: 9),
              ),
            ),
          ],
        ),
      );
    }
    return rows;
  }

  /// Transforma el texto de “indicaciones” (separado por saltos de línea) en una lista de checkboxes
  List<pw.Widget> _buildCheckListFromIndicaciones(String indicaciones) {
    final lines = indicaciones
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    return lines.map((l) {
      final texto = l.trim().replaceFirst(RegExp(r'^[-•]\s*'), '');
      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 10,
            height: 10,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
            ),
            margin: const pw.EdgeInsets.only(top: 2, right: 4),
          ),
          pw.Expanded(
              child: pw.Text(texto, style: pw.TextStyle(fontSize: 10))),
        ],
      );
    }).toList();
  }
}
