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

    // 1) Cargo datos de usuario (médico logueado) para firma
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
      doctorName = '';
      doctorProvReg = '';
    }

    // 2) Extraigo datos de “birthData”, “maternalData”, “closureOfHospitalization” y “evolutions”
    final birthData    = (dischargeMap['birthData']  as Map<String, dynamic>?) ?? {};
    final maternalData = (dischargeMap['maternalData'] as Map<String, dynamic>?) ?? {};

    // cierres de internación
    final clinicalClosure = (dischargeMap['closureOfHospitalization'] as Map<String, dynamic>?)
      ?? <String, dynamic>{};

    // — Datos básicos del RN —
    final birthDateStr      = birthData['birthDate']?.toString() ?? '';
    final birthTime         = birthData['birthTime']?.toString() ?? '';
    final placeOfBirth      = birthData['placeOfBirth']          ?? '';
    final sex               = birthData['sex']                   ?? '';
    final twin              = birthData['twin']                  ?? '';
    final birthType         = birthData['birthType']             ?? '';
    final presentation      = birthData['presentation']          ?? '';
    final ruptureOfMembrane = birthData['ruptureOfMembrane']     ?? '';
    final amnioticFluid     = birthData['amnioticFluid']         ?? '';
    final gestationalAge    = birthData['gestationalAge']?.toString() ?? '';
    final birthWeight       = birthData['weight']?.toString()       ?? '';
    final babyBloodType     = birthData['bloodType']             ?? '';
    final length            = birthData['length']?.toString()       ?? '';
    final headCircumference = birthData['headCircumference']?.toString() ?? '';
    final apgar1            = birthData['firstApgarScore']?.toString()  ?? '';
    final apgar2            = birthData['secondApgarScore']?.toString() ?? '';
    final apgar3            = birthData['thirdApgarScore']?.toString()  ?? '';
    final apgarScore        = '$apgar1/$apgar2/$apgar3';
    final physicalExamBirth = birthData['physicalExamination'] ?? '';

    // — Datos maternos —
    final motherName    = '${maternalData['firstName'] ?? ''} ${maternalData['lastName'] ?? ''}';
    final motherDni     = maternalData['idNumber']  ?? '';
    final motherAge     = maternalData['age']?.toString() ?? '';
    final motherLocality= maternalData['locality'] ?? '';
    final gravidity     = maternalData['gravidity']?.toString() ?? '';
    final parity        = maternalData['parity']?.toString() ?? '';
    final cesareans     = maternalData['cesareans']?.toString() ?? '';
    final abortions     = maternalData['abortions']?.toString() ?? '';
    final testResults   = maternalData['testResults'] as Map<String, dynamic>? ?? {};
    final testDates     = maternalData['testDates']   as Map<String, dynamic>? ?? {};

    // — Evolutions: FEI
    final feiSnap = await FirebaseFirestore.instance
        .collection('evolutions')
        .where('patientId', isEqualTo: p.id)
        .where('specialty', isEqualTo: 'enfermeria_fei')
        .limit(1)
        .get();
    final feiDetails = feiSnap.docs.isNotEmpty
        ? (feiSnap.docs.first.data()['details'] as Map<String, dynamic>)
        : <String, dynamic>{};
    final feiRecordNumber = feiDetails['recordNumber']?.toString() ?? '';

    final feiDateRaw = feiDetails['feiDate'];
    DateTime? feiDate = feiDateRaw is Timestamp
        ? feiDateRaw.toDate()
        : feiDateRaw is String
            ? DateTime.tryParse(feiDateRaw)
            : null;
    // luego formateamos de forma segura
    final feiDateFormatted = feiDate != null
        ? DateFormat('dd/MM/yyyy').format(feiDate)
        : '';

    // — Evolutions: test de saturación
    final satSnap = await FirebaseFirestore.instance
        .collection('evolutions')
        .where('patientId', isEqualTo: p.id)
        .where('specialty', isEqualTo: 'enfermeria_test_saturacion')
        .limit(1)
        .get();
    final satDetails = satSnap.docs.isNotEmpty
        ? (satSnap.docs.first.data()['details'] as Map<String, dynamic>)
        : <String, dynamic>{};
    final preDuctal  = satDetails['preDuctalSaturationResult']?.toString()  ?? '';
    final postDuctal = satDetails['postDuctalSaturationResult']?.toString() ?? '';

    // — Evolutions: vacuna BCG
    final vacSnap = await FirebaseFirestore.instance
        .collection('evolutions')
        .where('patientId', isEqualTo: p.id)
        .where('specialty', isEqualTo: 'vacunatorio')
        .limit(1)
        .get();
    final vacDetails = vacSnap.docs.isNotEmpty
        ? (vacSnap.docs.first.data()['details'] as Map<String, dynamic>)
        : <String, dynamic>{};
    final bcgApplied = (vacDetails['bcg'] as bool?) == true ? 'Aplicada' : 'No aplicada';

    // — Vacunas al nacer del birthData —
    final hepBVaccine = (birthData['hasHepatitisBVaccine'] as bool?) == true ? 'Aplicada' : 'No aplicada';
    final vitK        = (birthData['hasVitaminK'] as bool?) == true ? 'Aplicada' : 'No aplicada';
    final ophthDrops  = (birthData['hasOphthalmicDrops'] as bool?) == true ? 'Aplicada' : 'No aplicada';

    // — Cierre clínico de internación —
    final dischargeRaw = clinicalClosure['date'];
    // convertimos a DateTime si es Timestamp o String
    DateTime? dischargeDate = dischargeRaw is Timestamp
        ? dischargeRaw.toDate()
        : dischargeRaw is String
            ? DateTime.tryParse(dischargeRaw)
            : null;
    // formateamos de manera segura
    final dischargeDateFormatted = dischargeDate != null
        ? DateFormat('dd/MM/yyyy').format(dischargeDate)
        : '';

    final dischargeWeight      = clinicalClosure['weight']?.toString()  ?? '';
    int diasVida = 0;
    if (birthDateStr.isNotEmpty && dischargeDateFormatted.isNotEmpty) {
      final bDate = DateTime.parse(birthDateStr);
      final dDate = DateTime.parse(dischargeDateFormatted);
      diasVida = dDate.difference(bDate).inDays;
    }
    double descensoPeso = 0;
    if (birthWeight.isNotEmpty && dischargeWeight.isNotEmpty) {
      final w0 = double.tryParse(birthWeight) ?? 0;
      final w1 = double.tryParse(dischargeWeight) ?? 0;
      if (w0 > 0) descensoPeso = ((w0 - w1) / w0) * 100;
    }
    final feedOption          = clinicalClosure['feedingOption'] ?? '';
    final formulaMl           = clinicalClosure['formulaMl']?.toString() ?? '';
    final feedingAtDischarge2 = feedOption == 'leche_formula'
        ? 'Leche de fórmula ($formulaMl ml)'
        : feedOption;
    final physicalExamDischarge = clinicalClosure['physicalExamination'] ?? '';
    final nextControlRaw = clinicalClosure['nextControlDate'];
    // convierte a DateTime si es Timestamp o String
    DateTime? nextControlDate = nextControlRaw is Timestamp
        ? nextControlRaw.toDate()
        : nextControlRaw is String
            ? DateTime.tryParse(nextControlRaw)
            : null;
    // formateo seguro
    final nextControlFormatted = nextControlDate != null
        ? DateFormat('dd/MM/yyyy').format(nextControlDate)
        : '';
    final nextControlLocation   = clinicalClosure['nextControlLocation'] ?? '';
    final needsAudiology        = (clinicalClosure['needsAudiology'] as bool?) == true;
    final needsOphthalmology    = (clinicalClosure['needsOphthalmology'] as bool?) == true;

    // 3) Creo el documento PDF
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) {
          return [
            // -- Encabezado --
            pw.Center(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('Resumen de Historia Clínica - Internación Conjunta',
                            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Maternidad Nuestra Señora del Pilar',
                            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Provincia de Buenos Aires',
                            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.Container(
              color: PdfColors.grey300,
              padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Recién nacido: ${p.lastName.toUpperCase()} ${p.firstName.toUpperCase()}',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Text(
                    'H.Clínica n°: ${dischargeMap['medicalRecordNumber']?.toString() ?? ''}',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // -- Datos de nacimiento --
            pw.Text(
              'Fecha de Nacimiento: $birthDateStr   Hora de Nacimiento: $birthTime',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 2),
            pw.Text('Lugar de Nacimiento: $placeOfBirth', style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 2),
            pw.Text('Sexo: $sex   Gemelar: $twin', style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 4),
            pw.Text(
              'Tipo: $birthType   Presentación: $presentation   Rotura de membranas: $ruptureOfMembrane   Líquido amniótico: $amnioticFluid',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),

            // -- Tabla de datos de nacimiento --
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: .5),
              columnWidths: {0: const pw.FlexColumnWidth(1), 1: const pw.FlexColumnWidth(1)},
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Edad gestacional: $gestationalAge', style: pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Grupo y factor de la madre: ${birthData['grupoFactorMadre'] ?? ''}',
                          style: pw.TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Peso: $birthWeight', style: pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Grupo y factor del RN: $babyBloodType',
                          style: pw.TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Talla: $length', style: pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('PCD: $headCircumference', style: pw.TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Perímetro cefálico: $headCircumference', style: pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Apgar: $apgarScore', style: pw.TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            // -- Ex. físico al nacer --
            pw.Text('Ex. físico al nacer: $physicalExamBirth', style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 8),

            // -- Vacunas y datos maternos --
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // -- Vacunas y estudios --
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Vacunas y estudios complementarios:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text('- FEI: cartón N° $feiRecordNumber', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Fecha realización: $feiDateFormatted', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Evaluación oftalmológica - Fondo de ojo: ${birthData['evaluacionOftalmologica'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Evaluación audiológica: ${birthData['evaluacionAudiologica'] ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Test de saturación pre-ductal: $preDuctal', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Test de saturación post-ductal: $postDuctal', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Vacuna BCG: $bcgApplied    Hepatitis B: $hepBVaccine', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Profilaxis Vitamina K 1 mg: $vitK', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Colirio profiláctico en ambos ojos: $ophthDrops', style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 8),
                      pw.Text('Datos al alta:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text('- Fecha de alta: $dischargeDateFormatted', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Días de vida: $diasVida', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Peso al alta: $dischargeWeight', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Descenso de peso: ${descensoPeso.toStringAsFixed(1)} %', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Alimentación: $feedingAtDischarge2', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('- Ex. físico al alta: $physicalExamDischarge', style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 8),
                    ],
                  ),
                ),
                pw.SizedBox(width: 12),
                // -- Datos maternos --
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: .5)),
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Container(
                        color: PdfColors.grey300,
                        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text('Madre: ${motherName.toUpperCase()}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Text('DNI: $motherDni', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(children: [
                        pw.Expanded(flex: 2, child: pw.Text('Edad: $motherAge', style: pw.TextStyle(fontSize: 10))),
                        pw.Expanded(flex: 3, child: pw.Text('Localidad: $motherLocality', style: pw.TextStyle(fontSize: 10))),
                        pw.Expanded(flex: 1, child: pw.Text('G: $gravidity', style: pw.TextStyle(fontSize: 10))),
                        pw.Expanded(flex: 1, child: pw.Text('P: $parity', style: pw.TextStyle(fontSize: 10))),
                        pw.Expanded(flex: 1, child: pw.Text('C: $cesareans', style: pw.TextStyle(fontSize: 10))),
                        pw.Expanded(flex: 1, child: pw.Text('A: $abortions', style: pw.TextStyle(fontSize: 10))),
                      ]),
                      pw.SizedBox(height: 4),
                      pw.Text('Serologías maternas:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.black, width: .5),
                        columnWidths: {0: const pw.FlexColumnWidth(1), 1: const pw.FlexColumnWidth(1)},
                        children: _buildSerologiaRows(testResults, testDates),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // -- Indicaciones generales --
            pw.Container(
              color: PdfColors.grey300,
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Center(child: pw.Text('INDICACIONES', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
            ),
            pw.SizedBox(height: 8),
            pw.Bullet(text: 'Alimentación al alta: $feedingAtDischarge2', style: pw.TextStyle(fontSize: 10)),
            pw.Bullet(text: 'Vitamina ACD 0,3 ml vía oral (todos los días).', style: pw.TextStyle(fontSize: 10)),
            pw.Bullet(
              text: 'Retirar resultados pendientes de FEI en oficina de alta conjunta a los 30 días de vida en los siguientes horarios: Lunes a viernes de 8 a 17 hs. Sábado, Domingos y Feriados de 8 a 16 hs.',
              style: pw.TextStyle(fontSize: 10)
            ),
            pw.SizedBox(height: 12),

            // -- Turnos a solicitar --
            pw.Text('Turnos a solicitar en oficina de alta conjunta', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('1- Solicitar turno para: $nextControlFormatted en $nextControlLocation', style: pw.TextStyle(fontSize: 10)),
            pw.Text('2- ¿Solicitar turno para OEA?: ${needsAudiology ? 'Sí' : 'No'}', style: pw.TextStyle(fontSize: 10)),
            pw.Text('3- ¿Solicitar turno para oftalmología?: ${needsOphthalmology ? 'Sí' : 'No'}', style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 12),

            // -- Información final --
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

            // -- Pie de página --
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
}
