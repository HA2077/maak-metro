import 'package:flutter/widgets.dart';

import 'package:maak_metro/features/network/domain/models/models.dart';

String _languageCode(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

/// The station name in the active language.
String stationName(BuildContext context, Station station) =>
    _languageCode(context) == 'ar' ? station.nameAr : station.nameEn;

/// The same station in the other language, used as the picker subtitle.
String otherStationName(BuildContext context, Station station) =>
    _languageCode(context) == 'ar' ? station.nameEn : station.nameAr;

String lineName(BuildContext context, Line line) =>
    _languageCode(context) == 'ar' ? line.nameAr : line.nameEn;

String stationNameById(BuildContext context, NetworkData data, String id) {
  final station = data.stationById(id);
  return station == null ? id : stationName(context, station);
}
