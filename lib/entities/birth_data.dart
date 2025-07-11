// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

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
  DateTime? birthDate;
  String? birthTime;
  int? weight;
  int? length; 
  int? headCircumference;
  String? physicalExamination;
  String? physicalExaminationDetails;
  String? birthPlace;
  String? birthPlaceDetails;
  int? braceletNumber;
  String? bloodType;
  bool isDataSaved;

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
  this.birthDate,
  this.birthTime,
  this.weight,
  this.length,
  this.headCircumference,
  this.physicalExamination,
  this.physicalExaminationDetails,
  this.birthPlace,
  this.birthPlaceDetails,
  this.braceletNumber,
  this.bloodType,
  this.isDataSaved = false,
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
    int? gestationalAge,
    DateTime? birthDate,
    String? birthTime,
    int? weight, 
    int? length,
    int? headCircumference,
    String? physicalExamination,
    String? physicalExaminationDetails,
    String? birthPlace,
    String? birthPlaceDetails,
    int? braceletNumber,
    String? bloodType,
    bool? isDataSaved,
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
    gestationalAge : gestationalAge?? this.gestationalAge,
    birthDate: birthDate ?? this.birthDate,
    birthTime: birthTime ?? this.birthTime,
    weight: weight?? this.weight,
    length: length?? this.length,
    headCircumference: headCircumference??this.headCircumference,
    physicalExamination: physicalExamination ?? this.physicalExamination,
    physicalExaminationDetails: physicalExaminationDetails ?? this.physicalExaminationDetails,
    birthPlace: birthPlace ?? this.birthPlace,
    birthPlaceDetails: birthPlaceDetails ?? this.birthPlaceDetails,
    braceletNumber: braceletNumber?? this.braceletNumber,
    bloodType: bloodType ?? this.bloodType,
    isDataSaved: isDataSaved ?? this.isDataSaved
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
      'gestationalAge': gestationalAge,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'birthTime': birthTime,
      'weight': weight,
      'length': length,
      'headCircumference': headCircumference,
      'physicalExamination': physicalExamination,
      'physicalExaminationDetails': physicalExaminationDetails,
      'birthPlace': birthPlace,
      'birthPlaceDetails':birthPlaceDetails,
      'braceletNumber': braceletNumber,
      'bloodType': bloodType,
      'isDataSaved': isDataSaved
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
      thirdApgarScore: map['thirdApgarScore'] ,
      hasHepatitisBVaccine: map['hasHepatitisBVaccine'] ?? false,
      hasVitaminK: map['hasVitaminK'] ?? false,
      hasOphthalmicDrops: map['hasOphthalmicDrops']?? false,
      disposition: map['disposition'],
      gestationalAge: map['gestationalAge'],
      birthDate:  map['birthDate']?.toDate(), 
      birthTime: map['birthTime'],
      weight: map['weight'] ,
      length: map['length'],
      headCircumference: map['headCircumference'],
      physicalExamination: map['physicalExamination'],
      physicalExaminationDetails: map['physicalExaminationDetails'], 
      birthPlace: map['birthPlace'] ,
      birthPlaceDetails: map['birthPlaceDetails'],
      braceletNumber: map['braceletNumber'],
      bloodType: map['bloodType'],
      isDataSaved: map['isDataSaved'] ?? false,
    );
  }


  @override
String toString() {
  return '''
  BirthData {
    birthType: $birthType,
    presentation: $presentation,
    ruptureOfMembrane: $ruptureOfMembrane,
    amnioticFluid: $amnioticFluid,
    sex: $sex,
    twin: $twin,
    disposition: $disposition,
    physicalExamination: $physicalExamination,
    physicalExaminationDetails: $physicalExaminationDetails,
    birthPlace: $birthPlace,
    birthPlaceDetails: $birthPlaceDetails,
    braceletNumber: $braceletNumber,
    birthDate: $birthDate,
    birthTime: $birthTime,
    weight: $weight,
    length: $length,
    headCircumference: $headCircumference,
    bloodType: $bloodType,
    isDataSaved: $isDataSaved,
  }
  ''';
}

}