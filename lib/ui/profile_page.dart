import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:groupchat/ui/toaster.dart';
import 'package:image_picker/image_picker.dart';
import '../src/rust/api/rust.dart';
import 'profile_text_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(this.controller, {super.key});

  final ChatController controller;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Me me;
  late Me delta;
  late ObjectKey _key;
  late ChangesId changesId;
  bool needsSaved = false;
  bool isSaving = false;
  Map<String, bool> valids = {};
  final ImagePicker _picker = ImagePicker();

  void init() {
    me = widget.controller.getMe();
    delta = widget.controller.getMe();
    if (delta.photoUrls.isEmpty) delta.photoUrls.addAll(["", "", ""]);
    _key = ObjectKey(delta);
    isSaving = false;
  }

  @override
  void initState() {
    super.initState();
    init();

    changesId = widget.controller.state.nextId();
    widget.controller.state.changes(id: changesId).listen((state) {
      state.whenOrNull(
        me: () => setState(() {
          init();
          print("changed me on profile page");
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
    var valid = true;
    for (bool val in valids.values) {
      if (!val) {
        valid = false;
        break;
      }
    }
    needsSaved = !me.equals(other: delta) && valid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() {
              init();
            }),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                key: _key,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundImage: me.imageUrl != null
                          ? NetworkImage(me.imageUrl!)
                          : null,
                      child: Text(
                        me.initials(),
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  ProfileTextField(
                    delta.name,
                    align: TextAlign.center,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "Name",
                      filled: false,
                    ),
                    pattern: RegExp(r"^\s*\S.*$"),
                    onValidChange: (value) {
                      valids["name"] = true;
                      setState(() => delta.name = value);
                    },
                    onInvalidChange: () =>
                        setState(() => valids["name"] = false),
                  ),
                  SizedBox(height: 10),
                  ProfileTextField(
                    delta.bio,
                    decoration: InputDecoration(
                      icon: Icon(Icons.notes, size: 32),
                      hintText: "Tell people about yourself!",
                    ),
                    maxLines: 3,
                    maxLength: 225,
                    onValidChange: (value) {
                      setState(() => delta.bio = value);
                    },
                  ),
                  SizedBox(height: 10),
                  ProfileTextField(
                    delta.email,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email_outlined, size: 32),
                      hintText: "example@email.com",
                    ),
                    pattern: RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                    ),
                    onValidChange: (value) {
                      valids["email"] = true;
                      setState(() => delta.email = value);
                    },
                    onInvalidChange: () =>
                        setState(() => valids["email"] = false),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 8),
                    child: Text(
                      "Photo Gallery (Min 3, Max 6)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: [
                      for (var (index, img) in delta.photoUrls.indexed)
                        SizedBox(
                          width: 225,
                          child: AspectRatio(
                            aspectRatio: 9 / 16,
                            child: OutlinedButton(
                              clipBehavior: Clip.hardEdge,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.all(0),
                              ),
                              onPressed: () async {
                                var image = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (image != null) {
                                  setState(
                                    () => delta.photoUrls[index] = image.path,
                                  );
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                clipBehavior: Clip.hardEdge,
                                child: img.startsWith("https://")
                                    ? Image.network(
                                        img,
                                        fit: BoxFit.fitHeight,
                                        height: double.infinity,
                                      )
                                    : (img == ""
                                          ? Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 36,
                                            )
                                          : Image.file(
                                              File(img),
                                              fit: BoxFit.fitHeight,
                                              height: double.infinity,
                                            )),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: FilledButton(
                onPressed: needsSaved
                    ? () async {
                        setState(() => isSaving = true);
                        try {
                          await widget.controller.updateMe(me: delta);
                        } on ChatError catch (e) {
                          Toaster.showError(e);
                        }
                        setState(() => isSaving = false);
                      }
                    : null,
                child: isSaving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text("Update Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
