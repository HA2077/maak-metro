import 'package:flutter/material.dart';
import 'package:maak_metro/core/theme/app_theme.dart';

void main() => runApp(const MaakMetroApp());

class MaakMetroApp extends StatelessWidget {
  const MaakMetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maak Metro',
      theme: AppTheme.light,
      home: const Scaffold(body: Center(child: Text('Maak Metro'))),
    );
  }
}
