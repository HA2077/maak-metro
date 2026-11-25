# AGENTS.md

## Project Overview
- **Purpose:** Maak Metro (معاك) is an offline Android app that finds the best route between any two stations on Cairo Metro Lines 1, 2 and 3. For each route it shows stations, transfers, fare and an estimated time. Arabic (RTL) is the default language, English is available.
- **Tech Stack:** Flutter and Dart, `flutter_bloc` (Cubit and BlocProvider), SQLite via `sqflite`, `shared_preferences`, `intl` and Flutter localization (ARB files). Dev: `flutter_test`, `flutter_lints`, `sqflite_common_ffi`. The exact Flutter and Dart versions are in `README.md` under "Toolchain". Do not use other versions.
- **Architecture:** Feature-first Clean Architecture. Each feature owns its presentation, pure Dart domain, and data adapter where needed. Dependencies point `presentation → domain ← data`. The app composes them in `lib/main.dart`.
  1. `assets/metro_seed.json` is the single source of truth for lines, stations, branches and fares. Bootstrap opens SQLite once and seeds it before loading the network.
  2. Network owns the shared metro snapshot and the Lines screen. Planner owns station selection, the route engine, and the result screen.
  3. Library owns saved trips and history. Settings owns language, theme, and onboarding.
  4. Presentation uses `NetworkCubit`, `PlannerCubit`, `LibraryCubit`, and `SettingsCubit` with immutable state and constructor-injected dependencies.
- **Source of truth:** `docs/PLAN.md` (seed format, SQL schema, Dart contract, router design, screens). If a task contradicts the plan, stop and ask. Do not guess.
- **Scope (final):** no monorail, no other transport, no live train data, no GPS, no maps, no online APIs, no accounts, no payments, no backend. The app must work with no internet.

## Setup & Common Commands
Always run commands from the repository root:
- **Install dependencies:** `flutter pub get`
- **Run the app:** `flutter run`
- **Run all tests:** `flutter test`
- **Run a single test file:** `flutter test test/features/planner/domain/router_engine_test.dart`
- **Format:** `dart format .`
- **Format check (what CI runs):** `dart format --output=none --set-exit-if-changed .`
- **Analyze (lint and type check):** `flutter analyze`
- **Generate localization files (if the ARB files changed):** `flutter gen-l10n`
- **Build release APK:** `flutter build apk --release`

## Directory Structure
- `/assets/metro_seed.json` — All metro data. Format is frozen (see the plan, section 1).
- `/lib/core/` — Shared theme, localization, motion, utilities, and SQLite setup
- `/lib/features/` — `planner/`, `network/`, `library/`, and `settings/`
- `/lib/main.dart`, `/lib/app.dart`, `/lib/home_shell.dart` — Bootstrap, app configuration, and navigation
- `/test/` — Tests mirroring `lib/`, plus `fixtures/` with a small hand-written test network
- `/docs/` — `PLAN.md`, `data-sources.md`, onboarding notes
- `/.github/` — `CODEOWNERS`, PR template, CI workflow

Work inside the feature or layer your task belongs to. Coordinate reviews with the seed owner (Abdullah), data owner (Mahmoud), domain and state owner (Hassan), UI owner (Omar), and test owner (Youssef).

## Code Style & Conventions
- **Language:** Dart with null safety. Avoid `dynamic` and unnecessary `!`. Follow the rules in `analysis_options.yaml` (`flutter_lints`); `flutter analyze` must report zero issues.
- **Formatting:** Output of `dart format .` is the only accepted format. Prefer single quotes.
- **Patterns:** Immutable data classes with `const` constructors and `final` fields. Small functions, pure where possible. Keep widgets small and split reusable parts into the feature’s `presentation/widgets/`. Do not put business logic in widgets.
- **Naming:** `lowerCamelCase` for variables, functions and members; `UpperCamelCase` for classes and enums; `snake_case` for file names (`route_provider.dart`). JSON and SQL keys stay `snake_case` (`name_ar`, `line_id`).
- **Imports:** Order: `dart:` first, then `package:` (Flutter and third party), then `package:maak_metro/...` for other folders of this app, then relative imports within the same folder.
- **Domain purity:** Each feature’s `domain/` must not import `package:flutter`, `sqflite` or `dart:io`. Everything there must run without a device.
- **Localization:** No hardcoded user-facing strings in UI code. Every string goes in both `app_ar.arb` and `app_en.arb` with identical keys. Use ICU plurals (Arabic needs `=0`, `=1`, `=2`, `few`, `many`, `other`). Layouts must work in RTL and LTR. Use `EdgeInsetsDirectional` and `AlignmentDirectional` instead of left and right.
- **Data rules:** Never hardcode stations, lines, fares or line colors in Dart (test fixtures are the only exception). Station ids are stable lowercase English slugs and are never renamed. An interchange is the same `station_id` on several lines, not a special case.
- **Routing rules:** Graph node is `(stationId, lineId)`. Costs are integers in tenths of a minute (2.5 → 25, 7.5 → 75). Defaults: `perStopMinutes = 2.5`, `transferPenaltyMinutes = 7.5`. Ties are broken by fewer transfers, then fewer stations. Estimated time is shown to users as an estimate.
- **Errors:** Handle errors explicitly. Never swallow exceptions. Seeding failures must surface to the UI (error screen with retry), not a blank screen.

