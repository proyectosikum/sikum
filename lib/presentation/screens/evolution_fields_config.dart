enum FieldType { text, number, checkbox, radio, multiline }

class FieldConfig {
  final String key;
  final String label;
  final FieldType type;
  final List<String>? options;

  const FieldConfig({
    required this.key,
    required this.label,
    required this.type,
    this.options,
  });
}

/// Mapa: especialidad -> lista de campos
const Map<String, List<FieldConfig>> evolutionFormConfig = {
  // Enfermería / general
  'enfermeria': [
    FieldConfig(key: 'temperature',  label: 'Temperatura (°C)',        type: FieldType.number),
    FieldConfig(key: 'respiratory',  label: 'Frecuencia respiratoria (resp/min)', type: FieldType.number),
    FieldConfig(key: 'cardiac',      label: 'Frecuencia cardíaca (lat/min)',      type: FieldType.number),
    FieldConfig(key: 'weight',       label: 'Peso (gr)',                type: FieldType.number),
    FieldConfig(key: 'diuresis',     label: 'Diuresis',                 type: FieldType.radio,   options: ['Negativo', 'Positivo']),
    FieldConfig(key: 'catarsis',     label: 'Catarsis',                 type: FieldType.radio,   options: ['Negativo', 'Positivo']),
    FieldConfig(key: 'bilirubin',    label: 'Bilirrubina',              type: FieldType.radio,   options: ['No', 'Sí']),
    FieldConfig(key: 'observations', label: 'Observaciones',            type: FieldType.multiline),
  ],

  // Vacunatorio
  'vacunatorio': [
    FieldConfig(key: 'bcg',          label: 'Se aplicó la BCG',         type: FieldType.checkbox),
    FieldConfig(key: 'observations', label: 'Observaciones',            type: FieldType.multiline),
  ],

  // Fonoaudiología
  'fonoaudiologia': [
    FieldConfig(key: 'leftOAE',      label: 'OEA – Oído izquierdo',     type: FieldType.radio,   options: ['Pasa', 'No pasa']),
    FieldConfig(key: 'rightOAE',     label: 'OEA – Oído derecho',       type: FieldType.radio,   options: ['Pasa', 'No pasa']),
    FieldConfig(key: 'indications',  label: 'Indicaciones',             type: FieldType.multiline),
    FieldConfig(key: 'observations', label: 'Observaciones',            type: FieldType.multiline),
  ],

  // Puericultura
  'puericultura': [
    FieldConfig(key: 'observations', label: 'Observaciones',            type: FieldType.multiline),
  ],

  // Servicio Social
  'servicio social': [
    FieldConfig(key: 'observations', label: 'Observaciones',            type: FieldType.multiline),
  ],

  // Interconsultor (campo libre de especialidad más observaciones)
  'interconsultor': [
    FieldConfig(key: 'interSpec',    label: 'Especialidad interconsultor', type: FieldType.text),
    FieldConfig(key: 'observations', label: 'Observaciones',               type: FieldType.multiline),
  ],

  // Neonatología
  'neonatologia': [],
};

// Neonatology – page 1
const List<FieldConfig> neonatologyPage1 = [
  FieldConfig(
    key: 'physicalExam',
    label: 'Examen físico',
    type: FieldType.radio,
    options: ['Normal', 'Anormal'],
  ),
  FieldConfig(
    key: 'abnormalObservation',
    label: '¿Qué observo?',
    type: FieldType.multiline,
  ),
  FieldConfig(
    key: 'jaundice',
    label: 'Ictericia',
    type: FieldType.radio,
    options: ['Negativo', 'Positivo'],
  ),
  FieldConfig(
    key: 'diuresis',
    label: 'Diuresis',
    type: FieldType.radio,
    options: ['Negativo', 'Positivo'],
  ),
  FieldConfig(
    key: 'catarsis',
    label: 'Catarsis',
    type: FieldType.radio,
    options: ['Negativo', 'Positivo'],
  ),
  FieldConfig(
    key: 'feeding',
    label: 'Lactancia',
    type: FieldType.radio,
    options: ['OK', 'Dificultosa', 'Contraindicada'],
  ),
  FieldConfig(
    key: 'inCrib',
    label: 'Está en cuna',
    type: FieldType.checkbox,
  ),
  FieldConfig(
    key: 'dressed',
    label: 'Está vestido',
    type: FieldType.checkbox,
  ),
];

// Neonatology – page 2
const List<FieldConfig> neonatologyPage2 = [
  // Indicaciones
  FieldConfig(key: 'pmld',                   label: 'PMLD',                         type: FieldType.checkbox),
  FieldConfig(key: 'csvByShift',             label: 'CSV por turno',                type: FieldType.checkbox),

  // Alimentación
  FieldConfig(key: 'feedingPmld',            label: 'PMLD',                         type: FieldType.checkbox),
  FieldConfig(key: 'feedingPmldComplement',  label: 'PMLD + complemento',          type: FieldType.checkbox),
  FieldConfig(key: 'feedingMlQuantity',      label: 'Cantidad de ML/3hs',          type: FieldType.text),

  FieldConfig(key: 'lf',                     label: 'LF',                           type: FieldType.checkbox),
  FieldConfig(key: 'lfMlQuantity',           label: 'Cantidad de ML/3hs',          type: FieldType.text),

  // Resto
  FieldConfig(
    key: 'phototherapy',
    label: 'Luminoterapia',
    type: FieldType.radio,
    options: ['No', 'Sí'],
  ),
  FieldConfig(key: 'medication',             label: 'Medicación',                   type: FieldType.multiline),
  FieldConfig(key: 'observations',    label: 'Observaciones',                type: FieldType.multiline),
];
