// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

import 'package:flutter/material.dart';
import 'package:groupchat/src/rust/frb_generated.dart';
import 'package:groupchat/src/rust/api/rust.dart';
import 'package:path_provider/path_provider.dart';
import 'ui/home_page.dart';

void main() async {
  await RustLib.init();
  WidgetsFlutterBinding.ensureInitialized();
  var dataFolder = "${(await getApplicationCacheDirectory()).path}/Database";
  var metaFolder = "${(await getApplicationSupportDirectory()).path}/Metadata";
  var controller = await ChatController.newInstance(
    dataFolder: dataFolder,
    metaFolder: metaFolder,
    online: true,
  );
  if (controller.loggedIn()) {
    await controller.refreshAll();
  }
  runApp(GroupChat(controller));
}

class GroupChat extends StatelessWidget {
  const GroupChat(this.controller, {super.key});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    double cornerRadius = 8;
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          toolbarHeight: 70,
          backgroundColor: const Color.fromARGB(255, 21, 103, 255),
          foregroundColor: Colors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            textStyle: TextStyle(fontSize: 22),
            backgroundColor: const Color.fromARGB(255, 21, 103, 255),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(cornerRadius),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          filled: true,
          fillColor: Colors.grey.shade300,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
        ),
        canvasColor: Colors.white,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color.fromARGB(255, 21, 103, 255),
          onPrimary: Colors.black,
          secondary: Colors.blue.shade200,
          onSecondary: Colors.black,
          error: Colors.red.shade400,
          onError: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 20),
          bodyMedium: TextStyle(fontSize: 18),
        ),
      ),
      home: HomePage(controller),
    );
  }
}
