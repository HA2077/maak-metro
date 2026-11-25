# Maak Metro (معاك)

Offline Cairo Metro route planner (Lines 1, 2 and 3). Flutter + SQLite.
Android Development final project. Presentation 11/28/2026.

## Run
    flutter pub get
    flutter run

### Device preview

Device Preview is available during a normal debug run with `flutter run` or
your IDE’s Run command. Open the `device_preview` tab in Flutter DevTools to
select a phone or tablet, rotate it, or change the text scale. Use the app’s
Settings to switch between Arabic and English.

## Toolchain

Everyone uses exactly these versions. `pubspec.lock` is committed and must not be regenerated with a different SDK.

| Tool | Version |
| --- | --- |
| Flutter | 3.47.6 (`stable`, framework revision `5fc346839b`, engine `692136cb65`) |
| Dart | 3.13.5 |
| DevTools | 2.60.0 |
| Gradle (wrapper, committed) | 9.3.1 |
| Android Gradle Plugin | 9.1.0 |
| Kotlin | 2.4.0 |
| Java used to build | Oracle JDK 24.0.2 |
| Java source/target | 17 |
| Android compile / target SDK | 36 / 36 |
| Android min SDK | 24 (Android 7.0) |
| Android build-tools / NDK | 36.0.0 / 28.2.13676358 |

### Install the exact Flutter SDK

Download the 3.47.6 archive for your OS and put it on your `PATH`:

- Linux: https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.6-stable.tar.xz
- Windows: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.47.6-stable.zip

Or clone the tag:

```sh
git clone https://github.com/flutter/flutter.git -b 3.47.6 --depth 1 ~/Flutter/flutter
```

Check the install:

```sh
flutter --version
```

It must print `Flutter 3.47.6` and `Dart 3.13.5`. Do not run `flutter upgrade` or switch channels; `flutter downgrade` only goes back one release, so it is not a reliable way to reach 3.47.6.

### Android setup

Install the SDK packages (Android Studio SDK Manager, or `sdkmanager` for VS Code users):

```sh
sdkmanager "platforms;android-36" "build-tools;36.0.0" "platform-tools" "ndk;28.2.13676358"
```

- **Java:** the project builds with Oracle JDK 24.0.2. Android Studio or VS Code may use the IDE's bundled JBR instead; any JDK 17 or newer works because the project compiles to Java 17.
- **Emulator:** create an AVD with **Android 16 (API 36), Google APIs**; use the `x86_64` image on Linux/Windows and `arm64-v8a` on Apple Silicon.
- **Physical device:** minimum **Android 7.0 (API 24)**, matching `minSdk`.

### Verify a fresh clone

```sh
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Docs
- `docs/PLAN.md`: architecture, seed format, router design

## Rules
1. Nobody pushes directly to `main`. Branches: `feature/<area>-<short>` or `fix/<short>`.
2. One issue per PR, with `Closes #n`. Small PRs.
3. `dart format .`, `flutter analyze` and `flutter test` before every PR.
4. Blocked for more than 2 hours? Say so in the group immediately.
