import 'package:realm/realm.dart';
import 'i_user.dart';
import 'other_user.dart';

part 'group_user.realm.dart';

@RealmModel(ObjectType.embeddedObject)
class $GroupUser implements IUser {
  @override
  String get id => otherUser?.id ?? '';
  @override
  set id(String i) {}

  @override
  String get name => otherUser?.name ?? '';
  @override
  set name(String newName) => otherUser?.name = newName;

  @override
  String get imageUrl => otherUser?.imageUrl ?? '';
  @override
  set imageUrl(String? url) => otherUser?.imageUrl = url;

  late String? nickname;

  late bool muted = false;

  late $OtherUser? otherUser;

  @override
  String toString() {
    return 'GroupUser: $nickname ($name), $id';
  }
}