// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:groupchat/src/rust/frb_generated.dart';
import 'package:groupchat/src/rust/api/rust.dart';
import 'package:groupchat/ui/toaster.dart';
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

  PlatformDispatcher.instance.onError = (error, stack) {
    Toaster.showError(error);
    return true;
  };

  runApp(GroupChat(controller));
}

class GroupChat extends StatelessWidget {
  const GroupChat(this.controller, {super.key});

  final ChatController controller;
  static const Color primaryColor = Color.fromARGB(255, 21, 103, 255);
  static const double cornerRadius = 8;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
        ),
        primaryColor: primaryColor,
        cardColor: Colors.blueGrey.shade100,
        appBarTheme: AppBarTheme(
          toolbarHeight: 70,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 30),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            textStyle: TextStyle(fontSize: 22),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: TextStyle(fontSize: 22),
            foregroundColor: primaryColor,
            backgroundColor: Colors.blueGrey.shade100,
            side: BorderSide(color: primaryColor, width: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          filled: true,
          fillColor: Colors.grey.shade300,
          hintStyle: TextStyle(color: Colors.grey.shade700),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
        ),
        canvasColor: Colors.white,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryColor,
          onPrimary: Colors.black,
          secondary: Colors.blue.shade200,
          onSecondary: Colors.black,
          error: Colors.red.shade400,
          onError: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 22),
          bodyMedium: TextStyle(fontSize: 22),
        ),
      ),
      home: HomePage(controller, key: Toaster.scaffoldKey),
    );
  }
}
