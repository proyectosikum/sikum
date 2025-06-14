import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikum/entities/birth_data.dart';
import 'package:sikum/entities/birth_statistics.dart';

final birthStatisticsProvider = FutureProvider<BirthStatistics>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('dischargeDataPatient').get();

  int total = 0;
  int cesareanCount = 0;
  int vaginalCount = 0;
  Map<String, int> birthsPerMonth = {};

  for (var doc in snapshot.docs) {
    final data = doc.data();
    if (data.containsKey('birthData')) {
      final birthData = BirthData.fromMap(data['birthData']);

      if (birthData.birthDate != null) {
        total++;

        final birthType = birthData.birthType?.toLowerCase().trim();
        if (birthType == 'cesárea' || birthType == 'cesarea') cesareanCount++;
        if (birthType == 'vaginal') vaginalCount++;

        final date = birthData.birthDate!;
        final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
        birthsPerMonth[key] = (birthsPerMonth[key] ?? 0) + 1;
      }
    }
  }

  return BirthStatistics(
    total: total,
    birthsPerMonth: birthsPerMonth,
    cesareanCount: cesareanCount,
    vaginalCount: vaginalCount,
  );
});