import 'package:flutter/material.dart';
import 'package:groupchat/ui/groups/groups_list.dart';
import 'package:groupchat/ui/profile_page.dart';
import '../src/rust/api/rust.dart';
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
          centerTitle: true,
          title: Text("GroupChat"),
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(widget.controller),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundImage: me.imageUrl != null
                    ? NetworkImage(me.imageUrl!)
                    : null,
                child: Text(me.initials(), style: TextStyle(fontSize: 22)),
              ),
            ),
          ),
          actions: [
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
