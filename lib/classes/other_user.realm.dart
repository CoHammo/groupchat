// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_user.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class OtherUser extends $OtherUser
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  OtherUser(
    String id, {
    String name = '',
    String? imageUrl,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<OtherUser>({
        'name': '',
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'imageUrl', imageUrl);
  }

  OtherUser._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => throw RealmUnsupportedSetError();

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
  Stream<RealmObjectChanges<OtherUser>> get changes =>
      RealmObjectBase.getChanges<OtherUser>(this);

  @override
  Stream<RealmObjectChanges<OtherUser>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<OtherUser>(this, keyPaths);

  @override
  OtherUser freeze() => RealmObjectBase.freezeObject<OtherUser>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'imageUrl': imageUrl.toEJson(),
    };
  }

  static EJsonValue _toEJson(OtherUser value) => value.toEJson();
  static OtherUser _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        OtherUser(
          fromEJson(id),
          name: fromEJson(ejson['name'], defaultValue: ''),
          imageUrl: fromEJson(ejson['imageUrl']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(OtherUser._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, OtherUser, 'OtherUser', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('imageUrl', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
