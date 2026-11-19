import 'package:flutter/material.dart';
import 'package:maak_metro/core/l10n/app_localizations.dart';

class LinesScreen extends StatelessWidget {
  const LinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).linesTitle)),
    );
  }
}
