/// 2026-03-27 becomes 27-03-2026: dates in this app read day first. Anything
/// that is not a plain ISO date is returned unchanged.
String dayFirstDate(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length != 3) return isoDate;
  return '${parts[2]}-${parts[1]}-${parts[0]}';
}
