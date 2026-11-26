import 'package:maak_metro/core/l10n/app_localizations.dart';

import 'dates.dart';

/// Parts of the day used by the greeting on the planner.
enum DayPart { morning, afternoon, evening, night }

/// Morning 05–11, afternoon 12–16, evening 17–21, night 22–04.
DayPart dayPartFor(int hour) {
  if (hour >= 5 && hour < 12) return DayPart.morning;
  if (hour >= 12 && hour < 17) return DayPart.afternoon;
  if (hour >= 17 && hour < 22) return DayPart.evening;
  return DayPart.night;
}

/// Four greetings per part of the day. The caller picks one per launch.
///
/// Empty during closed hours so the planner can hide the greeting instead of
/// contradicting the closed-hours advisory.
List<String> greetingsFor(
  AppLocalizations l10n,
  DayPart part, {
  DateTime? now,
}) {
  if (isMetroClosed(now: now)) return const <String>[];
  return switch (part) {
    DayPart.morning => [
      l10n.greetingMorning1,
      l10n.greetingMorning2,
      l10n.greetingMorning3,
      l10n.greetingMorning4,
    ],
    DayPart.afternoon => [
      l10n.greetingAfternoon1,
      l10n.greetingAfternoon2,
      l10n.greetingAfternoon3,
      l10n.greetingAfternoon4,
    ],
    DayPart.evening => [
      l10n.greetingEvening1,
      l10n.greetingEvening2,
      l10n.greetingEvening3,
      l10n.greetingEvening4,
    ],
    DayPart.night => [
      l10n.greetingNight1,
      l10n.greetingNight2,
      l10n.greetingNight3,
      l10n.greetingNight4,
    ],
  };
}
