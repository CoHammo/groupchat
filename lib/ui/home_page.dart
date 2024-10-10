import 'dart:async';
import 'package:flutter/material.dart';
import 'package:groupchat/settings_controller.dart';
import 'package:groupchat/ui/account_page.dart';
import 'login_page.dart';
import 'package:signals/signals_flutter.dart';
import '../controller.dart';
import 'settings_page.dart';
import 'widgets/chat_tile.dart';
import 'widgets/group_tile.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({super.key});

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => MaterialApp(
        title: 'GroupChat',
        themeMode: settingsController.themeMode.value,
        theme: ThemeData(
          cardColor: const Color.fromARGB(255, 224, 224, 224),
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
          cardColor: const Color.fromARGB(255, 43, 43, 43),
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
                case AccountPage.route:
                  return const AccountPage();
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
  late final groups = controller.groups;
  late final chats = controller.chats;
  late final stateChanged = super.createSignal(0);

  late final pageIndex = super.createSignal(0);

  late List<StreamSubscription?> subs = [];

  @override
  void initState() {
    super.initState();
    controller.ensureLoginServerClosed();
    var sub1 = groups.changes.listen((event) => stateChanged.value++);
    var sub2 = chats.changes.listen((event) => stateChanged.value++);
    var sub3 = controller.user?.changes.listen((event) => stateChanged.value++);
    subs.addAll([sub1, sub2, sub3]);
  }

  @override
  void dispose() async {
    super.dispose();
    for (var sub in subs) {
      await sub?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        title: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AccountPage.route),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: CircleAvatar(
                radius: 24,
                foregroundImage: NetworkImage(controller.user?.imageUrl ?? ''),
              ),
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
      body: IndexedStack(index: pageIndex.value, children: [
        ListView.separated(
          cacheExtent: 1000,
          separatorBuilder: (context, index) =>
              const Divider(thickness: 2, height: 2),
          itemCount: groups.length,
          itemBuilder: (context, index) => GroupTile(groups[index]),
        ),
        ListView.separated(
          cacheExtent: 1000,
          separatorBuilder: (context, index) =>
              const Divider(thickness: 2, height: 2),
          itemCount: chats.length,
          itemBuilder: (context, index) => ChatTile(chats[index]),
        ),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: pageIndex.value,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.group), label: 'Groups'),
          NavigationDestination(
              icon: Icon(Icons.person), label: 'Direct Messages'),
        ],
        onDestinationSelected: (value) {
          pageIndex.value = value;
        },
      ),
    );
  }
}
