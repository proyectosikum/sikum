import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../entities/patient.dart';

class EpicrisisPdfService {
  static Future<void> downloadEpicrisisPdf(Patient p) async {
    final dischargeDoc =
        await FirebaseFirestore.instance
            .collection('dischargeDataPatient')
            .doc(p.id)
            .get();
    final dischargeMap = dischargeDoc.exists ? dischargeDoc.data()! : {};

    final clinicalClosure =
        (dischargeMap['closureOfHospitalization'] as Map<String, dynamic>?) ??
        <String, dynamic>{};

    String doctorName = '';
    String doctorProvReg = '';
    try {
      final createdById = clinicalClosure['createdBy'] as String?;
      if (createdById != null && createdById.isNotEmpty) {
        final docSnap =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(createdById)
                .get();
        if (docSnap.exists) {
          final userData = docSnap.data()!;
          doctorName =
              '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}';
          doctorProvReg = userData['provReg'] ?? '';
        }
      }
    } catch (_) {
      doctorName = '';
      doctorProvReg = '';
    }

    final birthData =
        (dischargeMap['birthData'] as Map<String, dynamic>?) ?? {};
    final maternalData =
        (dischargeMap['maternalData'] as Map<String, dynamic>?) ?? {};

    // Datos de Nacimiento
    final birthDateRaw = birthData['birthDate'];
    DateTime? birthDate =
        birthDateRaw is Timestamp
            ? birthDateRaw.toDate()
            : birthDateRaw is String
            ? DateTime.tryParse(birthDateRaw)
            : null;
    final birthDateStr =
        birthDate != null ? DateFormat('dd/MM/yyyy').format(birthDate) : '';
    final birthTime = birthData['birthTime']?.toString() ?? '';
    final placeOfBirth = birthData['birthPlace'] ?? '';
    final sex = birthData['sex'] ?? '';
    final twin = birthData['twin'] ?? '';
    final birthType = birthData['birthType'] ?? '';
    final presentation = birthData['presentation'] ?? '';
    final ruptureOfMembrane = birthData['ruptureOfMembrane'] ?? '';
    final amnioticFluid = birthData['amnioticFluid'] ?? '';
    final gestationalAge = birthData['gestationalAge']?.toString() ?? '';
    final birthWeight = birthData['weight']?.toString() ?? '';
    final babyBloodType = birthData['bloodType'] ?? '';
    final length = birthData['length']?.toString() ?? '';
    final headCircumference = birthData['headCircumference']?.toString() ?? '';
    final apgar1 = birthData['firstApgarScore']?.toString() ?? '';
    final apgar2 = birthData['secondApgarScore']?.toString() ?? '';
    final apgar3 = birthData['thirdApgarScore']?.toString() ?? '';
    final apgarScore = '$apgar1/$apgar2/$apgar3';
    final physicalExamBirth = birthData['physicalExamination'] ?? '';

    // Datos maternos
    final motherName =
        '${maternalData['firstName'] ?? ''} ${maternalData['lastName'] ?? ''}';
    final motherDni = maternalData['idNumber'] ?? '';
    final motherAge = maternalData['age']?.toString() ?? '';
    final motherLocality = maternalData['locality'] ?? '';
    final gravidity = maternalData['gravidity']?.toString() ?? '';
    final parity = maternalData['parity']?.toString() ?? '';
    final cesareans = maternalData['cesareans']?.toString() ?? '';
    final abortions = maternalData['abortions']?.toString() ?? '';
    final testResults =
        maternalData['testResults'] as Map<String, dynamic>? ?? {};
    final testDates = maternalData['testDates'] as Map<String, dynamic>? ?? {};
    final bloodType = maternalData['bloodType'] ?? '';

    // Evoluciones
    final feiSnap =
        await FirebaseFirestore.instance
            .collection('evolutions')
            .where('patientId', isEqualTo: p.id)
            .where('specialty', isEqualTo: 'enfermeria_fei')
            .limit(1)
            .get();
    final feiDetails =
        feiSnap.docs.isNotEmpty
            ? (feiSnap.docs.first.data()['details'] as Map<String, dynamic>)
            : <String, dynamic>{};
    final feiRecordNumber = feiDetails['recordNumber']?.toString() ?? '';

    final feiDateRaw = feiDetails['feiDate'];
    DateTime? feiDate =
        feiDateRaw is Timestamp
            ? feiDateRaw.toDate()
            : feiDateRaw is String
            ? DateTime.tryParse(feiDateRaw)
            : null;
    final feiDateFormatted =
        feiDate != null ? DateFormat('dd/MM/yyyy').format(feiDate) : '';

    final satSnap =
        await FirebaseFirestore.instance
            .collection('evolutions')
            .where('patientId', isEqualTo: p.id)
            .where('specialty', isEqualTo: 'enfermeria_test_saturacion')
            .limit(1)
            .get();
    final satDetails =
        satSnap.docs.isNotEmpty
            ? (satSnap.docs.first.data()['details'] as Map<String, dynamic>)
            : <String, dynamic>{};
    final preDuctal = satDetails['preDuctalSaturationResult']?.toString() ?? '';
    final postDuctal =
        satDetails['postDuctalSaturationResult']?.toString() ?? '';

    final vacSnap =
        await FirebaseFirestore.instance
            .collection('evolutions')
            .where('patientId', isEqualTo: p.id)
            .where('specialty', isEqualTo: 'vacunatorio')
            .limit(1)
            .get();
    final vacDetails =
        vacSnap.docs.isNotEmpty
            ? (vacSnap.docs.first.data()['details'] as Map<String, dynamic>)
            : <String, dynamic>{};
    final bcgApplied =
        (vacDetails['bcg'] as bool?) == true ? 'Aplicada' : 'No aplicada';

    final hepBVaccine =
        (birthData['hasHepatitisBVaccine'] as bool?) == true
            ? 'Aplicada'
            : 'No aplicada';
    final vitK =
        (birthData['hasVitaminK'] as bool?) == true
            ? 'Aplicada'
            : 'No aplicada';
    final ophthDrops =
        (birthData['hasOphthalmicDrops'] as bool?) == true
            ? 'Aplicada'
            : 'No aplicada';

    // Cierre clínico
    final dischargeRaw = clinicalClosure['date'];
    DateTime? dischargeDate =
        dischargeRaw is Timestamp
            ? dischargeRaw.toDate()
            : dischargeRaw is String
            ? DateTime.tryParse(dischargeRaw)
            : null;
    final dischargeDateFormatted =
        dischargeDate != null
            ? DateFormat('dd/MM/yyyy').format(dischargeDate)
            : '';

    final dischargeWeight = clinicalClosure['weight']?.toString() ?? '';
    int diasVida = 0;
    if (birthDate != null && dischargeDate != null) {
      diasVida = dischargeDate.difference(birthDate).inDays;
    }
    double descensoPeso = 0;
    if (birthWeight.isNotEmpty && dischargeWeight.isNotEmpty) {
      final w0 = double.tryParse(birthWeight) ?? 0;
      final w1 = double.tryParse(dischargeWeight) ?? 0;
      if (w0 > 0) descensoPeso = ((w0 - w1) / w0) * 100;
    }
    final feedOption = clinicalClosure['feedingOption'] ?? '';
    final formulaMl = clinicalClosure['formulaMl']?.toString() ?? '';
    final feedingAtDischarge2 =
        feedOption == 'leche_formula'
            ? 'Leche de fórmula ($formulaMl ml)'
            : feedOption;

    final physicalExamDischarge = clinicalClosure['physicalExamination'] ?? '';
    final physicalExamDetails =
        clinicalClosure['physicalExaminationDetails'] ?? '';

    final normalized = physicalExamDischarge.toLowerCase();
    final physicalExamDischargeText =
        (normalized == 'otros' && physicalExamDetails.isNotEmpty)
            ? '$physicalExamDischarge ($physicalExamDetails)'
            : physicalExamDischarge;

    final nextControlRaw = clinicalClosure['nextControlDate'];
    DateTime? nextControlDate =
        nextControlRaw is Timestamp
            ? nextControlRaw.toDate()
            : nextControlRaw is String
            ? DateTime.tryParse(nextControlRaw)
            : null;
    final nextControlFormatted =
        nextControlDate != null
            ? DateFormat('dd/MM/yyyy').format(nextControlDate)
            : '';
    final nextControlLocation = clinicalClosure['nextControlLocation'] ?? '';
    final needsAudiology = (clinicalClosure['needsAudiology'] as bool?) == true;
    final needsOphthalmology =
        (clinicalClosure['needsOphthalmology'] as bool?) == true;

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) {
          return [
            // Encabezado
            pw.Center(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                ),
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Resumen de Historia Clínica - Internación Conjunta',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Hospital F. Escardo - Tigre',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Provincia de Buenos Aires',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
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
              padding: const pw.EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 6,
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Recién nacido: ${p.lastName.toUpperCase()} ${p.firstName.toUpperCase()}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Text(
                    'H.Clínica n°: ${dischargeMap['medicalRecordNumber']?.toString() ?? ''}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // Datos de nacimiento
            pw.Text(
              'Fecha de Nacimiento: $birthDateStr   Hora de Nacimiento: $birthTime Hs.',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Lugar de Nacimiento: $placeOfBirth',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Sexo: $sex   Gemelar: $twin',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Tipo: $birthType   Presentación: $presentation   Rotura de membranas: $ruptureOfMembrane   Líquido amniótico: $amnioticFluid',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),

            // Tabla de datos de nacimiento
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
                        'Edad gestacional: $gestationalAge semanas',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Grupo y factor de la madre: $bloodType',
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
                        'Peso: $birthWeight gramos',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Grupo y factor del RN: $babyBloodType',
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
                        'Talla: $length cm',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'PCD: Negativa',
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
                        'Perímetro cefálico: $headCircumference cm',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Apgar: $apgarScore',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            // Ex. físico al nacer
            pw.Text(
              'Ex. físico al nacer: $physicalExamBirth',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),

            // Vacunas y datos maternos
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Vacunas y estudios
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Vacunas y estudios complementarios:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '- FEI: cartón N° $feiRecordNumber',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Fecha realización: $feiDateFormatted',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Evaluación oftalmológica - Fondo de ojo: Pendiente - Evaluación al alta',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Evaluación audiológica: Pendiente - Evaluación al alta',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Test de saturación pre-ductal: $preDuctal',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Test de saturación post-ductal: $postDuctal',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Vacuna BCG: $bcgApplied    Hepatitis B: $hepBVaccine',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Profilaxis Vitamina K 1 mg: $vitK',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Colirio profiláctico en ambos ojos: $ophthDrops',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Datos al alta:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '- Fecha de alta: $dischargeDateFormatted',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Días de vida: $diasVida',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Peso al alta: $dischargeWeight gramos',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Descenso de peso: ${descensoPeso.toStringAsFixed(1)} %',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Alimentación: $feedingAtDischarge2',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '- Ex. físico al alta: $physicalExamDischargeText',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 8),
                    ],
                  ),
                ),
                pw.SizedBox(width: 12),
                // Datos maternos
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
                        pw.Container(
                          color: PdfColors.grey300,
                          padding: const pw.EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 6,
                          ),
                          child: pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  'Madre: ${motherName.toUpperCase()}',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.Text(
                                'DNI: $motherDni',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 3,
                              child: pw.Text(
                                'Edad: $motherAge años',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              flex: 3,
                              child: pw.Text(
                                'Localidad: $motherLocality',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                'G: $gravidity',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                'P: $parity',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                'C: $cesareans',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                'A: $abortions',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Serologías maternas:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Table(
                          border: pw.TableBorder.all(
                            color: PdfColors.black,
                            width: .5,
                          ),
                          columnWidths: {
                            0: const pw.FlexColumnWidth(1),
                            1: const pw.FlexColumnWidth(1),
                          },
                          children: _buildSerologiaRows(testResults, testDates),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Indicaciones
            pw.Container(
              color: PdfColors.grey300,
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Center(
                child: pw.Text(
                  'INDICACIONES',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Bullet(
              text: 'Alimentación al alta: $feedingAtDischarge2',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Bullet(
              text: 'Vitamina ACD 0,3 ml vía oral (todos los días).',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Bullet(
              text:
                  'Retirar resultados pendientes de FEI en oficina de alta conjunta a los 30 días de vida en los siguientes horarios: Lunes a viernes de 8 a 17 hs. Sábado, Domingos y Feriados de 8 a 16 hs.',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 12),

            // Turnos a solicitar
            pw.Text(
              'Turnos a solicitar en oficina de alta conjunta',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '1- Solicitar turno para: $nextControlFormatted en $nextControlLocation',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              '2- ¿Solicitar turno para OEA?: ${needsAudiology ? 'Sí' : 'No'}',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              '3- ¿Solicitar turno para oftalmología?: ${needsOphthalmology ? 'Sí' : 'No'}',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 12),

            // Información final
            pw.Text(
              '¿CUÁNDO CONSULTAR EN LA GUARDIA?',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Fiebre (temperatura axilar > 37,8°C), dificultad para respirar, agitación, '
              'marca las costillas, aleteo nasal, coloración azulada o amarilla de piel o mucosas, '
              'falta de orina, mucosas secas, irritabilidad, somnolencia, movimientos anormales.',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),

            pw.Text(
              'PAUTAS DE SUEÑO SEGURO',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Dormir boca arriba, en su propia cuna, sin almohada, colchón firme, tapado hasta tórax dejando brazo afuera, '
              'ambiente ventilado, NO FUMAR.',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),

            pw.Text(
              'CUIDADOS DEL CORDÓN UMBILICAL',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'El cordón umbilical se seca y se cae solo 1 o 2 semanas después del nacimiento.\n'
              'Hasta ese momento, debes cuidarlo una vez por día:',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),
            pw.Bullet(
              text:
                  'Lavate bien las manos con agua y jabón, y pasá suavemente por la zona una gasa con agua limpia. '
                  'Después tirala, no la dejes sobre el cordón. Tampoco tapes el cordón con el pañal, no uses "ombligueras", ni fajes al bebé.',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Bullet(
              text:
                  'Antes de la caída del cordón umbilical te recomendamos no darle baños de inmersión, porque podría retrasar su secado y caída. '
                  'Durante ese período tiempo higienizalo por partes y limpia el cordón con agua y gasa solamente.',
              style: pw.TextStyle(fontSize: 10),
            ),

            pw.SizedBox(height: 24),

            // Pie de página
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Dr./Dra. $doctorName',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'M.P.: $doctorProvReg',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Epicrisis_${p.lastName}_${p.firstName}_${p.dni}.pdf',
    );
  }

  static List<pw.TableRow> _buildSerologiaRows(
    Map<String, dynamic> results,
    Map<String, dynamic> dates,
  ) {
    final keys = <String>[
      'VDRL',
      'Chagas',
      'HIV',
      'Toxo IgG',
      'Hepatitis B',
      'Toxo IgM',
      'EGB',
      'TPHA',
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
                key2.isNotEmpty
                    ? '$key2: $res2${date2 != '' ? '  $date2' : ''}'
                    : '',
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
