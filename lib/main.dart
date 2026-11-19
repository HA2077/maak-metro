import 'package:flutter/material.dart';
import 'package:maak_metro/app.dart';
import 'package:maak_metro/data/in_memory_metro_repository.dart';
import 'package:maak_metro/providers/library_provider.dart';
import 'package:maak_metro/providers/route_provider.dart';
import 'package:maak_metro/providers/settings_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // scaffold: INT-1 owns the real wiring. The router (#20..#23) is not in this
  // branch, so RouteProvider has no planner and a search reports "no route"
  // until main passes findRoute.
  final repository = InMemoryMetroRepository();
  final settings = SettingsProvider();
  final library = LibraryProvider(repository: repository);
  final route = RouteProvider(repository: repository, library: library);

  await settings.load();
  await route.load();
  await library.refresh();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: library),
        ChangeNotifierProvider.value(value: route),
      ],
      child: const MaakMetroApp(),
    ),
  );
}
