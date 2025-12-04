import 'me.dart';

class Message {
  static final List<String> columns = [];

  String id;
  String groupId;
  String senderId;
  bool system;
  String? text;
  List<Reaction> reactions;
  List<Attachment> attachments;
  String sourceGuid;
  int? pinnedAt;
  String? pinnedBy;
  int createdAt;
  int? updatedAt;

  String? senderName;
  String? imageUrl;

  Message({
    this.id = '-1',
    required this.groupId,
    required this.senderId,
    this.system = false,
    required this.text,
    this.reactions = const [],
    this.attachments = const [],
    required this.sourceGuid,
    this.pinnedAt,
    this.pinnedBy,
    this.createdAt = 0,
    this.updatedAt,
    required this.senderName,
    required this.imageUrl,
  });

  factory Message.toSend(
    Me sender,
    String senderName,
    String groupId,
    String text,
  ) {
    return Message(
      groupId: groupId,
      senderId: sender.id,
      text: text,
      sourceGuid: "shouldBeUuid",
      senderName: senderName,
      imageUrl: sender.imageUrl,
    );
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    List<Reaction> reacts = [];
    List<Attachment> atts = [];
    for (var react in map['reactions'] ?? []) {
      reacts.add(Reaction.fromMap(react));
    }
    for (var att in map['attachments'] ?? []) {
      atts.add(Attachment.fromMap(att));
    }
    return Message(
      id: map['id'],
      groupId: map['group_id'],
      senderId: map['sender_id'],
      system: map['system'],
      text: map['text'],
      reactions: reacts,
      attachments: atts,
      sourceGuid: map['source_guid'],
      pinnedAt: map['pinned_at'],
      pinnedBy: map['pinned_by'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      senderName: map['name'],
      imageUrl: map['avatar_url'],
    );
  }

  factory Message.fromRow(List row) {
    List<Reaction> reacts = [];
    List<Attachment> atts = [];
    for (Map<String, dynamic> react in row[5] ?? []) {
      reacts.add(
        Reaction(react['unicode'], (react['user_ids'] as List).cast<String>()),
      );
    }
    for (Map<String, dynamic> att in row[6] ?? []) {
      atts.add(
        Attachment(att['type'], att['id'], lat: att['lat'], lng: att['lng']),
      );
    }
    return Message(
      id: row[0],
      groupId: row[1],
      senderId: row[2],
      system: row[3],
      text: row[4],
      reactions: reacts,
      attachments: atts,
      sourceGuid: row[7],
      pinnedAt: row[8],
      pinnedBy: row[9],
      createdAt: row[10],
      updatedAt: row[11],
      senderName: row[12],
      imageUrl: row[13],
    );
  }

  @override
  String toString() {
    return 'Message($id, $senderName, $text)';
  }
}

class Reaction {
  final String unicode;
  List<String> userIds;

  Reaction(this.unicode, this.userIds);

  factory Reaction.fromMap(Map<String, dynamic> map) {
    var userIds = (map['user_ids'] as List).cast<String>();
    if (map['type'] == 'unicode') {
      return Reaction(map['code'], userIds);
    } else {
      return Reaction('�', userIds);
    }
  }

  @override
  String toString() {
    return 'Reaction($unicode, $userIds)';
  }
}

class Attachment {
  final String type;
  final String id;
  final String? lat;
  final String? lng;

  Attachment(this.type, this.id, {this.lat, this.lng});

  factory Attachment.fromMap(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'image':
        return Attachment('image', map['url']);
      case 'reply':
        return Attachment('reply', map['reply_id']);
      case 'file':
        return Attachment('file', map['name']);
      case 'location':
        return Attachment(
          'location',
          map['name'],
          lat: map['lat'],
          lng: map['lng'],
        );
      default:
        return Attachment('unsupported', '');
    }
  }

  @override
  String toString() {
    return 'Attachment($type, $id, $lat, $lng)';
  }
}
