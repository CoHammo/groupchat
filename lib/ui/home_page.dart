import 'package:flutter/material.dart';
import 'package:groupchat/ui/groups/groups_list.dart';
import 'package:groupchat/ui/profile/profile_page.dart';
import 'package:groupchat/ui/toast.dart';
import '../src/rust/api/rust.dart';
import 'images/any_image.dart';
import 'images/image_utils.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.controller, {super.key});

  final ChatController controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Me me;
  late ChangesId changesId;

  @override
  void initState() {
    super.initState();
    me = widget.controller.getMe();
    changesId = widget.controller.state.nextId();
    widget.controller.state.changes(id: changesId).listen((state) {
      state.whenOrNull(
        login: () => setState(() {
          me = widget.controller.getMe();
          print("logged in on home page");
        }),
        me: () => setState(() {
          me = widget.controller.getMe();
        }),
        logout: () => setState(() {
          me = widget.controller.getMe();
          print("logged out on home page");
        }),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.state.unlisten(id: changesId);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.loggedIn()) {
      return LoginPage(widget.controller);
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("GroupChat"),
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ProfilePage(widget.controller),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          var tween = Tween(
                            begin: Offset(-1.0, 0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeInOutQuint));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                  ),
                );
              },
              child: AnyImage(
                Img(url: me.imageUrl),
                circle: true,
                child: Text(me.initials()),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Toast("Hello There!", seconds: 3);
              },
              icon: Icon(Icons.bubble_chart),
            ),
            IconButton(
              onPressed: () {
                widget.controller.shrinkDb();
              },
              icon: Icon(Icons.compress),
            ),
            IconButton(
              onPressed: () {
                widget.controller.refreshAll();
              },
              icon: Icon(Icons.refresh),
            ),
          ],
        ),
        body: GroupsList(widget.controller),
      );
    }
  }
}
