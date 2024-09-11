// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Group extends $Group with RealmEntity, RealmObjectBase, RealmObject {
  Group(
    String id,
    int createdAt,
    int updatedAt,
    int unreadCount,
    String name,
    String description,
    String creatorUserId, {
    String? imageUrl,
    Iterable<ChatUser> members = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'unreadCount', unreadCount);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'imageUrl', imageUrl);
    RealmObjectBase.set(this, 'creatorUserId', creatorUserId);
    RealmObjectBase.set<RealmList<ChatUser>>(
        this, 'members', RealmList<ChatUser>(members));
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
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get description =>
      RealmObjectBase.get<String>(this, 'description') as String;
  @override
  set description(String value) =>
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
  RealmList<ChatUser> get members =>
      RealmObjectBase.get<ChatUser>(this, 'members') as RealmList<ChatUser>;
  @override
  set members(covariant RealmList<ChatUser> value) =>
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
      'name': name.toEJson(),
      'description': description.toEJson(),
      'imageUrl': imageUrl.toEJson(),
      'creatorUserId': creatorUserId.toEJson(),
      'members': members.toEJson(),
    };
  }

  static EJsonValue _toEJson(Group value) => value.toEJson();
  static Group _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'createdAt': EJsonValue createdAt,
        'updatedAt': EJsonValue updatedAt,
        'unreadCount': EJsonValue unreadCount,
        'name': EJsonValue name,
        'description': EJsonValue description,
        'creatorUserId': EJsonValue creatorUserId,
      } =>
        Group(
          fromEJson(id),
          fromEJson(createdAt),
          fromEJson(updatedAt),
          fromEJson(unreadCount),
          fromEJson(name),
          fromEJson(description),
          fromEJson(creatorUserId),
          imageUrl: fromEJson(ejson['imageUrl']),
          members: fromEJson(ejson['members']),
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
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('description', RealmPropertyType.string),
      SchemaProperty('imageUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('creatorUserId', RealmPropertyType.string),
      SchemaProperty('members', RealmPropertyType.object,
          linkTarget: 'ChatUser', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
