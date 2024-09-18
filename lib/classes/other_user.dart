import 'package:realm/realm.dart';
import 'i_user.dart';

part 'other_user.realm.dart';

@RealmModel()
class $OtherUser implements IUser {
  @override
  @PrimaryKey()
  late final String id;

  @override
  late String name = '';

  @override
  late String? imageUrl;

  @override
  String toString() {
    return 'OtherUser: $name, $id';
  }
}