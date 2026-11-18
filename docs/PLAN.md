# Maak Metro (معاك): Project Plan

Android Development final project · Flutter + SQLite · Team of 6 · Plan date 11/17/2026 · Feature freeze 11/25 · Presentation 11/28/2026

## 0. Locked decisions

- App: **Maak Metro (معاك)**, offline metro planner for Cairo Metro Lines 1, 2 and 3.
- State management: Provider (`ChangeNotifier` + `MultiProvider`).
- Database: **SQLite via `sqflite`**. Hive was considered and rejected: our data is relational, the team and the DB owner work in SQL, and there is no visible speed or size gain at this data size. The app only talks to `MetroRepository`, so the storage engine can be swapped later by changing `lib/data/` only.
- Default language Arabic (RTL), instant toggle to English.
- Routing constants: `perStopMinutes = 2.5`, `transferPenaltyMinutes = 7.5` (1 transfer = 3 stops).
- Single source of truth: `assets/metro_seed.json`, loaded into SQLite on first run.
- Scope is final: no monorail, GPS, maps, online APIs, accounts or backend. Stretch (only after everything else works): fuzzy Arabic station search, discounted fares, line diagram.
- Data source: the official Cairo Metro website. Snapshot rule: open stations only, as of the snapshot date written into the seed file (confirmation tracked in D-4).

## 1. Seed file format (`assets/metro_seed.json`)

Owner: Abdullah. Reviewers: Hassan and Youssef. The format below is frozen once the repo is live; any change needs a PR that tags everyone.

```json
{
  "version": 1,
  "snapshot_date": "2026-11-18",
  "lines": [
    { "id": 1, "name_ar": "الخط الأول", "name_en": "Line 1", "color_hex": "#1E63B8" }
  ],
  "stations": [
    { "id": "sadat", "name_ar": "السادات", "name_en": "Sadat" }
  ],
  "line_branches": [
    { "line_id": 3, "branch": "rod_el_farag", "starts_after": "kit_kat" },
    { "line_id": 3, "branch": "cairo_uni", "starts_after": "kit_kat" }
  ],
  "line_stations": [
    { "line_id": 1, "station_id": "sadat", "branch": "main", "seq": 18 }
  ],
  "fares": [
    { "max_stations": 9, "price_egp": 10 },
    { "max_stations": 16, "price_egp": 12 },
    { "max_stations": 23, "price_egp": 15 },
    { "max_stations": 39, "price_egp": 20 }
  ]
}
```

Rules:

1. Station `id` is a stable lowercase English slug (`al_shohadaa`, `kit_kat`). Never renamed after the first commit. Both `name_ar` and `name_en` are required and non-empty.
2. An interchange is the same `station_id` appearing in `line_stations` once per line. No special flag. Expected interchanges to verify: Sadat, Al-Shohadaa (Lines 1 and 2), Attaba (Lines 2 and 3), Nasser (Lines 1 and 3). The data decides, not this list.
3. `seq` starts at 1 and is contiguous **per (line_id, branch)**. Stations on Lines 1 and 2 use branch `main` (see D-6).
4. Line 3: `main` runs from Adly Mansour to Kit Kat. Each branch (`rod_el_farag`, `cairo_uni`) starts its own `seq` at 1, and its first station is adjacent to the `starts_after` station. Branch names and station membership are confirmed in D-3.
5. Fares are copied from the official fares page and re-verified before the demo. Never hardcoded in Dart.

## 2. SQLite schema

Owner: Mahmoud. Foreign keys on (`PRAGMA foreign_keys = ON` in `onConfigure`).

```sql
CREATE TABLE lines (id INTEGER PRIMARY KEY, name_ar TEXT NOT NULL, name_en TEXT NOT NULL, color_hex TEXT NOT NULL);
CREATE TABLE stations (id TEXT PRIMARY KEY, name_ar TEXT NOT NULL, name_en TEXT NOT NULL);
CREATE TABLE line_branches (line_id INTEGER NOT NULL REFERENCES lines(id), branch TEXT NOT NULL, starts_after TEXT NOT NULL REFERENCES stations(id), PRIMARY KEY (line_id, branch));
CREATE TABLE line_stations (line_id INTEGER NOT NULL REFERENCES lines(id), station_id TEXT NOT NULL REFERENCES stations(id), branch TEXT NOT NULL, seq INTEGER NOT NULL, PRIMARY KEY (line_id, branch, seq), UNIQUE (line_id, station_id));
CREATE TABLE fares (max_stations INTEGER PRIMARY KEY, price_egp INTEGER NOT NULL);
CREATE TABLE favorites (id INTEGER PRIMARY KEY AUTOINCREMENT, from_id TEXT NOT NULL REFERENCES stations(id), to_id TEXT NOT NULL REFERENCES stations(id), created_at TEXT NOT NULL, UNIQUE (from_id, to_id));
CREATE TABLE history (id INTEGER PRIMARY KEY AUTOINCREMENT, from_id TEXT NOT NULL REFERENCES stations(id), to_id TEXT NOT NULL REFERENCES stations(id), searched_at TEXT NOT NULL);
```

