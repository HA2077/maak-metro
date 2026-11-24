/// Normalises a user-typed station name so that spelling variants of Arabic
/// and the casing of English match each other.
///
/// The picker runs both the query and the station names through
/// [normalizeSearch] and then asks whether the query is contained in the name.
/// Keeping the rules in one pure function means the search behaves the same in
/// every screen and can be unit tested without a widget.
///
/// Rules, in order:
/// 1. Lower case (affects Latin only).
/// 2. Remove Arabic diacritics U+064B..U+0652 and the superscript alef U+0670.
/// 3. Remove tatweel U+0640.
/// 4. Unify alef forms: أ إ آ ٱ -> ا.
/// 5. Unify ta marbuta ة -> ه.
/// 6. Unify alef maqsura ى -> ي.
/// 7. Trim and collapse runs of whitespace to a single space.
///
/// Hamza (ء) and the hamza carriers ئ / ؤ are intentionally kept: merging them
/// would make "سؤال" and "سوال" the same word only by luck of the station list.
String normalizeSearch(String input) {
  final buffer = StringBuffer();

  for (final rune in input.runes) {
    // 1. Arabic diacritics (fathatan .. sukun) and the superscript alef.
    if ((rune >= 0x064B && rune <= 0x0652) || rune == 0x0670) {
      continue;
    }

    // 3. Tatweel (kashida) carries no meaning in a search query.
    if (rune == 0x0640) {
      continue;
    }

    // 4. Alef with hamza above / below, alef with madda, alef wasla -> alef.
    if (rune == 0x0623 || rune == 0x0625 || rune == 0x0622 || rune == 0x0671) {
      buffer.writeCharCode(0x0627);
      continue;
    }

    // 5. Ta marbuta -> ha.
    if (rune == 0x0629) {
      buffer.writeCharCode(0x0647);
      continue;
    }

    // 6. Alef maqsura -> ya.
    if (rune == 0x0649) {
      buffer.writeCharCode(0x064A);
      continue;
    }

    buffer.writeCharCode(rune);
  }

  // 1 + 7. Lower case, trim, collapse internal whitespace.
  final collapsed = buffer.toString().toLowerCase().trim();
  return collapsed.replaceAll(RegExp(r'\s+'), ' ');
}

/// Whether [query] matches [name] after normalising both.
///
/// An empty query matches everything, so an untouched search field lists the
/// whole station list.
bool stationMatchesQuery(String name, String query) {
  final normalizedQuery = normalizeSearch(query);
  if (normalizedQuery.isEmpty) {
    return true;
  }
  return normalizeSearch(name).contains(normalizedQuery);
}
