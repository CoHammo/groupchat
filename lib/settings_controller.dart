import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

final SettingsController sController = SettingsController();

class SettingsController {
  Signal<ThemeMode> themeMode = signal(ThemeMode.system);
}