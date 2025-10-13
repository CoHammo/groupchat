import 'package:flutter/material.dart';
import 'group_page.dart';
import '../chat_controller.dart';
import '../classes/classes.dart';

class GroupCard extends StatelessWidget {
  const GroupCard(this.chatCon, this.group, {super.key});

  final ChatController chatCon;
  final Group group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: InkWell(
        onTap: () {
          chatCon.openGroup(group);
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    var tween = Tween(
                      begin: Offset(1.0, 0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeInOutExpo));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
              pageBuilder: (context, animation, secondaryAnimation) {
                return GroupPage(chatCon, group);
              },
            ),
          );
        },
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: group.imageUrl != null
                  ? Image.network(group.imageUrl!, fit: BoxFit.cover)
                  : CircleAvatar(),
            ),
            Text(group.name),
          ],
        ),
      ),
    );
  }
}
