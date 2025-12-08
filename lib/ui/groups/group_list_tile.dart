import 'package:flutter/material.dart';
import '../../src/rust/api/rust.dart';
import '../images/any_image.dart';
import '../images/image_utils.dart';
import 'group_page.dart';

class GroupListTile extends StatelessWidget {
  const GroupListTile(this.controller, this.group, {super.key});

  final ChatController controller;
  final (Img, Group) group;

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: ColorScheme.of(context).secondary,
              ),
              clipBehavior: Clip.hardEdge,
              child: AnyImage(
                group.$1,
                fit: BoxFit.cover,
                child: Icon(Icons.people_alt_outlined, size: 30),
              ),
            ),
            SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(group.$2.name, style: TextTheme.of(context).titleSmall),
                  Text("heyo"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
