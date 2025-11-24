import 'package:flutter/material.dart';
import '../../src/rust/api/rust.dart';
import 'group_list_tile.dart';

class GroupsList extends StatefulWidget {
  const GroupsList(this.controller, {super.key});

  final ChatController controller;

  @override
  State<GroupsList> createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  late List<Group> groups;
  late ChangesId changesId;

  @override
  void initState() {
    super.initState();
    groups = widget.controller.getGroups();
    changesId = widget.controller.state.nextId();
    widget.controller.state.changes(id: changesId).listen((state) {
      state.whenOrNull(
        groups: () => setState(() {
          groups = widget.controller.getGroups();
          print("groups list changed");
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
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return GroupListTile(widget.controller, groups[index]);
      },
    );
  }
}
