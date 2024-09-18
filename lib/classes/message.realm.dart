// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Message extends $Message with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Message(
    String id, {
    String senderId = '',
    String? text,
    int createdAt = 0,
    bool system = false,
    Iterable<Attachment> attachments = const [],
    Iterable<Reaction> reactions = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Message>({
        'senderId': '',
        'createdAt': 0,
        'system': false,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'senderId', senderId);
    RealmObjectBase.set(this, 'text', text);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'system', system);
    RealmObjectBase.set<RealmList<Attachment>>(
        this, 'attachments', RealmList<Attachment>(attachments));
    RealmObjectBase.set<RealmList<Reaction>>(
        this, 'reactions', RealmList<Reaction>(reactions));
  }

  Message._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => throw RealmUnsupportedSetError();

  @override
  String get senderId =>
      RealmObjectBase.get<String>(this, 'senderId') as String;
  @override
  set senderId(String value) => throw RealmUnsupportedSetError();

  @override
  String? get text => RealmObjectBase.get<String>(this, 'text') as String?;
  @override
  set text(String? value) => RealmObjectBase.set(this, 'text', value);

  @override
  int get createdAt => RealmObjectBase.get<int>(this, 'createdAt') as int;
  @override
  set createdAt(int value) => throw RealmUnsupportedSetError();

  @override
  bool get system => RealmObjectBase.get<bool>(this, 'system') as bool;
  @override
  set system(bool value) => throw RealmUnsupportedSetError();

  @override
  RealmList<Attachment> get attachments =>
      RealmObjectBase.get<Attachment>(this, 'attachments')
          as RealmList<Attachment>;
  @override
  set attachments(covariant RealmList<Attachment> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<Reaction> get reactions =>
      RealmObjectBase.get<Reaction>(this, 'reactions') as RealmList<Reaction>;
  @override
  set reactions(covariant RealmList<Reaction> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Message>> get changes =>
      RealmObjectBase.getChanges<Message>(this);

  @override
  Stream<RealmObjectChanges<Message>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Message>(this, keyPaths);

  @override
  Message freeze() => RealmObjectBase.freezeObject<Message>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'senderId': senderId.toEJson(),
      'text': text.toEJson(),
      'createdAt': createdAt.toEJson(),
      'system': system.toEJson(),
      'attachments': attachments.toEJson(),
      'reactions': reactions.toEJson(),
    };
  }

  static EJsonValue _toEJson(Message value) => value.toEJson();
  static Message _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        Message(
          fromEJson(id),
          senderId: fromEJson(ejson['senderId'], defaultValue: ''),
          text: fromEJson(ejson['text']),
          createdAt: fromEJson(ejson['createdAt'], defaultValue: 0),
          system: fromEJson(ejson['system'], defaultValue: false),
          attachments: fromEJson(ejson['attachments']),
          reactions: fromEJson(ejson['reactions']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Message._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Message, 'Message', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('senderId', RealmPropertyType.string),
      SchemaProperty('text', RealmPropertyType.string, optional: true),
      SchemaProperty('createdAt', RealmPropertyType.int),
      SchemaProperty('system', RealmPropertyType.bool),
      SchemaProperty('attachments', RealmPropertyType.object,
          linkTarget: 'Attachment', collectionType: RealmCollectionType.list),
      SchemaProperty('reactions', RealmPropertyType.object,
          linkTarget: 'Reaction', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
