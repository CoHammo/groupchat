import 'package:flutter/material.dart';
import 'package:groupchat/settings_controller.dart';
import 'package:groupchat/ui/user_page.dart';
import 'package:realm/realm.dart';
import '../classes/models.dart';
import 'login_page.dart';
import 'package:signals/signals_flutter.dart';
import '../controller.dart';
import 'settings_page.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({super.key});

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> with SignalsMixin {
  @override
  Widget build(BuildContext context) {
    return Watch<MaterialApp>(
      (context) => MaterialApp(
        title: 'GroupChat',
        themeMode: settingsController.themeMode.value,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
              scrolledUnderElevation: 0.0,
              backgroundColor: Colors.lightBlueAccent),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          appBarTheme: const AppBarTheme(
            scrolledUnderElevation: 0.0,
            backgroundColor: Color.fromARGB(255, 21, 103, 255),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) {
              switch (routeSettings.name) {
                case HomePage.route:
                  return controller.hasToken.value
                      ? const HomePage()
                      : const LoginPage();
                case LoginPage.route:
                  return const LoginPage();
                case SettingsPage.route:
                  return const SettingsPage();
                case UserPage.route:
                  return const UserPage();
                default:
                  return controller.hasToken.value
                      ? const HomePage()
                      : const LoginPage();
              }
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const route = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SignalsMixin {
  late final Computed<bool> hasToken =
      super.createComputed(() => controller.hasToken.value);

  late final Signal<int> numGroups = super.createSignal(0);

  late RealmResults<Group> groups = controller.allGroups();

  @override
  void initState() {
    super.initState();
    groups.changes.listen((changes) => numGroups.value = groups.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        title: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, UserPage.route),
            child: CircleAvatar(
              radius: 24,
              foregroundImage: NetworkImage(controller.user.imageUrl!),
            ),
          ),
          const SizedBox(width: 10),
          const Text('GroupChat'),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 10),
        itemCount: numGroups.value,
        separatorBuilder: (context, index) => const Divider(thickness: 2),
        itemBuilder: (context, index) {
          return ListTile(
              title: Text(groups[index].name),
              subtitle: Text(groups[index].description));
        },
      ),
    );
  }
}
