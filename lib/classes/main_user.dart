import 'package:realm/realm.dart';
import 'i_user.dart';

part 'main_user.realm.dart';

@RealmModel()
class $MainUser implements IUser {
  @override
  @PrimaryKey()
  late String id;

  @override
  late String name = '';

  @override
  late String? imageUrl;

  late String? email;

  late String? shareUrl;

  late String? shareQrCodeUrl;

  late String? bio;

  late String? locale;

  late String? phoneNumber;

  late int createdAt = 0;

  late int updatedAt = 0;

  @override
  String toString() {
    return 'MainUser: $name, $id';
  }
}
