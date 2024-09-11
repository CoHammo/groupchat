import 'package:flutter/material.dart';
import 'package:groupchat/settings_controller.dart';
import 'package:groupchat/ui/account_page.dart';
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
  late final hasToken = super.createComputed(() => controller.hasToken.value);

  @override
  Widget build(BuildContext context) {
    var changed = hasToken.value;
    return Watch<MaterialApp>(
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
  late final groups = super.createComputed(() => controller.groups.value);
  late final chats = super.createComputed(() => controller.chats.value);
  late final pageIndex = super.createSignal(0);
  late final userChanged =
      super.createComputed(() => controller.userChanged.value);

  var scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var changed = userChanged.value;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        title: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, UserPage.route),
            child: CircleAvatar(
              radius: 24,
              foregroundImage: NetworkImage(controller.user?.imageUrl ?? ''),
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
      body: pageIndex.value == 0 ? ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.only(top: 10),
        itemCount: groups.value?.length ?? 0,
        separatorBuilder: (context, index) => const Divider(thickness: 2),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(groups.value?[index].name ?? ''),
            subtitle: Text(groups.value?[index].description ?? ''),
          );
        },
      ) : 
      ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.only(top: 10),
        itemCount: chats.value?.length ?? 0,
        separatorBuilder: (context, index) => const Divider(thickness: 2),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(chats.value?[index].name ?? ''),
            subtitle: Text(chats.value?[index].description ?? ''),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: pageIndex.value,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.group), label: 'Groups'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chats'),
        ],
        onDestinationSelected: (value) {
          pageIndex.value = value;
          scrollController.position.moveTo(0);
        },
      ),
    );
  }
}
