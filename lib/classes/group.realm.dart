// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Group extends $Group with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Group(
    String id, {
    int createdAt = 0,
    int updatedAt = 0,
    int unreadCount = 0,
    int messageCount = 0,
    String name = '',
    String? description,
    String? imageUrl,
    String creatorUserId = '',
    Iterable<OtherUser> members = const [],
    Iterable<Message> messages = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Group>({
        'createdAt': 0,
        'updatedAt': 0,
        'unreadCount': 0,
        'messageCount': 0,
        'name': '',
        'creatorUserId': '',
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'unreadCount', unreadCount);
    RealmObjectBase.set(this, 'messageCount', messageCount);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'imageUrl', imageUrl);
    RealmObjectBase.set(this, 'creatorUserId', creatorUserId);
    RealmObjectBase.set<RealmList<OtherUser>>(
        this, 'members', RealmList<OtherUser>(members));
    RealmObjectBase.set<RealmList<Message>>(
        this, 'messages', RealmList<Message>(messages));
  }

  Group._();

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
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get imageUrl =>
      RealmObjectBase.get<String>(this, 'imageUrl') as String?;
  @override
  set imageUrl(String? value) => RealmObjectBase.set(this, 'imageUrl', value);

  @override
  String get creatorUserId =>
      RealmObjectBase.get<String>(this, 'creatorUserId') as String;
  @override
  set creatorUserId(String value) =>
      RealmObjectBase.set(this, 'creatorUserId', value);

  @override
  RealmList<OtherUser> get members =>
      RealmObjectBase.get<OtherUser>(this, 'members') as RealmList<OtherUser>;
  @override
  set members(covariant RealmList<OtherUser> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Message> get messages =>
      RealmObjectBase.get<Message>(this, 'messages') as RealmList<Message>;
  @override
  set messages(covariant RealmList<Message> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Group>> get changes =>
      RealmObjectBase.getChanges<Group>(this);

  @override
  Stream<RealmObjectChanges<Group>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Group>(this, keyPaths);

  @override
  Group freeze() => RealmObjectBase.freezeObject<Group>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
      'unreadCount': unreadCount.toEJson(),
      'messageCount': messageCount.toEJson(),
      'name': name.toEJson(),
      'description': description.toEJson(),
      'imageUrl': imageUrl.toEJson(),
      'creatorUserId': creatorUserId.toEJson(),
      'members': members.toEJson(),
      'messages': messages.toEJson(),
    };
  }

  static EJsonValue _toEJson(Group value) => value.toEJson();
  static Group _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        Group(
          fromEJson(id),
          createdAt: fromEJson(ejson['createdAt'], defaultValue: 0),
          updatedAt: fromEJson(ejson['updatedAt'], defaultValue: 0),
          unreadCount: fromEJson(ejson['unreadCount'], defaultValue: 0),
          messageCount: fromEJson(ejson['messageCount'], defaultValue: 0),
          name: fromEJson(ejson['name'], defaultValue: ''),
          description: fromEJson(ejson['description']),
          imageUrl: fromEJson(ejson['imageUrl']),
          creatorUserId: fromEJson(ejson['creatorUserId'], defaultValue: ''),
          members: fromEJson(ejson['members']),
          messages: fromEJson(ejson['messages']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Group._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Group, 'Group', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('createdAt', RealmPropertyType.int),
      SchemaProperty('updatedAt', RealmPropertyType.int),
      SchemaProperty('unreadCount', RealmPropertyType.int),
      SchemaProperty('messageCount', RealmPropertyType.int),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('imageUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('creatorUserId', RealmPropertyType.string),
      SchemaProperty('members', RealmPropertyType.object,
          linkTarget: 'OtherUser', collectionType: RealmCollectionType.list),
      SchemaProperty('messages', RealmPropertyType.object,
          linkTarget: 'Message', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
