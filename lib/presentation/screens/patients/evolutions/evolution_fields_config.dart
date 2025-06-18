enum FieldType { text, number, checkbox, radio, multiline, datetime }

class FieldConfig {
  final String key;
  final String label;
  final FieldType type;
  final List<String>? options;
  final bool isRequired;
  final num? min;
  final num? max;

  const FieldConfig({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.isRequired = false,
    this.min,
    this.max,
  });
}

const Map<String, List<FieldConfig>> evolutionFormConfig = {
  'enfermeria': [
    FieldConfig(
      key: 'temperature',
      label: 'Temperatura (°C)',
      type: FieldType.number,
      isRequired: true,
      min: 35,
      max: 40,
    ),
    FieldConfig(
      key: 'respiratory',
      label: 'Frecuencia respiratoria (resp/min)',
      type: FieldType.number,
      isRequired: true,
      min: 30,
      max: 100,
    ),
    FieldConfig(
      key: 'cardiac',
      label: 'Frecuencia cardíaca (lat/min)',
      type: FieldType.number,
      isRequired: true,
      min: 60,
      max: 200,
    ),
    FieldConfig(
      key: 'weight',
      label: 'Peso (gr)',
      type: FieldType.number,
      isRequired: true,
      min: 1900,
      max: 6000,
    ),
    FieldConfig(
      key: 'diuresis',
      label: 'Diuresis',
      type: FieldType.radio,
      options: ['Negativo', 'Positivo'],
      isRequired: true,
    ),
    FieldConfig(
      key: 'catarsis',
      label: 'Catarsis',
      type: FieldType.radio,
      options: ['Negativo', 'Positivo'],
      isRequired: true,
    ),
    FieldConfig(
      key: 'bilirubin',
      label: 'Bilirrubina',
      type: FieldType.radio,
      options: ['No', 'Sí'],
      isRequired: true,
    ),
    FieldConfig(
      key: 'observations',
      label: 'Observaciones',
      type: FieldType.multiline,
    ),
  ],

  'enfermeria_fei': [
    FieldConfig(
      key: 'feiDate',
      label: 'Fecha *',
      type: FieldType.datetime,
      isRequired: true,
    ),
    FieldConfig(
      key: 'recordNumber',
      label: 'Número de cartón *',
      type: FieldType.number,
      isRequired: true,
    ),
  ],

  'enfermeria_test_saturacion': [
    FieldConfig(
      key: 'preDuctalOxygenSaturation',
      label: 'Saturación pre ductal',
      type: FieldType.number,
      isRequired: true,
      min: 0,
      max: 100,
    ),
    FieldConfig(
      key: 'postDuctalOxygenSaturation',
      label: 'Saturación post ductal',
      type: FieldType.number,
      isRequired: true,
      min: 0,
      max: 100,
    ),
  ],

  'enfermeria_cambio_pulsera': [
    FieldConfig(
      key: 'braceletNumberNew',
      label: 'Nuevo número de pulsera',
      type: FieldType.number,
      isRequired: true,
    ),
  ],

  'vacunatorio': [
    FieldConfig(
      key: 'bcg',
      label: 'Se aplicó la BCG',
      type: FieldType.checkbox,
      isRequired: true,
    ),
    FieldConfig(
      key: 'observations',
      label: 'Observaciones',
      type: FieldType.multiline,
    ),
  ],

  'fonoaudiologia': [
    FieldConfig(
      key: 'leftOAE',
      label: 'OEA – Oído izquierdo',
      type: FieldType.radio,
      options: ['Pasa', 'No pasa'],
      isRequired: true,
    ),
    FieldConfig(
      key: 'rightOAE',
      label: 'OEA – Oído derecho',
      type: FieldType.radio,
      options: ['Pasa', 'No pasa'],
      isRequired: true,
    ),
    FieldConfig(
      key: 'indications',
      label: 'Indicaciones',
      type: FieldType.multiline,
    ),
    FieldConfig(
      key: 'observations',
      label: 'Observaciones',
      type: FieldType.multiline,
    ),
  ],

  'puericultura': [
    FieldConfig(
      key: 'observations',
      label: 'Observaciones',
      type: FieldType.multiline,
    ),
  ],

  'servicio_social': [
    FieldConfig(
      key: 'observations',
      label: 'Observaciones',
      type: FieldType.multiline,
    ),
  ],

  'interconsultor': [
    FieldConfig(
      key: 'interSpec',
      label: 'Especialidad interconsultor',
      type: FieldType.text,
      isRequired: true,
    ),
    FieldConfig(
      key: 'observations',
      label: 'Observaciones',
      type: FieldType.multiline,
    ),
  ],

  'neonatologia': [],

  'neonatologia_adicional': [
    FieldConfig(key: 'comment', label: 'Comentario', type: FieldType.text),
    FieldConfig(
      key: 'indications',
      label: 'Indicaciones',
      type: FieldType.text,
      isRequired: true,
    ),
  ],
};

