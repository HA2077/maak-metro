import 'package:flutter/material.dart';
import 'package:maak_metro/app.dart';
import 'package:maak_metro/data/metro_repository.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _bootstrap();
}

Future<void> _bootstrap() async {
  SharedPreferences? prefs;
  SqliteMetroRepository? repo;
  Object? startupError;
  try {
    prefs = await SharedPreferences.getInstance();
    repo = await SqliteMetroRepository.create(prefs: prefs);
  } catch (error) {
    startupError = error;
  }

  if (prefs == null || repo == null) {
    runApp(
      MaakMetroApp(
        startupError: startupError ?? StateError('Startup failed'),
        onRetry: _bootstrap,
      ),
    );
    return;
  }

  final settings = SettingsProvider(prefs);
  final library = LibraryProvider(repo);
  final route = RouteProvider(repo, onLibraryChanged: library.refresh);
  await settings.load();
  await library.refresh();
  await route.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProvider<LibraryProvider>.value(value: library),
        ChangeNotifierProvider<RouteProvider>.value(value: route),
      ],
      child: const MaakMetroApp(),
    ),
  );
}
