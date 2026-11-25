import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maak_metro/core/data/db_helper.dart';
import 'package:maak_metro/features/library/data/sqlite_library_repository.dart';
import 'package:maak_metro/features/library/presentation/library_cubit.dart';
import 'package:maak_metro/features/network/data/seed_loader.dart';
import 'package:maak_metro/features/network/data/sqlite_network_repository.dart';
import 'package:maak_metro/features/network/presentation/network_cubit.dart';
import 'package:maak_metro/features/planner/presentation/planner_cubit.dart';
import 'package:maak_metro/features/settings/data/preferences_settings_repository.dart';
import 'package:maak_metro/features/settings/presentation/settings_cubit.dart';

import 'app.dart';

Future<void> main() async {
  if (kDebugMode) {
    DevicePreview.enable();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  await _bootstrap();
}

Future<void> _bootstrap() async {
  final helper = DbHelper();
  final SettingsCubit settings;
  final LibraryCubit library;
  final NetworkCubit network;

  try {
    final prefs = await SharedPreferences.getInstance();
    final db = await helper.database;
    await SeedLoader(db, prefs).seedIfNeeded();
    settings = SettingsCubit(PreferencesSettingsRepository(prefs));
    library = LibraryCubit(SqliteLibraryRepository(db));
    network = NetworkCubit(SqliteNetworkRepository(db, prefs));
  } catch (error) {
    runApp(MaakMetroApp(startupError: error, onRetry: _bootstrap));
    return;
  }

  await library.refresh();
  await network.load();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => settings, lazy: false),
        BlocProvider(create: (_) => library, lazy: false),
        BlocProvider(create: (_) => network, lazy: false),
        BlocProvider(create: (_) => PlannerCubit()),
      ],
      child: const MaakMetroApp(),
    ),
  );
}
