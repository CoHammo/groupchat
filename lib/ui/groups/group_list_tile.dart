import 'package:flutter/material.dart';
import '../../src/rust/api/rust.dart';
import 'group_page.dart';

class GroupListTile extends StatelessWidget {
  const GroupListTile(this.controller, this.group, {super.key});

  final ChatController controller;
  final Group group;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  var tween = Tween(
                    begin: Offset(0, 1.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOutQuint));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
            pageBuilder: (context, animation, secondaryAnimation) {
              return Scaffold(appBar: AppBar(), body: Text("Not done yet"));
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color.fromARGB(255, 131, 179, 255),
              ),
              clipBehavior: Clip.hardEdge,
              child: group.imageUrl != null
                  ? Image.network(group.imageUrl!, fit: BoxFit.cover)
                  : null,
            ),
            Text(group.name),
            Spacer(),
            Text(
              DateTime.fromMillisecondsSinceEpoch(
                (group.updatedAt * 1000),
              ).toString(),
            ),
          ],
        ),
      ),
    );
  }
}
