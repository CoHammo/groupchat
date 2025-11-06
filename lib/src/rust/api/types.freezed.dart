// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Attachment {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attachment);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Attachment()';
}


}

/// @nodoc
class $AttachmentCopyWith<$Res>  {
$AttachmentCopyWith(Attachment _, $Res Function(Attachment) __);
}


/// Adds pattern-matching-related methods to [Attachment].
extension AttachmentPatterns on Attachment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Attachment_Image value)?  image,TResult Function( Attachment_Reply value)?  reply,TResult Function( Attachment_File value)?  file,TResult Function( Attachment_Location value)?  location,TResult Function( Attachment_Event value)?  event,TResult Function( Attachment_Unsupported value)?  unsupported,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Attachment_Image() when image != null:
return image(_that);case Attachment_Reply() when reply != null:
return reply(_that);case Attachment_File() when file != null:
return file(_that);case Attachment_Location() when location != null:
return location(_that);case Attachment_Event() when event != null:
return event(_that);case Attachment_Unsupported() when unsupported != null:
return unsupported(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Attachment_Image value)  image,required TResult Function( Attachment_Reply value)  reply,required TResult Function( Attachment_File value)  file,required TResult Function( Attachment_Location value)  location,required TResult Function( Attachment_Event value)  event,required TResult Function( Attachment_Unsupported value)  unsupported,}){
final _that = this;
switch (_that) {
case Attachment_Image():
return image(_that);case Attachment_Reply():
return reply(_that);case Attachment_File():
return file(_that);case Attachment_Location():
return location(_that);case Attachment_Event():
return event(_that);case Attachment_Unsupported():
return unsupported(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Attachment_Image value)?  image,TResult? Function( Attachment_Reply value)?  reply,TResult? Function( Attachment_File value)?  file,TResult? Function( Attachment_Location value)?  location,TResult? Function( Attachment_Event value)?  event,TResult? Function( Attachment_Unsupported value)?  unsupported,}){
final _that = this;
switch (_that) {
case Attachment_Image() when image != null:
return image(_that);case Attachment_Reply() when reply != null:
return reply(_that);case Attachment_File() when file != null:
return file(_that);case Attachment_Location() when location != null:
return location(_that);case Attachment_Event() when event != null:
return event(_that);case Attachment_Unsupported() when unsupported != null:
return unsupported(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String url)?  image,TResult Function( String messageId)?  reply,TResult Function( String fileId)?  file,TResult Function( String name,  String lat,  String lng)?  location,TResult Function( String eventId)?  event,TResult Function( String field0)?  unsupported,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Attachment_Image() when image != null:
return image(_that.url);case Attachment_Reply() when reply != null:
return reply(_that.messageId);case Attachment_File() when file != null:
return file(_that.fileId);case Attachment_Location() when location != null:
return location(_that.name,_that.lat,_that.lng);case Attachment_Event() when event != null:
return event(_that.eventId);case Attachment_Unsupported() when unsupported != null:
return unsupported(_that.field0);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String url)  image,required TResult Function( String messageId)  reply,required TResult Function( String fileId)  file,required TResult Function( String name,  String lat,  String lng)  location,required TResult Function( String eventId)  event,required TResult Function( String field0)  unsupported,}) {final _that = this;
switch (_that) {
case Attachment_Image():
return image(_that.url);case Attachment_Reply():
return reply(_that.messageId);case Attachment_File():
return file(_that.fileId);case Attachment_Location():
return location(_that.name,_that.lat,_that.lng);case Attachment_Event():
return event(_that.eventId);case Attachment_Unsupported():
return unsupported(_that.field0);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String url)?  image,TResult? Function( String messageId)?  reply,TResult? Function( String fileId)?  file,TResult? Function( String name,  String lat,  String lng)?  location,TResult? Function( String eventId)?  event,TResult? Function( String field0)?  unsupported,}) {final _that = this;
switch (_that) {
case Attachment_Image() when image != null:
return image(_that.url);case Attachment_Reply() when reply != null:
return reply(_that.messageId);case Attachment_File() when file != null:
return file(_that.fileId);case Attachment_Location() when location != null:
return location(_that.name,_that.lat,_that.lng);case Attachment_Event() when event != null:
return event(_that.eventId);case Attachment_Unsupported() when unsupported != null:
return unsupported(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class Attachment_Image extends Attachment {
  const Attachment_Image({required this.url}): super._();
  

 final  String url;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Attachment_ImageCopyWith<Attachment_Image> get copyWith => _$Attachment_ImageCopyWithImpl<Attachment_Image>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attachment_Image&&(identical(other.url, url) || other.url == url));
}


@override
int get hashCode => Object.hash(runtimeType,url);

@override
String toString() {
  return 'Attachment.image(url: $url)';
}


}

/// @nodoc
abstract mixin class $Attachment_ImageCopyWith<$Res> implements $AttachmentCopyWith<$Res> {
  factory $Attachment_ImageCopyWith(Attachment_Image value, $Res Function(Attachment_Image) _then) = _$Attachment_ImageCopyWithImpl;
@useResult
$Res call({
 String url
});




}
/// @nodoc
class _$Attachment_ImageCopyWithImpl<$Res>
    implements $Attachment_ImageCopyWith<$Res> {
  _$Attachment_ImageCopyWithImpl(this._self, this._then);

  final Attachment_Image _self;
  final $Res Function(Attachment_Image) _then;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? url = null,}) {
  return _then(Attachment_Image(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Attachment_Reply extends Attachment {
  const Attachment_Reply({required this.messageId}): super._();
  

 final  String messageId;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Attachment_ReplyCopyWith<Attachment_Reply> get copyWith => _$Attachment_ReplyCopyWithImpl<Attachment_Reply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attachment_Reply&&(identical(other.messageId, messageId) || other.messageId == messageId));
}


@override
int get hashCode => Object.hash(runtimeType,messageId);

@override
String toString() {
  return 'Attachment.reply(messageId: $messageId)';
}


}

/// @nodoc
abstract mixin class $Attachment_ReplyCopyWith<$Res> implements $AttachmentCopyWith<$Res> {
  factory $Attachment_ReplyCopyWith(Attachment_Reply value, $Res Function(Attachment_Reply) _then) = _$Attachment_ReplyCopyWithImpl;
@useResult
$Res call({
 String messageId
});




}
/// @nodoc
class _$Attachment_ReplyCopyWithImpl<$Res>
    implements $Attachment_ReplyCopyWith<$Res> {
  _$Attachment_ReplyCopyWithImpl(this._self, this._then);

  final Attachment_Reply _self;
  final $Res Function(Attachment_Reply) _then;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messageId = null,}) {
  return _then(Attachment_Reply(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Attachment_File extends Attachment {
  const Attachment_File({required this.fileId}): super._();
  

 final  String fileId;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Attachment_FileCopyWith<Attachment_File> get copyWith => _$Attachment_FileCopyWithImpl<Attachment_File>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attachment_File&&(identical(other.fileId, fileId) || other.fileId == fileId));
}


@override
int get hashCode => Object.hash(runtimeType,fileId);

@override
String toString() {
  return 'Attachment.file(fileId: $fileId)';
}


}

/// @nodoc
abstract mixin class $Attachment_FileCopyWith<$Res> implements $AttachmentCopyWith<$Res> {
  factory $Attachment_FileCopyWith(Attachment_File value, $Res Function(Attachment_File) _then) = _$Attachment_FileCopyWithImpl;
@useResult
$Res call({
 String fileId
});




}
/// @nodoc
class _$Attachment_FileCopyWithImpl<$Res>
    implements $Attachment_FileCopyWith<$Res> {
  _$Attachment_FileCopyWithImpl(this._self, this._then);

  final Attachment_File _self;
  final $Res Function(Attachment_File) _then;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fileId = null,}) {
  return _then(Attachment_File(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Attachment_Location extends Attachment {
  const Attachment_Location({required this.name, required this.lat, required this.lng}): super._();
  

 final  String name;
 final  String lat;
 final  String lng;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Attachment_LocationCopyWith<Attachment_Location> get copyWith => _$Attachment_LocationCopyWithImpl<Attachment_Location>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attachment_Location&&(identical(other.name, name) || other.name == name)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}


@override
int get hashCode => Object.hash(runtimeType,name,lat,lng);

@override
String toString() {
  return 'Attachment.location(name: $name, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class $Attachment_LocationCopyWith<$Res> implements $AttachmentCopyWith<$Res> {
  factory $Attachment_LocationCopyWith(Attachment_Location value, $Res Function(Attachment_Location) _then) = _$Attachment_LocationCopyWithImpl;
@useResult
$Res call({
 String name, String lat, String lng
});




}
/// @nodoc
class _$Attachment_LocationCopyWithImpl<$Res>
    implements $Attachment_LocationCopyWith<$Res> {
  _$Attachment_LocationCopyWithImpl(this._self, this._then);

  final Attachment_Location _self;
  final $Res Function(Attachment_Location) _then;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,Object? lat = null,Object? lng = null,}) {
  return _then(Attachment_Location(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as String,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Attachment_Event extends Attachment {
  const Attachment_Event({required this.eventId}): super._();
  

 final  String eventId;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Attachment_EventCopyWith<Attachment_Event> get copyWith => _$Attachment_EventCopyWithImpl<Attachment_Event>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attachment_Event&&(identical(other.eventId, eventId) || other.eventId == eventId));
}


@override
int get hashCode => Object.hash(runtimeType,eventId);

@override
String toString() {
  return 'Attachment.event(eventId: $eventId)';
}


}

/// @nodoc
abstract mixin class $Attachment_EventCopyWith<$Res> implements $AttachmentCopyWith<$Res> {
  factory $Attachment_EventCopyWith(Attachment_Event value, $Res Function(Attachment_Event) _then) = _$Attachment_EventCopyWithImpl;
@useResult
$Res call({
 String eventId
});




}
/// @nodoc
class _$Attachment_EventCopyWithImpl<$Res>
    implements $Attachment_EventCopyWith<$Res> {
  _$Attachment_EventCopyWithImpl(this._self, this._then);

  final Attachment_Event _self;
  final $Res Function(Attachment_Event) _then;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? eventId = null,}) {
  return _then(Attachment_Event(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Attachment_Unsupported extends Attachment {
  const Attachment_Unsupported(this.field0): super._();
  

 final  String field0;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Attachment_UnsupportedCopyWith<Attachment_Unsupported> get copyWith => _$Attachment_UnsupportedCopyWithImpl<Attachment_Unsupported>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attachment_Unsupported&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'Attachment.unsupported(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $Attachment_UnsupportedCopyWith<$Res> implements $AttachmentCopyWith<$Res> {
  factory $Attachment_UnsupportedCopyWith(Attachment_Unsupported value, $Res Function(Attachment_Unsupported) _then) = _$Attachment_UnsupportedCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$Attachment_UnsupportedCopyWithImpl<$Res>
    implements $Attachment_UnsupportedCopyWith<$Res> {
  _$Attachment_UnsupportedCopyWithImpl(this._self, this._then);

  final Attachment_Unsupported _self;
  final $Res Function(Attachment_Unsupported) _then;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(Attachment_Unsupported(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
