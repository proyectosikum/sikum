class BirthStatistics {
  final int total;
  final Map<String, int> birthsPerMonth;
  final int cesareanCount;
  final int vaginalCount;

  BirthStatistics({
    required this.total,
    required this.birthsPerMonth,
    required this.cesareanCount,
    required this.vaginalCount,
  });
}