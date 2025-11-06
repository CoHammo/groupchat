import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../chat_controller.dart';
import '../classes/classes.dart';
import 'message_widget.dart';

class GroupPage extends StatelessWidget {
  const GroupPage(this.chatCon, this.group, {super.key});

  final ChatController chatCon;
  final Group group;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => chatCon.updateMessages(group),
            icon: Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Watch.builder(
              builder: (context) {
                return ListView.builder(
                  reverse: true,
                  itemCount: group.messages.value.length,
                  itemBuilder: (context, index) {
                    return MessageWidget(chatCon, group.messages[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
