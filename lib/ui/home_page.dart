import 'package:flutter/material.dart';
import 'package:groupchat/ui/group_list_tile.dart';
import 'package:signals/signals_flutter.dart';
import '../chat_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage(this.chatCon, {super.key});

  final ChatController chatCon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              chatCon.getGroups();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Watch((context) {
        return ListView.builder(
          itemCount: chatCon.groups.length,
          itemBuilder: (context, index) =>
              GroupListTile(chatCon, chatCon.groups[index]),
        );
      }),
    );
  }
}
