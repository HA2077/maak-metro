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
  String get fare => 'Fare';

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
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get about => 'About';

  @override
  String get loadError => 'Couldn\'t load the network data';

  @override
  String get retry => 'Try again';

  @override
  String get interchanges => 'Interchanges';

  @override
  String get close => 'Close';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get greetingMorning1 => 'Good morning, ready for the trip?';

  @override
  String get greetingMorning2 => 'Morning! Where are you headed today?';

  @override
  String get greetingMorning3 => 'Morning! Your trip starts right here';

  @override
  String get greetingMorning4 =>
      'Good morning, pick two stations and we handle the rest';

  @override
  String get greetingAfternoon1 => 'Good afternoon, where shall we start?';

  @override
  String get greetingAfternoon2 => 'Welcome back, your trip is two taps away';

  @override
  String get greetingAfternoon3 =>
      'Good afternoon, where\'s your station today?';

  @override
  String get greetingAfternoon4 => 'Hi there, let\'s make this trip easier';

  @override
  String get greetingEvening1 => 'Good evening, your trip is in your hands';

  @override
  String get greetingEvening2 => 'Evening! Pick a station and let\'s go';

  @override
  String get greetingEvening3 => 'Good evening, where to after work?';

  @override
  String get greetingEvening4 => 'Evening, plan your trip in a second';

  @override
  String get greetingNight1 => 'Late night? The last train is waiting';

  @override
  String get greetingNight2 => 'Still up? Pick your station quickly';

  @override
  String get greetingNight3 => 'Quiet night — where are you off to?';

  @override
  String get greetingNight4 => 'Late night, your trip still needs a plan';

  @override
  String get dataSnapshotTitle => 'Data snapshot';

  @override
  String get fareEffectiveTitle => 'Fare effective';

  @override
  String get planTrip => 'Plan a trip';

  @override
  String changeAt(String station) {
    return 'Change lines at $station';
  }
}
