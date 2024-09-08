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

  late int messageCount;

  late $ChatUser? otherUser;

  @override
  String toString() {
    return 'Chat with ${otherUser?.name}';
  }
}
