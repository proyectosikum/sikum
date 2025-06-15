String getSpecialtyDisplayName(String specialty) {
  return specialty.isNotEmpty
      ? specialty
          .replaceAll('_', ' ')
          .toLowerCase()
          .replaceFirst(
            specialty.replaceAll('_', ' ').toLowerCase()[0],
            specialty.replaceAll('_', ' ').toLowerCase()[0].toUpperCase(),
          )
      : specialty;
}
