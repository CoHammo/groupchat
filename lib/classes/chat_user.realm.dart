// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_user.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class ChatUser extends $ChatUser
    with RealmEntity, RealmObjectBase, RealmObject {
  ChatUser(
    String id,
    String name,
    String nickname,
    bool muted, {
    String? imageUrl,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'imageUrl', imageUrl);
    RealmObjectBase.set(this, 'nickname', nickname);
    RealmObjectBase.set(this, 'muted', muted);
  }

  ChatUser._();

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
  String get nickname =>
      RealmObjectBase.get<String>(this, 'nickname') as String;
  @override
  set nickname(String value) => RealmObjectBase.set(this, 'nickname', value);

  @override
  bool get muted => RealmObjectBase.get<bool>(this, 'muted') as bool;
  @override
  set muted(bool value) => RealmObjectBase.set(this, 'muted', value);

  @override
  Stream<RealmObjectChanges<ChatUser>> get changes =>
      RealmObjectBase.getChanges<ChatUser>(this);

  @override
  Stream<RealmObjectChanges<ChatUser>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ChatUser>(this, keyPaths);

  @override
  ChatUser freeze() => RealmObjectBase.freezeObject<ChatUser>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'imageUrl': imageUrl.toEJson(),
      'nickname': nickname.toEJson(),
      'muted': muted.toEJson(),
    };
  }

  static EJsonValue _toEJson(ChatUser value) => value.toEJson();
  static ChatUser _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'nickname': EJsonValue nickname,
        'muted': EJsonValue muted,
      } =>
        ChatUser(
          fromEJson(id),
          fromEJson(name),
          fromEJson(nickname),
          fromEJson(muted),
          imageUrl: fromEJson(ejson['imageUrl']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ChatUser._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, ChatUser, 'ChatUser', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('imageUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('nickname', RealmPropertyType.string),
      SchemaProperty('muted', RealmPropertyType.bool),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
