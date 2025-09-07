// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Reaction extends $Reaction
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  static var _defaultsSet = false;

  Reaction({
    String? code = '',
    String type = '',
    Iterable<String> users = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Reaction>({
        'code': '',
        'type': '',
      });
    }
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set<RealmList<String>>(
        this, 'users', RealmList<String>(users));
  }

  Reaction._();

  @override
  String? get code => RealmObjectBase.get<String>(this, 'code') as String?;
  @override
  set code(String? value) => RealmObjectBase.set(this, 'code', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  RealmList<String> get users =>
      RealmObjectBase.get<String>(this, 'users') as RealmList<String>;
  @override
  set users(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Reaction>> get changes =>
      RealmObjectBase.getChanges<Reaction>(this);

  @override
  Stream<RealmObjectChanges<Reaction>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Reaction>(this, keyPaths);

  @override
  Reaction freeze() => RealmObjectBase.freezeObject<Reaction>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'type': type.toEJson(),
      'users': users.toEJson(),
    };
  }

  static EJsonValue _toEJson(Reaction value) => value.toEJson();
  static Reaction _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return Reaction(
      code: fromEJson(ejson['code'], defaultValue: ''),
      type: fromEJson(ejson['type'], defaultValue: ''),
      users: fromEJson(ejson['users']),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Reaction._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.embeddedObject, Reaction, 'Reaction', [
      SchemaProperty('code', RealmPropertyType.string, optional: true),
      SchemaProperty('type', RealmPropertyType.string),
      SchemaProperty('users', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
