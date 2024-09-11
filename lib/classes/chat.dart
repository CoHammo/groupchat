import 'package:realm/realm.dart';
import 'chat_user.dart';
import 'i_conversation.dart';

part 'chat.realm.dart';

@RealmModel()
class $Chat implements IConversation {
  @override
  @PrimaryKey()
  late final String id;

  @override
  late int createdAt;

  @override
  late int updatedAt;

  @override
  late int unreadCount;

  late int messageCount;

  late $ChatUser? otherUser;

  String get name => otherUser?.name ?? '';

  String get description => 'Chat with ${otherUser?.name}';

  @override
  String toString() {
    return 'Chat with ${otherUser?.name}';
  }
}
