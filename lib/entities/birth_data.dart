class BirthData{

  String birthType;
  String presentation;
  String ruptureOfMembrane;
  String amnioticFluid;
  String sex;
  

BirthData({
  required this.birthType,
  required this.presentation,
  required this.ruptureOfMembrane,
  required this.amnioticFluid,
  required this.sex,
  
});

  BirthData copyWith({
    String? birthType,
    String? presentation,
    String? ruptureOfMembrane,
    String? amnioticFluid,
    String? sex,
    
    }) { 
    return BirthData(
    birthType: birthType ?? this.birthType,
    presentation: presentation?? this.presentation,
    ruptureOfMembrane: ruptureOfMembrane ?? this.ruptureOfMembrane,
    amnioticFluid: amnioticFluid?? this.amnioticFluid,
    sex: sex?? this.sex,
    
    );
  }

   Map<String, dynamic> toMap() {
    return {
      'birthType': birthType,
      'presentation': presentation,
      'ruptureOfMembrane':ruptureOfMembrane,
      'amnioticFluid':amnioticFluid,
      'sex':sex,
      
    };
  }

  factory BirthData.fromMap(Map<String, dynamic> map) {
    return BirthData(
      birthType: map['birthType'],
      presentation: map['presentation'],
      ruptureOfMembrane: map['ruptureOfMembrane'],
      amnioticFluid: map['amnioticFluid'],
      sex: map['sex'],
    );
  }

}