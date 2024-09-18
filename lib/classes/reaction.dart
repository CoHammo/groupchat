import 'package:realm/realm.dart';

part 'reaction.realm.dart';

@RealmModel(ObjectType.embeddedObject)
class $Reaction {
  late String code = '';
  late String type = '';
  late List<String> users;

  @override
  String toString() {
    return 'Reaction: $code, $type\n$users';
  }
}