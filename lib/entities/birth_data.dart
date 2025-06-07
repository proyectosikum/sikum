class BirthData{

  String birthType;
  String presentation;
  String ruptureOfMembrane;
  String amnioticFluid;
  String sex;
  String? twin;
  String? firstApgarScore;
  String? secondApgarScore;
  String? thirdApgarScore;
  

BirthData({
  required this.birthType,
  required this.presentation,
  required this.ruptureOfMembrane,
  required this.amnioticFluid,
  required this.sex,
  this.twin,
  this.firstApgarScore,
  this.secondApgarScore,
  this.thirdApgarScore
});

  BirthData copyWith({
    String? birthType,
    String? presentation,
    String? ruptureOfMembrane,
    String? amnioticFluid,
    String? sex,
    String? twin,
    String? firstApgarScore,
    String? secondApgarScore,
    String? thirdApgarScore,
    }) { 
    return BirthData(
    birthType: birthType ?? this.birthType,
    presentation: presentation?? this.presentation,
    ruptureOfMembrane: ruptureOfMembrane ?? this.ruptureOfMembrane,
    amnioticFluid: amnioticFluid?? this.amnioticFluid,
    sex: sex?? this.sex,
    twin: twin ?? this.twin,
    firstApgarScore: firstApgarScore?? this.firstApgarScore,
    secondApgarScore: secondApgarScore?? this.secondApgarScore,
    thirdApgarScore: thirdApgarScore ?? this.thirdApgarScore,   
    );
  }

   Map<String, dynamic> toMap() {
    return {
      'birthType': birthType,
      'presentation': presentation,
      'ruptureOfMembrane':ruptureOfMembrane,
      'amnioticFluid':amnioticFluid,
      'sex':sex,
      'twin': twin,
      'firstApgarScore': firstApgarScore,
      'secondApgarScore': secondApgarScore,
      'thirdApgarScore': thirdApgarScore
    };
  }

  factory BirthData.fromMap(Map<String, dynamic> map) {
    return BirthData(
      birthType: map['birthType'],
      presentation: map['presentation'],
      ruptureOfMembrane: map['ruptureOfMembrane'],
      amnioticFluid: map['amnioticFluid'],
      sex: map['sex'],
      twin: map['twin'],
      firstApgarScore: map['firstApgarScore'],
      secondApgarScore: map['secondApgarScore'],
      thirdApgarScore: map['thirdApgarScore']
    );
  }

}