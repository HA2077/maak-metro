/// Splits an ISO date into day, month and year. Null when it is not one.
({int day, int month, int year})? splitIsoDate(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length != 3) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return null;
  if (month < 1 || month > 12) return null;
  if (day < 1 || day > 31) return null;
  return (day: day, month: month, year: year);
}

/// True during the overnight closure window, from 12:15 AM up to 5:15 AM.
bool isMetroClosed({DateTime? now}) {
  final time = now ?? DateTime.now();
  final minutes = time.hour * 60 + time.minute;
  return minutes >= 15 && minutes < 5 * 60 + 15;
}
