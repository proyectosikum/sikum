class BirthData{

  String? birthType;
  String? presentation;
  String? ruptureOfMembrane;
  String? amnioticFluid;
  String? sex;
  String? twin;
  String? firstApgarScore;
  String? secondApgarScore;
  String? thirdApgarScore;
  bool hasHepatitisBVaccine;
  bool hasVitaminK;
  bool hasOphthalmicDrops;
  String? disposition;
  int? gestationalAge;

BirthData({
  this.birthType,
  this.presentation,
  this.ruptureOfMembrane,
  this.amnioticFluid,
  this.sex,
  this.twin,
  this.firstApgarScore,
  this.secondApgarScore,
  this.thirdApgarScore,
  this.hasHepatitisBVaccine =false,
  this.hasVitaminK =false ,
  this.hasOphthalmicDrops =false,
  this.disposition,
  this.gestationalAge,
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
    bool? hasHepatitisBVaccine,
    bool? hasVitaminK,
    bool? hasOphthalmicDrops,
    String? disposition,
    int? gestationalAge
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
    hasHepatitisBVaccine: hasHepatitisBVaccine ?? this.hasHepatitisBVaccine,
    hasVitaminK: hasVitaminK ?? this.hasVitaminK,
    hasOphthalmicDrops: hasOphthalmicDrops ?? this.hasOphthalmicDrops,
    disposition: disposition?? this.disposition ,
    gestationalAge : gestationalAge?? this.gestationalAge
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
      'thirdApgarScore': thirdApgarScore,
      'hasHepatitisBVaccine': hasHepatitisBVaccine,
      'hasVitaminK': hasVitaminK,
      'hasOphthalmicDrops': hasOphthalmicDrops,
      'disposition': disposition, 
      'gestationalAge': gestationalAge
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
      thirdApgarScore: map['thirdApgarScore'],
      hasHepatitisBVaccine: map['hasHepatitisBVaccine'] ?? false,
      hasVitaminK: map['hasVitaminK'] ?? false,
      hasOphthalmicDrops: map['hasOphthalmicDrops']?? false,
      disposition: map['disposition'],
      gestationalAge: map['gestationalAge']      
    );
  }

}