Changes from the first plan: `line_stations` gains `branch` and `seq`, and `line_branches` is new.

Seeding:

1. On first run, read the JSON asset and insert everything in one transaction. If it fails, roll back and show a clear error screen, not a blank app.
2. Store `seed_version` in `shared_preferences`. If the JSON version is higher than the stored one, re-seed the reference tables (`lines`, `stations`, `line_branches`, `line_stations`, `fares`) and leave `favorites` and `history` untouched.
3. History keeps the latest 50 rows; older ones are deleted on insert. Saving the same pair twice as a favorite is a no-op.

## 3. Dart contract (models and repository)

Owner: Hassan. Put in `lib/domain/models/`. **Pure Dart, no Flutter or sqflite imports**, so the router can be tested without a device.

```dart
class Line { final int id; final String nameAr, nameEn, colorHex; }
class Station { final String id, nameAr, nameEn; }
class LineStation { final int lineId; final String stationId, branch; final int seq; }
class LineBranch { final int lineId; final String branch, startsAfter; }
class FareBracket { final int maxStations, priceEgp; }

class NetworkData {
  final List<Line> lines;
  final List<Station> stations;
  final List<LineBranch> branches;
  final List<LineStation> lineStations;
  final List<FareBracket> fares; // sorted ascending by maxStations
}

class RoutingConfig {
  final double perStopMinutes;         // 2.5
  final double transferPenaltyMinutes; // 7.5
}

class RouteLeg { final int lineId; final String branch; final List<String> stationIds; } // ordered, boarding station first

class RouteResult {
  final String fromId, toId;
  final List<RouteLeg> legs;
  final int stationCount;     // stations traveled (rule in section 4)
  final int transfers;        // legs.length - 1
  final double estimatedMinutes;
  final int fareEgp;
}

abstract class MetroRepository {
  Future<NetworkData> loadNetwork();
  Future<List<FavoriteRoute>> getFavorites();
  Future<void> addFavorite(String fromId, String toId);
  Future<void> removeFavorite(int id);
  Future<List<HistoryEntry>> getHistory({int limit = 50});
  Future<void> addHistory(String fromId, String toId);
  Future<void> clearHistory();
}
```

Router entry point, a pure function:

```dart
RouteResult? findRoute({required String fromId, required String toId, required NetworkData data, required RoutingConfig config});
```

It returns `null` when `fromId == toId`, when a station id is unknown, or when no path exists. The provider turns `null` into a friendly message.

## 4. Router design

Owner: Hassan. Tests: Youssef.

**Graph.** Node = `(stationId, lineId)`. Edges:

1. Same-line neighbors: seq `n` and `n+1` within the same (line, branch), cost `perStopMinutes`, counts as 1 station.
2. Fork edges: the `starts_after` station's `main` node to `seq = 1` of each branch, same cost, 1 station.
3. Transfer edges: same `stationId`, different `lineId`, cost `transferPenaltyMinutes`, 0 stations.

The graph is undirected, so A to B and B to A cost the same.

**Search.** Multi-source Dijkstra: start with every `(from, line)` node at cost 0, stop at the cheapest `(to, line)` node. About 100 nodes, so performance is a non-issue. Use `PriorityQueue` from `package:collection` or a simple sorted list. Break ties by fewer transfers, then fewer stations.

**Legs.** Walk the path and start a new leg whenever the line changes. Branch rule (confirmation tracked in D-2): if a Line 3 route goes from one branch through Kit Kat into the other branch, split it into two legs there so it counts as one transfer and one penalty. This is applied after the search; it does not change the path chosen, because there is only one path between two branches.

**Station count.** `stationCount` is the number of same-line moves along the route, with transfers adding 0. Whether the fare count includes the boarding station is tracked in D-1. If it does, add 1 in `FareCalculator` only, not in the router.

