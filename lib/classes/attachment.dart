import 'package:realm/realm.dart';

part 'attachment.realm.dart';

@RealmModel(ObjectType.embeddedObject)
class $Attachment {
  late String type = '';
  late String? url;
  late String? fileId;

  @override
  String toString() {
    return 'Attachment: $type, url: $url, file: $fileId';
  }
}