import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'ui/group_card.dart';
import 'chat_controller.dart';

void main() async {
  SignalsObserver.instance = null;
  var chatCon = await ChatController.make();
  runApp(GroupChat(chatCon));
}

class GroupChat extends StatelessWidget {
  const GroupChat(this.chatCon, {super.key});

  final ChatController chatCon;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 18)),
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: Watch.builder(
          builder: (context) {
            return ListView.builder(
              itemCount: chatCon.groups.length,
              itemBuilder: (context, index) =>
                  GroupCard(chatCon, chatCon.groups[index]),
            );
          },
        ),
      ),
    );
  }
}
