import 'package:realm/realm.dart';
import 'other_user.dart';
import 'i_conversation.dart';
import 'message.dart';

part 'chat.realm.dart';

@RealmModel()
class $Chat implements IConversation {
  @override
  @PrimaryKey()
  late final String id;

  @override
  late int createdAt = 0;

  @override
  late int updatedAt = 0;

  @override
  late int unreadCount = 0;

  @override
  late int messageCount = 0;

  late $OtherUser? otherUser;

  late List<$Message> messages;

  String get name => otherUser?.name ?? '';

  String get description => 'Chat with ${otherUser?.name}';

  @override
  String toString() {
    return 'Chat: $name, $messageCount messages';
  }
}
