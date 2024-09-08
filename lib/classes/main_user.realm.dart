// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_user.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class MainUser extends $MainUser
    with RealmEntity, RealmObjectBase, RealmObject {
  MainUser(
    String id,
    String name, {
    String? imageUrl,
    String? email,
    String? shareUrl,
    String? shareQrCodeUrl,
    String? bio,
    String? locale,
    String? phoneNumber,
    int? createdAt,
    int? updatedAt,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'imageUrl', imageUrl);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'shareUrl', shareUrl);
    RealmObjectBase.set(this, 'shareQrCodeUrl', shareQrCodeUrl);
    RealmObjectBase.set(this, 'bio', bio);
    RealmObjectBase.set(this, 'locale', locale);
    RealmObjectBase.set(this, 'phoneNumber', phoneNumber);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
  }

  MainUser._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get imageUrl =>
      RealmObjectBase.get<String>(this, 'imageUrl') as String?;
  @override
  set imageUrl(String? value) => RealmObjectBase.set(this, 'imageUrl', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get shareUrl =>
      RealmObjectBase.get<String>(this, 'shareUrl') as String?;
  @override
  set shareUrl(String? value) => RealmObjectBase.set(this, 'shareUrl', value);

  @override
  String? get shareQrCodeUrl =>
      RealmObjectBase.get<String>(this, 'shareQrCodeUrl') as String?;
  @override
  set shareQrCodeUrl(String? value) =>
      RealmObjectBase.set(this, 'shareQrCodeUrl', value);

  @override
  String? get bio => RealmObjectBase.get<String>(this, 'bio') as String?;
  @override
  set bio(String? value) => RealmObjectBase.set(this, 'bio', value);

  @override
  String? get locale => RealmObjectBase.get<String>(this, 'locale') as String?;
  @override
  set locale(String? value) => RealmObjectBase.set(this, 'locale', value);

  @override
  String? get phoneNumber =>
      RealmObjectBase.get<String>(this, 'phoneNumber') as String?;
  @override
  set phoneNumber(String? value) =>
      RealmObjectBase.set(this, 'phoneNumber', value);

  @override
  int? get createdAt => RealmObjectBase.get<int>(this, 'createdAt') as int?;
  @override
  set createdAt(int? value) => RealmObjectBase.set(this, 'createdAt', value);

  @override
  int? get updatedAt => RealmObjectBase.get<int>(this, 'updatedAt') as int?;
  @override
  set updatedAt(int? value) => RealmObjectBase.set(this, 'updatedAt', value);

  @override
  Stream<RealmObjectChanges<MainUser>> get changes =>
      RealmObjectBase.getChanges<MainUser>(this);

  @override
  Stream<RealmObjectChanges<MainUser>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<MainUser>(this, keyPaths);

  @override
  MainUser freeze() => RealmObjectBase.freezeObject<MainUser>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'imageUrl': imageUrl.toEJson(),
      'email': email.toEJson(),
      'shareUrl': shareUrl.toEJson(),
      'shareQrCodeUrl': shareQrCodeUrl.toEJson(),
      'bio': bio.toEJson(),
      'locale': locale.toEJson(),
      'phoneNumber': phoneNumber.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(MainUser value) => value.toEJson();
  static MainUser _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
      } =>
        MainUser(
          fromEJson(id),
          fromEJson(name),
          imageUrl: fromEJson(ejson['imageUrl']),
          email: fromEJson(ejson['email']),
          shareUrl: fromEJson(ejson['shareUrl']),
          shareQrCodeUrl: fromEJson(ejson['shareQrCodeUrl']),
          bio: fromEJson(ejson['bio']),
          locale: fromEJson(ejson['locale']),
          phoneNumber: fromEJson(ejson['phoneNumber']),
          createdAt: fromEJson(ejson['createdAt']),
          updatedAt: fromEJson(ejson['updatedAt']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(MainUser._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, MainUser, 'MainUser', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('imageUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('email', RealmPropertyType.string, optional: true),
      SchemaProperty('shareUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('shareQrCodeUrl', RealmPropertyType.string,
          optional: true),
      SchemaProperty('bio', RealmPropertyType.string, optional: true),
      SchemaProperty('locale', RealmPropertyType.string, optional: true),
      SchemaProperty('phoneNumber', RealmPropertyType.string, optional: true),
      SchemaProperty('createdAt', RealmPropertyType.int, optional: true),
      SchemaProperty('updatedAt', RealmPropertyType.int, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
