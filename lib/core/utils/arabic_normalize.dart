/// Folds the spelling variants users actually type for Cairo station names:
/// case, extra spaces, Arabic diacritics and tatweel, alef forms, ta marbuta
/// and alef maqsura.
String normalizeSearch(String input) {
  var value = input.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  value = value.replaceAll(RegExp('[\u064B-\u0652\u0640]'), '');
  return value
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي');
}
