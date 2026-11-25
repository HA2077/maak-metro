import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:maak_metro/core/l10n/app_localizations.dart';
import 'package:maak_metro/core/presentation/web_device_preview.dart';

class _PreviewController extends Fake implements DevicePreviewController {
  @override
  final ValueNotifier<DeviceSimulation?> simulationListenable = ValueNotifier(
    null,
  );

  @override
  DeviceSimulation? get simulation => simulationListenable.value;

  @override
  Future<void> applyPreset(
    DevicePreset preset, {
    Orientation orientation = Orientation.portrait,
    bool resetOverrides = false,
  }) async {
    simulationListenable.value = preset.resolve(orientation: orientation);
  }

  @override
  Future<void> setOrientation(Orientation orientation) async {
    simulationListenable.value = simulation?.copyWith(orientation: orientation);
  }

  @override
  Future<void> update(
    DeviceSimulation Function(DeviceSimulation current) mutate,
  ) async {
    simulationListenable.value = mutate(simulation ?? const DeviceSimulation());
  }

  @override
  Future<void> reset() async => simulationListenable.value = null;
}

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('preview controls work at 360dp in ${locale.languageCode}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final semantics = tester.ensureSemantics();
      final controller = _PreviewController();

      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => WebDevicePreview(
            controller: controller,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const Scaffold(),
        ),
      );
      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)));
      expect(find.bySemanticsLabel(l10n.devicePreview), findsOneWidget);
      semantics.dispose();

      Future<void> tap(String label) async {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }

      await tap(l10n.devicePreview);
      expect(
        tester
            .widget<MenuItemButton>(
              find.ancestor(
                of: find.text(l10n.devicePreviewRotate),
                matching: find.byType(MenuItemButton),
              ),
            )
            .onPressed,
        isNull,
      );
      await tap(DevicePresets.iPhoneSe3.name);
      expect(controller.simulation?.presetId, DevicePresets.iPhoneSe3.id);

      await tap(l10n.devicePreview);
      await tap(l10n.devicePreviewRotate);
      expect(controller.simulation?.orientation, Orientation.landscape);

      await tap(l10n.devicePreview);
      await tap(l10n.devicePreviewTextSize);
      await tap(NumberFormat.percentPattern(l10n.localeName).format(2));
      expect(controller.simulation?.textScaleFactor, 2);

      await tap(l10n.devicePreview);
      await tap(l10n.devicePreviewReset);
      expect(controller.simulation, isNull);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.simulationListenable.dispose();
    });
  }
}
