import 'package:realm/realm.dart';

part 'message.realm.dart';

@RealmModel()
class $Message {

  @PrimaryKey()
  late final String id;

  late String content;
}