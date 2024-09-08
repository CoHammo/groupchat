import 'package:realm/realm.dart';
import 'chat_user.dart';
import 'i_conversation.dart';

part 'group.realm.dart';

@RealmModel()
class $Group implements IConversation {
  @override
  @PrimaryKey()
  late final String id;

  @override
  late int createdAt;

  @override
  late int updatedAt;

  late String name;

  late String description;

  late String? imageUrl;

  late String creatorUserId;

  late List<$ChatUser> members;

  @override
  String toString() {
    return 'Group: $name';
  }
}