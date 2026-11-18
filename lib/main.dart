import 'package:flutter/material.dart';

void main() => runApp(const MaakMetroApp());

class MaakMetroApp extends StatelessWidget {
  const MaakMetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Maak Metro'))),
    );
  }
}
