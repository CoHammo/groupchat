import 'package:realm/realm.dart';

part 'reaction.realm.dart';

@RealmModel(ObjectType.embeddedObject)
class $Reaction {
  late String type = '';
  late String? code = '';
  late List<String> users;

  @override
  String toString() {
    return 'Reaction: $code, $type\n$users';
  }
}