## Testing & Verification Rules
- Write unit tests for all new business logic and bug fixes. Tests mirror `lib/`: `lib/features/planner/domain/router_engine.dart` is tested in `test/features/planner/domain/router_engine_test.dart`.
- Router and fare logic is verified against `test/fixtures/` and its `expected_routes.md`. Do not change the fixture or its expected values to make a test pass.
- Repository tests use `sqflite_common_ffi` with an in-memory database.
- `test/data/seed_validation_test.dart` validates `assets/metro_seed.json`. Run it after any seed change.
- Never delete or skip existing failing tests to make a suite pass.
- Before finishing any task, run `dart format .`, `flutter analyze` and `flutter test`, and fix every failure. Report the result.
- For UI changes, run the app and check both Arabic (RTL) and English, at 360dp width and with large text. Say what you could not test.

## Boundaries & Guardrails
### Always Do
- Read `docs/PLAN.md` and the files you will touch before changing anything.
- Keep diffs small, focused and scoped to the requested task. Open a follow-up suggestion instead of growing the change.
- Reuse existing models, helpers and widgets before creating new ones.
- Keep each feature’s `domain/` pure and keep the three layers separate (UI never talks to SQLite directly).
- Update `docs/PLAN.md` in the same change if you change a contract it describes (only when asked to change that contract).

### Ask First
- Changing the SQL schema, the seed file format or any file in a feature’s `domain/models/` (everything depends on them).
- Adding or upgrading any package, or changing `pubspec.yaml` SDK constraints.
- Changing CI workflows, `CODEOWNERS`, the PR template, `analysis_options.yaml` or Android build config (`applicationId`, permissions).
- Editing the real data in `assets/metro_seed.json`. Metro data comes only from the official Cairo Metro website and is verified by humans.
- Changing the routing constants, the transfer or branch rules, or the fare counting rule.
- Touching files outside the folder your task belongs to.

### Never Do
- Commit secrets, API keys or keystores.
- Add the internet permission, network calls, analytics, maps, GPS or any online API.
- Hand-edit generated files (localization output, `pubspec.lock`) or edit anything under `build/` or `.dart_tool/`.
- Invent metro data (station names, order, fares) or copy it from unofficial sources.
- Push to `main`, force-push, rewrite git history, or run `git commit` or `git push` unless explicitly instructed.
- Delete or weaken tests, lint rules or CI checks to get a green result.

## Git & Pull Request Guidelines
- **Branches:** `feature/<area>-<short>` or `fix/<short>`, created from an up-to-date `main`. `main` is protected: changes go in through a pull request with one approval and a green CI run, merged with squash.
- **Commit Format:** `type(area): short message` with types `feat`, `fix`, `test`, `docs`, `chore`, `refactor` (for example `feat(domain): add fare calculator`, `fix(data): keep favorites on re-seed`).
- **PR Descriptions:** Use the PR template in `.github/`. Include a summary of changes, the motivation, and confirmation that `dart format .`, `flutter analyze` and `flutter test` pass. Add a screenshot for UI changes and mention what was tested on a real device or emulator.
- **Small PRs:** One focused change per PR. Changes to a feature’s `domain/models/` or the seed format must tag the whole team.
- **Blocked?** If you cannot continue, stop and describe what you tried and what is missing. Do not work around a missing contract by guessing.