const List<FieldConfig> neonatologyPage1 = [
  FieldConfig(
    key: 'physicalExam',
    label: 'Examen físico',
    type: FieldType.radio,
    options: ['Normal', 'Anormal'],
    isRequired: true,
  ),
  FieldConfig(
    key: 'abnormalObservation',
    label: '¿Qué observo?',
    type: FieldType.multiline,
    isRequired: true,
  ),
  FieldConfig(
    key: 'jaundice',
    label: 'Ictericia',
    type: FieldType.radio,
    options: ['Negativo', 'Positivo'],
    isRequired: true,
  ),
  FieldConfig(
    key: 'diuresis',
    label: 'Diuresis',
    type: FieldType.radio,
    options: ['Negativo', 'Positivo'],
    isRequired: true,
  ),
  FieldConfig(
    key: 'catarsis',
    label: 'Catarsis',
    type: FieldType.radio,
    options: ['Negativo', 'Positivo'],
    isRequired: true,
  ),
  FieldConfig(
    key: 'feeding',
    label: 'Lactancia',
    type: FieldType.radio,
    options: ['OK', 'Dificultosa', 'Contraindicada'],
    isRequired: true,
  ),
  FieldConfig(
    key: 'inCrib',
    label: 'Está en cuna',
    type: FieldType.checkbox,
    isRequired: true,
  ),
  FieldConfig(
    key: 'dressed',
    label: 'Está vestido',
    type: FieldType.checkbox,
    isRequired: true,
  ),
];

const List<FieldConfig> neonatologyPage2 = [
  FieldConfig(
    key: 'pmld',
    label: 'PMLD',
    type: FieldType.checkbox,
    isRequired: true,
  ),
  FieldConfig(
    key: 'csvByShift',
    label: 'CSV por turno',
    type: FieldType.checkbox,
    isRequired: true,
  ),
  FieldConfig(
    key: 'feedingPmld',
    label: 'PMLD',
    type: FieldType.checkbox,
    isRequired: true,
  ),
  FieldConfig(
    key: 'feedingPmldComplement',
    label: 'PMLD + complemento',
    type: FieldType.checkbox,
    isRequired: true,
  ),
  FieldConfig(
    key: 'feedingMlQuantity',
    label: 'Cantidad de ML/3hs',
    type: FieldType.number,
    isRequired: true,
  ),
  FieldConfig(
    key: 'lf',
    label: 'LF',
    type: FieldType.checkbox,
    isRequired: true,
  ),
  FieldConfig(
    key: 'lfMlQuantity',
    label: 'Cantidad de ML/3hs',
    type: FieldType.number,
    isRequired: true,
  ),
  FieldConfig(
    key: 'phototherapy',
    label: 'Luminoterapia',
    type: FieldType.radio,
    options: ['No', 'Sí'],
    isRequired: true,
  ),
  FieldConfig(
    key: 'medication',
    label: 'Medicación',
    type: FieldType.multiline,
  ),
  FieldConfig(
    key: 'observations',
    label: 'Observaciones',
    type: FieldType.multiline,
  ),
];
