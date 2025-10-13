import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:groupchat/classes/classes.dart';
import 'package:signals/signals_flutter.dart';
import 'api.dart';
import 'database.dart';

class ChatController {
  final ListSignal<Group> groups = ListSignal([]);
  late Me me;

  final ListQueue<Group> cachedGroups = ListQueue(5);

  ChatController._make();

  static Future<ChatController> make() async {
    var token = await File('token').readAsString();
    Api.setToken(token);
    await Db.init(memory: true);
    var con = ChatController._make();
    await Db.saveMe(await Api.getMe());
    con.me = await Db.getMe();
    var apiGroups = await Api.getGroups();
    await Db.saveGroups(apiGroups);
    await con._updateGroups();
    return con;
  }

  Future<void> _updateGroups() async {
    final dbGroups = await Db.getGroups();
    groups.clear();
    groups.addAll(dbGroups);
  }

  Future<void> openGroup(Group group) async {
    updateMessages(group);
    var saveMembers = !group.membersSaved;
    var saveMessages = !group.messagesSaved;
    if (saveMembers) {
      await Db.saveMembers(await Api.getMembers(group.id), group.id);
      group.membersSaved = true;
    }
    if (saveMessages) {
      await Db.saveMessages(await Api.getMessages(group.id));
      group.messagesSaved = true;
      await updateMessages(group);
    }
    var apiGroup = await Api.getGroup(group.id);
    if (apiGroup['updated_at'] > group.updatedAt) {
      await Db.saveGroups([apiGroup]);
      _updateGroups();
      if (!saveMembers) {
        await Db.saveMembers(apiGroup['members'], group.id);
      }
      if (!saveMessages) {
        await Db.saveMessages(
          await Api.getMessages(group.id, sinceId: group.lastMessageId),
        );
      }
    }
  }

  Future<void> updateMessages(Group group) async {
    if (group.messagesSaved) {
      if (!cachedGroups.contains(group)) {
        if (cachedGroups.length == 5) {
          var lastGroup = cachedGroups.removeLast();
          lastGroup.messages.clear();
        }
        var dbMessages = await Db.getMessages(group.id);
        group.messages.clear();
        group.messages.addAll(dbMessages);
        cachedGroups.add(group);
      }
    }
  }

  Future<void> sendMessage(Group group, String text) async {
    var message = Message(text, group.id, me.id);
    var inMemory = cachedGroups.contains(group);
    if (inMemory) {
      group.messages.insert(0, message);
    }
    var mess = await Api.sendMessage(message);
    await Db.saveMessages([mess]);
    if (inMemory) {
      group.messages[group.messages.indexOf(message)] = await Db.getMessage(
        mess['id'],
      );
    }
    group.updatedAt = mess['created_at'];
  }
}
