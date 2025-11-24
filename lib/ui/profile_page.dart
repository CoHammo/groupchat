import 'package:flutter/material.dart';
import '../src/rust/api/rust.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(this.controller, {super.key});

  final ChatController controller;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Me me;
  late Me changeMe;
  late ChangesId changesId;
  late TextEditingController nameText;
  late TextEditingController emailText;
  late TextEditingController bioText;
  bool needsSaved = false;

  @override
  void initState() {
    super.initState();

    me = widget.controller.getMe();
    changeMe = widget.controller.getMe();

    nameText = TextEditingController(text: me.name);
    emailText = TextEditingController(text: me.email);
    bioText = TextEditingController(text: me.bio);

    changesId = widget.controller.state.nextId();
    widget.controller.state.changes(id: changesId).listen((state) {
      state.whenOrNull(
        me: () => setState(() {
          me = widget.controller.getMe();
          changeMe = widget.controller.getMe();
          needsSaved = false;
          print("changed me on profile page");
        }),
      );
    });
    widget.controller.loadMe();
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.state.unlisten(id: changesId);
  }

  @override
  Widget build(BuildContext context) {
    if (changeMe.name == me.name &&
        changeMe.email == me.email &&
        changeMe.bio == me.bio) {
      needsSaved = false;
    } else {
      needsSaved = true;
    }
    print(needsSaved);
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundImage: me.imageUrl != null
                    ? NetworkImage(me.imageUrl!)
                    : null,
                child: Text(me.initials(), style: TextStyle(fontSize: 32)),
              ),
            ),
            SizedBox(height: 14),
            TextField(
              controller: nameText,
              onChanged: (value) {
                changeMe.name = value;
                setState(() => needsSaved = changeMe != me);
              },
            ),
            SizedBox(height: 8),
            TextField(
              controller: emailText,
              onChanged: (value) {
                changeMe.email = value;
                setState(() => needsSaved = changeMe != me);
              },
            ),
            SizedBox(height: 8),
            TextField(
              controller: bioText,
              onChanged: (value) {
                changeMe.bio = value;
                setState(() => needsSaved = changeMe != me);
              },
            ),
            Spacer(),
            SizedBox(
              height: 38,
              child: FilledButton(
                onPressed: needsSaved
                    ? () => widget.controller.updateMe(me: changeMe)
                    : null,
                child: Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
