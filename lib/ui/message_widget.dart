import 'package:flutter/material.dart';
import 'package:groupchat/chat_controller.dart';

import '../classes/message.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget(this.chatCon, this.message, {super.key});

  final ChatController chatCon;
  final Message message;

  @override
  Widget build(BuildContext context) {
    EdgeInsets margin;
    if (message.senderId == chatCon.me.id) {
      margin = EdgeInsets.fromLTRB(60, 8, 10, 8);
    } else {
      margin = EdgeInsets.fromLTRB(10, 8, 60, 8);
    }

    if (message.system) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Material(
          color: Color.fromARGB(29, 0, 0, 0),
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Text(message.text ?? '', textAlign: TextAlign.center),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: margin,
        child: Material(
          borderRadius: BorderRadius.circular(12),
          color: Color(0xFFB0D3FF),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Text(message.text ?? ''),
            ),
          ),
        ),
      );
    }
  }
}
