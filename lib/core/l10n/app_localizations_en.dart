// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Maak Metro';

  @override
  String get tabPlanner => 'Planner';

  @override
  String get tabLines => 'Lines';

  @override
  String get tabLibrary => 'Saved';

  @override
  String get tabSettings => 'Settings';

  @override
  String get plannerTitle => 'Plan your trip';

  @override
  String get plannerHint =>
      'Pick your start and destination to see the best route';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get selectStation => 'Choose a station';

  @override
  String get searchStations => 'Search by station name';

  @override
  String get noStationsFound => 'No station matches that name';

  @override
  String get swapStations => 'Swap stations';

  @override
  String get findRoute => 'Show route';

  @override
  String get sameStationError => 'Start and destination are the same station';

  @override
  String get noRouteError => 'No route between these stations';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get routeTitle => 'Route';

  @override
  String estimatedTime(String minutes) {
    return 'About $minutes min';
  }

  @override
  String stationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stations',
      one: '1 station',
      zero: 'No stations',
    );
    return '$_temp0';
  }

  @override
  String transfersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes',
      one: '1 change',
      zero: 'No line changes',
    );
    return '$_temp0';
  }

  @override
  String fareEgp(String price) {
    return 'EGP $price';
  }

  @override
  String changeTo(String line, String station) {
    return 'Change to $line at $station';
  }

  @override
  String legFromTo(String from, String to) {
    return 'From $from to $to';
  }

  @override
  String intermediateStations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops in between',
      one: '1 stop in between',
      zero: 'No stops in between',
    );
    return '$_temp0';
  }

  @override
  String get linesTitle => 'Lines and stations';

  @override
  String branchLabel(String name) {
    return '$name';
  }

  @override
  String get stationDetails => 'Station';

  @override
  String get servesLines => 'Served by';

  @override
  String get setAsFrom => 'Start here';

  @override
  String get setAsTo => 'Go here';

  @override
  String get libraryTitle => 'Saved';

  @override
  String get favorites => 'Favorites';

  @override
  String get history => 'History';

  @override
  String get noFavorites => 'No favorite routes yet';

  @override
  String get noHistory => 'No search history yet';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get clearHistoryConfirm =>
      'Every search in the history will be removed. Are you sure?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get planTrip => 'Plan a trip';

  @override
  String get close => 'Close';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get about => 'About';

  @override
  String dataSnapshot(String date) {
    return 'Data snapshot $date';
  }

  @override
  String fareEffective(String date) {
    return 'Fare effective $date';
  }

  @override
  String get loadError => 'Couldn\'t load the network data';

  @override
  String get retry => 'Try again';
}
