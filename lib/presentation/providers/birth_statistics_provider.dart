// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikum/entities/birth_data.dart';
import 'package:sikum/entities/birth_statistics.dart';

final birthStatisticsProvider = FutureProvider<BirthStatistics>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('dischargeDataPatient')
      .get();

  int total = 0;
  int cesareanCount = 0;
  int vaginalCount = 0;
  int forcipalCount = 0;

  Map<String, int> birthsPerMonth = {};
  Map<String, int> birthsPerYear = {};

  final now = DateTime.now();

  for (var doc in snapshot.docs) {
    final data = doc.data();

    if (data.containsKey('birthData') && data['birthData'] != null) {
      try {
        final birthDataMap = Map<String, dynamic>.from(data['birthData']);
        final birthData = BirthData.fromMap(birthDataMap);

        if (birthData.birthDate != null) {
          final date = birthData.birthDate!;
          final isCurrentMonth = date.month == now.month && date.year == now.year;

          if (isCurrentMonth) {
            total++;

            final birthType = birthData.birthType?.toLowerCase().trim();

            if (birthType == 'cesárea' || birthType == 'cesarea') {
              cesareanCount++;
            } else if (birthType == 'vaginal') {
              vaginalCount++;
            } else if (birthType == 'forcipal') {
              forcipalCount++;
            }
          }

          final keyMonth = "${date.year}-${date.month.toString().padLeft(2, '0')}";
          birthsPerMonth[keyMonth] = (birthsPerMonth[keyMonth] ?? 0) + 1;

          final keyYear = date.year.toString();
          birthsPerYear[keyYear] = (birthsPerYear[keyYear] ?? 0) + 1;
        }
      } catch (e) {
        print("Error al procesar birthData: $e");
      }
    }
  }


  return BirthStatistics(
    total: total,
    cesareanCount: cesareanCount,
    vaginalCount: vaginalCount,
    forcipalCount: forcipalCount,
    birthsPerMonth: birthsPerMonth,
    birthsPerYear: birthsPerYear,
  );
});