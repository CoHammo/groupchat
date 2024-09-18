// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Chat extends $Chat with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Chat(
    String id, {
    int createdAt = 0,
    int updatedAt = 0,
    int unreadCount = 0,
    int messageCount = 0,
    OtherUser? otherUser,
    Iterable<Message> messages = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Chat>({
        'createdAt': 0,
        'updatedAt': 0,
        'unreadCount': 0,
        'messageCount': 0,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'unreadCount', unreadCount);
    RealmObjectBase.set(this, 'messageCount', messageCount);
    RealmObjectBase.set(this, 'otherUser', otherUser);
    RealmObjectBase.set<RealmList<Message>>(
        this, 'messages', RealmList<Message>(messages));
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
  int get unreadCount => RealmObjectBase.get<int>(this, 'unreadCount') as int;
  @override
  set unreadCount(int value) => RealmObjectBase.set(this, 'unreadCount', value);

  @override
  int get messageCount => RealmObjectBase.get<int>(this, 'messageCount') as int;
  @override
  set messageCount(int value) =>
      RealmObjectBase.set(this, 'messageCount', value);

  @override
  OtherUser? get otherUser =>
      RealmObjectBase.get<OtherUser>(this, 'otherUser') as OtherUser?;
  @override
  set otherUser(covariant OtherUser? value) =>
      RealmObjectBase.set(this, 'otherUser', value);

  @override
  RealmList<Message> get messages =>
      RealmObjectBase.get<Message>(this, 'messages') as RealmList<Message>;
  @override
  set messages(covariant RealmList<Message> value) =>
      throw RealmUnsupportedSetError();

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
      'unreadCount': unreadCount.toEJson(),
      'messageCount': messageCount.toEJson(),
      'otherUser': otherUser.toEJson(),
      'messages': messages.toEJson(),
    };
  }

  static EJsonValue _toEJson(Chat value) => value.toEJson();
  static Chat _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        Chat(
          fromEJson(id),
          createdAt: fromEJson(ejson['createdAt'], defaultValue: 0),
          updatedAt: fromEJson(ejson['updatedAt'], defaultValue: 0),
          unreadCount: fromEJson(ejson['unreadCount'], defaultValue: 0),
          messageCount: fromEJson(ejson['messageCount'], defaultValue: 0),
          otherUser: fromEJson(ejson['otherUser']),
          messages: fromEJson(ejson['messages']),
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
      SchemaProperty('unreadCount', RealmPropertyType.int),
      SchemaProperty('messageCount', RealmPropertyType.int),
      SchemaProperty('otherUser', RealmPropertyType.object,
          optional: true, linkTarget: 'OtherUser'),
      SchemaProperty('messages', RealmPropertyType.object,
          linkTarget: 'Message', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
