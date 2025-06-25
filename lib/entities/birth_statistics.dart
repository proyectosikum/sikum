class BirthStatistics {
  final int total;
  final Map<String, int> birthsPerMonth;
  final int cesareanCount;
  final int vaginalCount;
  final int forcipalCount;
  final Map<String, int> birthsPerYear;

  BirthStatistics({
    required this.total,
    required this.birthsPerMonth,
    required this.cesareanCount,
    required this.vaginalCount,
    required this.forcipalCount,
    required this.birthsPerYear
  });
}