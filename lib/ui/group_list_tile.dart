import 'package:flutter/material.dart';
import 'group_page.dart';
import '../chat_controller.dart';
import '../classes/classes.dart';

class GroupListTile extends StatelessWidget {
  const GroupListTile(this.chatCon, this.group, {super.key});

  final ChatController chatCon;
  final Group group;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                  ).chain(CurveTween(curve: Curves.fastEaseInToSlowEaseOut));

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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Container(
              width: 75,
              height: 75,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
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
