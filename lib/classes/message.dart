import 'dart:convert';

import 'package:uuid/uuid.dart';

class Message {
  static final List<String> columns = [];
  final List _row;

  String? id;
  String groupId;
  String senderId;
  bool system;
  String? text;
  List<Reaction>? reactions;
  List<Attachment>? attachments;
  String sourceGuid;
  int? pinnedAt;
  String? pinnedBy;
  int? createdAt;
  int? updatedAt;

  String name;
  String? nickname;
  String? imageUrl;

  Message(
    this.text,
    this.groupId,
    this.senderId, {
    this.attachments,
    this.system = false,
  }) : id = null,
       sourceGuid = Uuid().v7(),
       createdAt = null,
       name = 'You',
       _row = [];

  Message.fromRow(this._row)
    : id = _row[0],
      groupId = _row[1],
      senderId = _row[2],
      system = _row[3],
      text = _row[4],
      sourceGuid = _row[7],
      pinnedAt = _row[8],
      pinnedBy = _row[9],
      createdAt = _row[10],
      updatedAt = _row[11],
      name = _row[12],
      nickname = _row[13],
      imageUrl = _row[14] {
    if (_row[5] != null) {
      reactions = [];
      for (Map<String, dynamic> react in (_row[5] as List)) {
        reactions!.add(
          Reaction(
            react['unicode'],
            (react['user_ids'] as List).cast<String>(),
          ),
        );
      }
    }
    if (_row[6] != null) {
      attachments = [];
      for (Map<String, dynamic> att in _row[6]) {
        attachments!.add(
          Attachment(att['type'], att['id'], att['lat'], att['lng']),
        );
      }
    }
  }

  @override
  String toString() {
    var message = Map.fromIterables(columns, _row);
    return JsonEncoder.withIndent('  ').convert(message);
  }
}

class Reaction {
  final String unicode;
  List<String> userIds;

  Reaction(this.unicode, this.userIds);

  @override
  String toString() {
    var reaction = {'unicode': unicode, 'user_ids': userIds};
    return JsonEncoder.withIndent('  ').convert(reaction);
  }
}

class Attachment {
  final String type;
  final String id;
  final String? lat;
  final String? lng;

  Attachment(this.type, this.id, this.lat, this.lng);

  @override
  String toString() {
    var attachment = {'type': type, 'id': id, 'lat': lat, 'lng': lng};
    return JsonEncoder.withIndent('  ').convert(attachment);
  }
}
