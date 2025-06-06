abstract class EnumWithValue {
  String getValue(); // Método obligatorio para todos los Enum
}

enum BirthTypeEnum implements EnumWithValue{ 
  Vaginal("Vaginal") ,
  Cesarean ("Cesarea"),
  Forceps("Forcipal"), 
  Unknown("Desconocido");

  final String value;
  const BirthTypeEnum(this.value);
  
  @override
  String getValue() {
    return value;
  }
  }

enum PresentationEnum implements EnumWithValue{
  Cephalic("Cefalica"),
  Breech("Podalica"),
  Unknown("Desconocido");

  final String value;
  const PresentationEnum(this.value);
  
  @override
  String getValue() {
    return value;
  }
  
}

enum RuptureOfMembraneEnum implements EnumWithValue{
  Artificial("Artificial"),
  Spontaneous("Espontanea"), 
  Unknown("Desconocido");

  final String value;
  const RuptureOfMembraneEnum(this.value);

 @override
  String getValue() {
    return value;
  }
  
}

enum AmnioticFluidEnum implements EnumWithValue{
  Clear("Claro"),
  MeconiumStained("Meconial"),
  Hemorrhagic("Hemorragico"),
  Unknown("Desconocido");

  final String value;
  const AmnioticFluidEnum(this.value);
  @override
  String getValue() {
    return value;
  }
  }

  enum SexEnum implements EnumWithValue{
  Female("Femenino"),
  Male("Masculino"),
  Unknown("En estudio");

  final String value;

  const SexEnum(this.value);
  @override
  String getValue() {
    return value;
  }
}


