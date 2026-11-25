import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:maak_metro/core/l10n/app_localizations.dart';

class WebDevicePreview extends StatelessWidget {
  const WebDevicePreview({
    super.key,
    required this.controller,
    required this.child,
  });

  final DevicePreviewController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Overlay.wrap(
      child: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: Column(
            // Paint the toolbar above the route so its semantics stay visible.
            verticalDirection: VerticalDirection.up,
            children: [
              Expanded(child: child),
              Material(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: _PreviewMenu(controller: controller),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewMenu extends StatelessWidget {
  const _PreviewMenu({required this.controller});

  final DevicePreviewController controller;

  static const _presets = [
    DevicePresets.iPhoneSe3,
    DevicePresets.pixel9,
    DevicePresets.iPad10,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percent = NumberFormat.percentPattern(l10n.localeName);
    return ValueListenableBuilder<DeviceSimulation?>(
      valueListenable: controller.simulationListenable,
      builder: (context, simulation, _) {
        final orientation = simulation?.orientation ?? Orientation.portrait;
        return MenuAnchor(
          menuChildren: [
            for (final preset in _presets)
              MenuItemButton(
                onPressed: () =>
                    controller.applyPreset(preset, orientation: orientation),
                trailingIcon: simulation?.presetId == preset.id
                    ? const Icon(Icons.check)
                    : null,
                child: Text(preset.name),
              ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.screen_rotation_outlined),
              onPressed: simulation?.screenSize == null
                  ? null
                  : () => controller.setOrientation(
                      orientation == Orientation.portrait
                          ? Orientation.landscape
                          : Orientation.portrait,
                    ),
              child: Text(l10n.devicePreviewRotate),
            ),
            SubmenuButton(
              leadingIcon: const Icon(Icons.format_size),
              menuChildren: [
                for (final scale in [1.0, 1.5, 2.0])
                  MenuItemButton(
                    onPressed: () => controller.update(
                      (current) => current.copyWith(textScaleFactor: scale),
                    ),
                    trailingIcon: (simulation?.textScaleFactor ?? 1.0) == scale
                        ? const Icon(Icons.check)
                        : null,
                    child: Text(percent.format(scale)),
                  ),
              ],
              child: Text(l10n.devicePreviewTextSize),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.restart_alt),
              onPressed: simulation == null ? null : controller.reset,
              child: Text(l10n.devicePreviewReset),
            ),
          ],
          builder: (context, menu, _) => TextButton.icon(
            onPressed: () => menu.isOpen ? menu.close() : menu.open(),
            icon: const Icon(Icons.devices_outlined),
            label: Text(l10n.devicePreview),
          ),
        );
      },
    );
  }
}
