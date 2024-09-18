import 'package:realm/realm.dart';
import 'attachment.dart';
import 'reaction.dart';

part 'message.realm.dart';

@RealmModel()
class $Message {

  @PrimaryKey()
  late final String id;

  late final String senderId = '';

  late String? text;

  late final int createdAt = 0;

  late final bool system = false;

  late List<$Attachment> attachments;

  late List<$Reaction> reactions;

  @override
  String toString() {
    return 'Message: $id, $text, ${attachments.length} attachments, ${reactions.length} reactions';
  }
}