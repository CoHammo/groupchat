// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

import 'package:flutter/material.dart';
import 'package:groupchat/src/rust/frb_generated.dart';
import 'package:groupchat/src/rust/api/rust.dart';
// import 'package:path_provider/path_provider.dart';

void main() async {
  await RustLib.init();
  WidgetsFlutterBinding.ensureInitialized();
  // var dir = (await getApplicationCacheDirectory()).path;
  try {
    var token = "YL5adURLQUmATab5V3z31cIl9MBKKER4DI80YhPs";
    // var token = await File('token').readAsString();
    var api = await Api.init(token: token);
    var me = await api.getMe();
    print(me.name);
  } on ChatError catch (e) {
    print(e.message);
  }
}

// class GroupChat extends StatelessWidget {
//   const GroupChat(this.chatCon, {super.key});

//   final ChatController chatCon;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 18)),
//       ),
//       home: HomePage(chatCon),
//     );
//   }
// }
