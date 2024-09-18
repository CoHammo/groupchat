import 'package:realm/realm.dart';
import 'other_user.dart';
import 'i_conversation.dart';
import 'message.dart';

part 'group.realm.dart';

@RealmModel()
class $Group implements IConversation {
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

  late String name = '';

  late String? description;

  late String? imageUrl;

  late String creatorUserId = '';

  late List<$OtherUser> members;

  late List<$Message> messages;

  @override
  String toString() {
    return 'Group: $name, ${members.length} members, ${messages.length} messages';
  }
}