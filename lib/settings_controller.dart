import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

final SettingsController settingsController = SettingsController();

class SettingsController {
  Signal<ThemeMode> themeMode = signal(ThemeMode.system);
}