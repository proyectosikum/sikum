abstract class EnumWithValue {
  String getValue(); // Método obligatorio para todos los Enum
}

enum BirthTypeEnum implements EnumWithValue{
  vaginal("Vaginal") ,
  cesarean ("Cesarea"),
  forceps("Forcipal"),
  unknown("Sin dato");

  final String value;
  const BirthTypeEnum(this.value);

  @override
  String getValue() {
    return value;
  }
  }

enum PresentationEnum implements EnumWithValue{
  cephalic("Cefalica"),
  breech("Podalica"),
  unknown("Sin dato");

  final String value;
  const PresentationEnum(this.value);

  @override
  String getValue() {
    return value;
  }

}

enum RuptureOfMembraneEnum implements EnumWithValue{
  atificial("Artificial"),
  spontaneous("Espontanea"),
  unknown("Sin dato");

  final String value;
  const RuptureOfMembraneEnum(this.value);

 @override
  String getValue() {
    return value;
  }

}

enum AmnioticFluidEnum implements EnumWithValue{
  clear("Claro"),
  meconiumStained("Meconial"),
  hemorrhagic("Hemorragico"),
  unknown("Sin dato");

  final String value;
  const AmnioticFluidEnum(this.value);
  @override
  String getValue() {
    return value;
  }
  }

  enum SexEnum implements EnumWithValue{
  female("Femenino"),
  male("Masculino"),
  inProcess("En estudio");

  final String value;

  const SexEnum(this.value);
  @override
  String getValue() {
    return value;
  }
}

enum TwinEnum implements EnumWithValue{

no('No'),
twin1('Gemelar °1'),
twin2('Gemelar °2'),
twin3('Gemelar °3');

  final String value;

  const TwinEnum(this.value);
  @override
  String getValue() {
    return value;
  }

}

enum ApgarScoreEnum implements EnumWithValue{

one('1'),
two('2'),
three('3'),
four('4'),
five('5'),
six('6'),
seven('7'),
eigth('8'),
nine('9'),
ten('10'),
vigorous('VIGOROSO');


  final String value;

  const ApgarScoreEnum(this.value);
  @override
  String getValue() {
    return value;
  }

}

enum DispositionEnum implements EnumWithValue{

  roomingInHospitalization('Internacion Conjunta'),
  ucin('UCIN'),
  intermediateCare('Cuidados Intermedios'),
  minimalCare('Cuidados minimos'),
  middle('El medio'),
  isolation('Aislamiento'),
  hospitalDischarge('Egreso Hospitalario'),
  neonatalDeath('Obito en sala de partos');

  final String value;
  const DispositionEnum(this.value);

  @override
  String getValue() {
    return value;
  }

}

enum PlacesEnum implements EnumWithValue{

  thisHospital('Hospital F.Escardo (Tigre)'),
  outpatient('Extra hospitalario');

  final String value;
  const PlacesEnum(this.value);

  @override
  String getValue() {
    return value;
  }

}

enum BloodTypeEnum implements EnumWithValue{

    positiveA('A+'),
    negativeA('A-'),
    positiveB('B+'),
    negativeB('B-'),
    positiveAB('AB+'),
    negativeAB('AB-'),
    positive('0+'),
    negative('0-'),
    pendingResult('Resultado pendiente');

      final String value;
      const BloodTypeEnum(this.value);

      @override
      String getValue() {
        return value;
      }



}


