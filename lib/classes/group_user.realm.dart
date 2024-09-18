// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_user.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class GroupUser extends $GroupUser
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  static var _defaultsSet = false;

  GroupUser({
    String? nickname,
    bool muted = false,
    OtherUser? otherUser,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<GroupUser>({
        'muted': false,
      });
    }
    RealmObjectBase.set(this, 'nickname', nickname);
    RealmObjectBase.set(this, 'muted', muted);
    RealmObjectBase.set(this, 'otherUser', otherUser);
  }

  GroupUser._();

  @override
  String? get nickname =>
      RealmObjectBase.get<String>(this, 'nickname') as String?;
  @override
  set nickname(String? value) => RealmObjectBase.set(this, 'nickname', value);

  @override
  bool get muted => RealmObjectBase.get<bool>(this, 'muted') as bool;
  @override
  set muted(bool value) => RealmObjectBase.set(this, 'muted', value);

  @override
  OtherUser? get otherUser =>
      RealmObjectBase.get<OtherUser>(this, 'otherUser') as OtherUser?;
  @override
  set otherUser(covariant OtherUser? value) =>
      RealmObjectBase.set(this, 'otherUser', value);

  @override
  Stream<RealmObjectChanges<GroupUser>> get changes =>
      RealmObjectBase.getChanges<GroupUser>(this);

  @override
  Stream<RealmObjectChanges<GroupUser>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<GroupUser>(this, keyPaths);

  @override
  GroupUser freeze() => RealmObjectBase.freezeObject<GroupUser>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'nickname': nickname.toEJson(),
      'muted': muted.toEJson(),
      'otherUser': otherUser.toEJson(),
    };
  }

  static EJsonValue _toEJson(GroupUser value) => value.toEJson();
  static GroupUser _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return GroupUser(
      nickname: fromEJson(ejson['nickname']),
      muted: fromEJson(ejson['muted'], defaultValue: false),
      otherUser: fromEJson(ejson['otherUser']),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(GroupUser._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.embeddedObject, GroupUser, 'GroupUser', [
      SchemaProperty('nickname', RealmPropertyType.string, optional: true),
      SchemaProperty('muted', RealmPropertyType.bool),
      SchemaProperty('otherUser', RealmPropertyType.object,
          optional: true, linkTarget: 'OtherUser'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
