String getSpecialtyDisplayName(String key) {
  switch (key) {
    case 'enfermeria': return 'Enfermería';
    case 'enfermeria_fei': return 'Enfermería FEI';
    case 'enfermeria_test_saturacion': return 'Enfermería Test Saturación';
    case 'enfermeria_cambio_pulsera': return 'Enfermería cambio de pulsera';
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