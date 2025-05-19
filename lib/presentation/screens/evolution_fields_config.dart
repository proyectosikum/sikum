// lib/presentation/screens/evolution_fields_config.dart

enum FieldType { text, number, checkbox, radio, multiline }

class FieldConfig {
  final String key;             // clave interna / campo en Firestore
  final String label;           // etiqueta para el usuario
  final FieldType type;
  final List<String>? options;  // para radio

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
    FieldConfig(key: 'respiratory',  label: 'Frecuencia respiratoria', type: FieldType.number),
    FieldConfig(key: 'cardiac',      label: 'Frecuencia cardíaca',      type: FieldType.number),
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

  // Puericultura / Servicio Social
  'puericultura_servsocial': [
    FieldConfig(key: 'observations', label: 'Observaciones',            type: FieldType.multiline),
  ],

  // Interconsultor (campo libre de especialidad más observaciones)
  'interconsultor': [
    FieldConfig(key: 'interSpec',    label: 'Especialidad interconsultor', type: FieldType.text),
    FieldConfig(key: 'observations', label: 'Observaciones',               type: FieldType.multiline),
  ],
};