**Time.** `estimatedMinutes = stationCount * perStopMinutes + transfers * transferPenaltyMinutes`. The UI labels it as an estimate.

**Fare.** `FareCalculator` picks the first bracket where `stationCount <= maxStations`. If the count is above the largest bracket, use the largest price and keep a unit test for that case.

**Required unit tests (test/):**

1. Same line, no transfer, both directions.
2. One-transfer route (for example Line 1 to Line 2 via Sadat or Al-Shohadaa).
3. Two-transfer route across all three lines.
4. Line 3 branch to branch via Kit Kat counts one transfer.
5. Same station, unknown station and unreachable station return `null`.
6. Symmetry: A to B and B to A give equal time, stations and fare.
7. Fare boundaries: 1, 9, 10, 16, 17, 23, 24, 39 and above 39.
8. Interchange station as the start or the destination.

## 5. Screens and providers

Navigation: bottom bar with four tabs (Planner, Lines, Library, Settings). The Result screen is pushed from the Planner and from Library items. That makes five screens.

**1. Planner (home).** From field, To field, swap button, "Find route" button (disabled until both are set and different). Tapping a field opens a searchable station picker (type to filter, shows the active-language name, other language as subtitle). Below: last 3 searches as chips. Errors: same station, no route.

**2. Route Result.** Summary header with time (marked as an estimate), station count, transfers and fare. Then one card per leg: line color chip and name, boarding and alighting station, collapsible list of stations in between. Transfer markers between cards ("Change to Line 2 at Sadat"). Star button adds or removes the favorite. The search is saved to history when the result opens.

**3. Lines and Stations.** List of the three lines with color. Tap a line to see its stations in order (Line 3 grouped by branch). Tap a station for a bottom sheet with both names and the lines it serves. "Set as From" and "Set as To" buttons feed the Planner.

**4. Favorites and History.** Two tabs. Tap an item to open its result. Swipe to delete a favorite. "Clear history" with a confirmation.

**5. Settings.** Language (AR/EN) toggle, applied instantly. About section with the app name, the data snapshot date and the fare effective date (March 27, 2026).

**Providers.**

1. `SettingsProvider`: locale, text direction, persisted in `shared_preferences`.
2. `RouteProvider`: network data, selected From/To, swap, `calculate()` (calls `findRoute`), saves to history through the repository.
3. `LibraryProvider`: favorites and history lists, toggle favorite, clear history.

All UI text goes through the localization files from the first screen. No hardcoded strings. Station and line names come from the database in both languages and are picked by the active locale.

Arabic search helper (`lib/core/arabic_normalize.dart`, Omar): strip diacritics, unify أ/إ/آ to ا, ة to ه, ى to ي. This is the basic version. Abdullah's fuzzy search is the stretch layer on top.

## 6. Repo skeleton and rules

```
maak_metro/
  assets/metro_seed.json                 (Abdullah)
  docs/PLAN.md, docs/ISSUES.md, docs/M0_SETUP.md   (Hassan)
  lib/main.dart, lib/app.dart            (Hassan)
  lib/core/  theme, l10n, utils          (Omar)
  lib/data/  db_helper, seed_loader, metro_repository  (Mahmoud)
  lib/domain/  models, router_engine, fare_calculator   (Hassan)
  lib/providers/                         (Hassan)
  lib/screens/  lib/widgets/             (Omar)
  test/  fixtures/                       (Youssef)
  .github/  CODEOWNERS, PULL_REQUEST_TEMPLATE.md, workflows/ci.yml
```

- `pubspec.yaml`: provider, sqflite, path, shared_preferences, flutter_localizations, intl, collection. Dev: flutter_test, flutter_lints, sqflite_common_ffi (repository tests without a device).
- Branches: `main` is protected (PR required, 1 review, no direct pushes). Branch names `feature/<area>-<short>`, `fix/<short>`. Small PRs, one issue each, `Closes #n` in the description.
- `CODEOWNERS` maps each folder to its owner so reviews are requested automatically. Changes to `lib/domain/models/` need Hassan's review, because everyone depends on them.
- PR checklist: `dart format .`, `flutter analyze` clean, `flutter test` green, tested on emulator or device, screenshot for UI changes.
- CI (GitHub Actions): format check, `flutter analyze` and `flutter test` on every PR.
- Daily 10-minute sync. Blocked for more than 2 hours means you raise it immediately.
