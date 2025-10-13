import 'dart:convert';
import 'package:signals/signals_flutter.dart';

import 'message.dart';
import 'user.dart';

class Group {
  static final List<String> columns = [];
  final List _row;
  final ListSignal<Message> messages = listSignal([]);
  final ListSignal<Member> members = listSignal([]);

  String id;
  String name;
  String type = 'private';
  String? description;
  String? imageUrl;
  String? creatorUserId;
  int? createdAt;
  int? updatedAt;
  int? messageCount;
  String? lastMessageId;
  int? lastMessageCreatedAt;
  int? lastMessageUpdatedAt;
  String? themeName;
  bool requiresApproval = false;
  bool showJoinQuestion = false;
  String? joinQuestion;
  List<String> messageDeletionMode = [];
  String? shareUrl;
  String? shareQrCodeUrl;
  bool membersSaved = false;
  bool messagesSaved = false;

  Group(this.id, this.name) : _row = [];

  Group.fromRow(this._row)
    : id = _row[0],
      name = _row[1],
      type = _row[2],
      description = _row[3],
      imageUrl = _row[4],
      creatorUserId = _row[5],
      createdAt = _row[6],
      updatedAt = _row[7],
      messageCount = _row[8],
      lastMessageId = _row[9],
      lastMessageCreatedAt = _row[10],
      lastMessageUpdatedAt = _row[11],
      themeName = _row[12],
      requiresApproval = _row[13],
      showJoinQuestion = _row[14],
      joinQuestion = _row[15],
      messageDeletionMode = (_row[16] as List).cast<String>(),
      shareUrl = _row[17],
      shareQrCodeUrl = _row[18],
      membersSaved = _row[19],
      messagesSaved = _row[20];

  @override
  String toString() {
    var message = Map.fromIterables(columns, _row);
    return JsonEncoder.withIndent('  ').convert(message);
  }
}
