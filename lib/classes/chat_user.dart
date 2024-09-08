import 'package:realm/realm.dart';
import 'i_user.dart';

part 'chat_user.realm.dart';

@RealmModel()
class $ChatUser implements IUser {
  @override
  @PrimaryKey()
  late String id;

  @override
  late String name;

  @override
  late String? imageUrl;

  late String nickname;

  late bool muted;

  @override
  String toString() {
    return 'ChatUser: $nickname, $id';
  }
}