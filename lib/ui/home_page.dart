import 'package:flutter/material.dart';
import 'package:groupchat/ui/group_list_tile.dart';
import 'package:signals/signals_flutter.dart';
import '../src/rust/api/rust.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.controller, {super.key});

  final ChatController controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    if (widget.controller.needsLogin) {
      widget.controller.login().then((value) {
        setState(() {});
      });
      return LoginPage();
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: Watch((context) {
          return ListView.builder(
            itemCount: 0,
            itemBuilder: (context, index) {
              // GroupListTile(chatCon, chatCon.groups[index]);
            },
          );
        }),
      );
    }
  }
}
