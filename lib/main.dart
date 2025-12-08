// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:groupchat/src/rust/frb_generated.dart';
import 'package:groupchat/src/rust/api/rust.dart';
import 'package:groupchat/ui/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'ui/home_page.dart';

late final ChatController controller;

void main() async {
  await RustLib.init();
  WidgetsFlutterBinding.ensureInitialized();
  var dataFolder = "${(await getApplicationCacheDirectory()).path}/Database";
  var metaFolder = "${(await getApplicationSupportDirectory()).path}/Metadata";

  var cont = await ChatController.newInstance(
    dataFolder: dataFolder,
    metaFolder: metaFolder,
    online: true,
  );
  if (cont.loggedIn()) {
    await cont.loadGroups(loadAll: true);
  }
  controller = cont;

  PlatformDispatcher.instance.onError = (error, stack) {
    Toast.error(error);
    return true;
  };

  runApp(GroupChat(cont));
}

const double cornerRadius = 8;
final Color lightBoxColor = Colors.grey.shade300;

class GroupChat extends StatelessWidget {
  const GroupChat(this.cont, {super.key});

  final ChatController cont;
  static const Color primaryColor = Color.fromARGB(255, 21, 103, 255);
  // static const Color secondaryColor = Color.fromARGB(255, 146, 219, 253);
  static const Color secondaryColor = Color.fromARGB(255, 184, 217, 255);

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
            elevation: 0,
            shadowColor: null,
            padding: EdgeInsets.all(0),
            textStyle: TextStyle(fontSize: 22),
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor, width: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return secondaryColor;
            } else {
              return Colors.grey.shade800;
            }
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            } else {
              return Colors.grey.shade500;
            }
          }),
          trackOutlineColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            } else {
              return Colors.grey.shade800;
            }
          }),
          trackOutlineWidth: WidgetStateProperty.all(2.5),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          filled: true,
          fillColor: lightBoxColor,
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
          secondary: secondaryColor,
          onSecondary: Colors.black,
          error: Colors.red.shade400,
          onError: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 17),
          bodyMedium: TextStyle(fontSize: 16),
          bodySmall: TextStyle(fontSize: 14),
        ),
      ),
      home: HomePage(cont, key: Toast.scaffoldKey),
    );
  }
}
