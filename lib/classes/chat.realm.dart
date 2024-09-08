// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Chat extends $Chat with RealmEntity, RealmObjectBase, RealmObject {
  Chat(
    String id,
    int createdAt,
    int updatedAt,
    int messageCount, {
    ChatUser? otherUser,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'messageCount', messageCount);
    RealmObjectBase.set(this, 'otherUser', otherUser);
  }

  Chat._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => throw RealmUnsupportedSetError();

  @override
  int get createdAt => RealmObjectBase.get<int>(this, 'createdAt') as int;
  @override
  set createdAt(int value) => RealmObjectBase.set(this, 'createdAt', value);

  @override
  int get updatedAt => RealmObjectBase.get<int>(this, 'updatedAt') as int;
  @override
  set updatedAt(int value) => RealmObjectBase.set(this, 'updatedAt', value);

  @override
  int get messageCount => RealmObjectBase.get<int>(this, 'messageCount') as int;
  @override
  set messageCount(int value) =>
      RealmObjectBase.set(this, 'messageCount', value);

  @override
  ChatUser? get otherUser =>
      RealmObjectBase.get<ChatUser>(this, 'otherUser') as ChatUser?;
  @override
  set otherUser(covariant ChatUser? value) =>
      RealmObjectBase.set(this, 'otherUser', value);

  @override
  Stream<RealmObjectChanges<Chat>> get changes =>
      RealmObjectBase.getChanges<Chat>(this);

  @override
  Stream<RealmObjectChanges<Chat>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Chat>(this, keyPaths);

  @override
  Chat freeze() => RealmObjectBase.freezeObject<Chat>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
      'messageCount': messageCount.toEJson(),
      'otherUser': otherUser.toEJson(),
    };
  }

  static EJsonValue _toEJson(Chat value) => value.toEJson();
  static Chat _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'createdAt': EJsonValue createdAt,
        'updatedAt': EJsonValue updatedAt,
        'messageCount': EJsonValue messageCount,
      } =>
        Chat(
          fromEJson(id),
          fromEJson(createdAt),
          fromEJson(updatedAt),
          fromEJson(messageCount),
          otherUser: fromEJson(ejson['otherUser']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Chat._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Chat, 'Chat', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('createdAt', RealmPropertyType.int),
      SchemaProperty('updatedAt', RealmPropertyType.int),
      SchemaProperty('messageCount', RealmPropertyType.int),
      SchemaProperty('otherUser', RealmPropertyType.object,
          optional: true, linkTarget: 'ChatUser'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
