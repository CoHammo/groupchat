// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

import 'package:flutter/material.dart';
import 'package:groupchat/src/rust/frb_generated.dart';
import 'package:groupchat/src/rust/api/rust.dart';
import 'package:path_provider/path_provider.dart';

import 'ui/home_page.dart';

void main() async {
  await RustLib.init();
  WidgetsFlutterBinding.ensureInitialized();
  var folder = (await getApplicationCacheDirectory()).path;
  var controller = await ChatController.newInstance(folder: folder);
  runApp(GroupChat(controller));
  // try {
  //   var token = "YL5adURLQUmATab5V3z31cIl9MBKKER4DI80YhPs";
  // } on ChatError catch (e) {
  //   print(e.message);
  // }
}

class GroupChat extends StatelessWidget {
  const GroupChat(this.controller, {super.key});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 18)),
      ),
      home: HomePage(controller),
    );
  }
}
