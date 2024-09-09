import 'package:flutter/material.dart';
import 'package:groupchat/settings_controller.dart';
import '../controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const route = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
        ),
        body: ListView(padding: const EdgeInsets.all(5), children: [
          SubmenuButton(menuChildren: [
            MenuItemButton(
              child: const Text('System Theme'),
              onPressed: () {settingsController.themeMode.value = ThemeMode.system; setState(() {});},
            ),
            MenuItemButton(
              child: const Text('Light'),
              onPressed: () {settingsController.themeMode.value = ThemeMode.light; setState(() {});},
            ),
            MenuItemButton(
              child: const Text('Dark'),
              onPressed: () {settingsController.themeMode.value = ThemeMode.dark; setState(() {});},
            ),
          ], child: Text('Theme: ${settingsController.themeMode.value.name}')),
          FilledButton(
              style: Theme.of(context).filledButtonTheme.style,
              child: const Text('Logout'),
              onPressed: () {
                controller.logout();
                Navigator.pushReplacementNamed(context, '/login');
              })
        ]));
  }
}
