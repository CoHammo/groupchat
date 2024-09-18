// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Attachment extends $Attachment
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  static var _defaultsSet = false;

  Attachment({
    String type = '',
    String? url,
    String? fileId,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Attachment>({
        'type': '',
      });
    }
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'url', url);
    RealmObjectBase.set(this, 'fileId', fileId);
  }

  Attachment._();

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  String? get url => RealmObjectBase.get<String>(this, 'url') as String?;
  @override
  set url(String? value) => RealmObjectBase.set(this, 'url', value);

  @override
  String? get fileId => RealmObjectBase.get<String>(this, 'fileId') as String?;
  @override
  set fileId(String? value) => RealmObjectBase.set(this, 'fileId', value);

  @override
  Stream<RealmObjectChanges<Attachment>> get changes =>
      RealmObjectBase.getChanges<Attachment>(this);

  @override
  Stream<RealmObjectChanges<Attachment>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Attachment>(this, keyPaths);

  @override
  Attachment freeze() => RealmObjectBase.freezeObject<Attachment>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'type': type.toEJson(),
      'url': url.toEJson(),
      'fileId': fileId.toEJson(),
    };
  }

  static EJsonValue _toEJson(Attachment value) => value.toEJson();
  static Attachment _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return Attachment(
      type: fromEJson(ejson['type'], defaultValue: ''),
      url: fromEJson(ejson['url']),
      fileId: fromEJson(ejson['fileId']),
    );
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Attachment._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.embeddedObject, Attachment, 'Attachment', [
      SchemaProperty('type', RealmPropertyType.string),
      SchemaProperty('url', RealmPropertyType.string, optional: true),
      SchemaProperty('fileId', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
