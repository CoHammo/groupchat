// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StateChange {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StateChange);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StateChange()';
}


}

/// @nodoc
class $StateChangeCopyWith<$Res>  {
$StateChangeCopyWith(StateChange _, $Res Function(StateChange) __);
}


/// Adds pattern-matching-related methods to [StateChange].
extension StateChangePatterns on StateChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( StateChange_Login value)?  login,TResult Function( StateChange_Logout value)?  logout,TResult Function( StateChange_Me value)?  me,TResult Function( StateChange_Groups value)?  groups,TResult Function( StateChange_Group value)?  group,required TResult orElse(),}){
final _that = this;
switch (_that) {
case StateChange_Login() when login != null:
return login(_that);case StateChange_Logout() when logout != null:
return logout(_that);case StateChange_Me() when me != null:
return me(_that);case StateChange_Groups() when groups != null:
return groups(_that);case StateChange_Group() when group != null:
return group(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( StateChange_Login value)  login,required TResult Function( StateChange_Logout value)  logout,required TResult Function( StateChange_Me value)  me,required TResult Function( StateChange_Groups value)  groups,required TResult Function( StateChange_Group value)  group,}){
final _that = this;
switch (_that) {
case StateChange_Login():
return login(_that);case StateChange_Logout():
return logout(_that);case StateChange_Me():
return me(_that);case StateChange_Groups():
return groups(_that);case StateChange_Group():
return group(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( StateChange_Login value)?  login,TResult? Function( StateChange_Logout value)?  logout,TResult? Function( StateChange_Me value)?  me,TResult? Function( StateChange_Groups value)?  groups,TResult? Function( StateChange_Group value)?  group,}){
final _that = this;
switch (_that) {
case StateChange_Login() when login != null:
return login(_that);case StateChange_Logout() when logout != null:
return logout(_that);case StateChange_Me() when me != null:
return me(_that);case StateChange_Groups() when groups != null:
return groups(_that);case StateChange_Group() when group != null:
return group(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  login,TResult Function()?  logout,TResult Function()?  me,TResult Function()?  groups,TResult Function( String field0)?  group,required TResult orElse(),}) {final _that = this;
switch (_that) {
case StateChange_Login() when login != null:
return login();case StateChange_Logout() when logout != null:
return logout();case StateChange_Me() when me != null:
return me();case StateChange_Groups() when groups != null:
return groups();case StateChange_Group() when group != null:
return group(_that.field0);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  login,required TResult Function()  logout,required TResult Function()  me,required TResult Function()  groups,required TResult Function( String field0)  group,}) {final _that = this;
switch (_that) {
case StateChange_Login():
return login();case StateChange_Logout():
return logout();case StateChange_Me():
return me();case StateChange_Groups():
return groups();case StateChange_Group():
return group(_that.field0);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  login,TResult? Function()?  logout,TResult? Function()?  me,TResult? Function()?  groups,TResult? Function( String field0)?  group,}) {final _that = this;
switch (_that) {
case StateChange_Login() when login != null:
return login();case StateChange_Logout() when logout != null:
return logout();case StateChange_Me() when me != null:
return me();case StateChange_Groups() when groups != null:
return groups();case StateChange_Group() when group != null:
return group(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class StateChange_Login extends StateChange {
  const StateChange_Login(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StateChange_Login);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StateChange.login()';
}


}




/// @nodoc


class StateChange_Logout extends StateChange {
  const StateChange_Logout(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StateChange_Logout);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StateChange.logout()';
}


}




/// @nodoc


class StateChange_Me extends StateChange {
  const StateChange_Me(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StateChange_Me);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StateChange.me()';
}


}




/// @nodoc


class StateChange_Groups extends StateChange {
  const StateChange_Groups(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StateChange_Groups);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'StateChange.groups()';
}


}




/// @nodoc


class StateChange_Group extends StateChange {
  const StateChange_Group(this.field0): super._();
  

 final  String field0;

/// Create a copy of StateChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StateChange_GroupCopyWith<StateChange_Group> get copyWith => _$StateChange_GroupCopyWithImpl<StateChange_Group>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StateChange_Group&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'StateChange.group(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $StateChange_GroupCopyWith<$Res> implements $StateChangeCopyWith<$Res> {
  factory $StateChange_GroupCopyWith(StateChange_Group value, $Res Function(StateChange_Group) _then) = _$StateChange_GroupCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$StateChange_GroupCopyWithImpl<$Res>
    implements $StateChange_GroupCopyWith<$Res> {
  _$StateChange_GroupCopyWithImpl(this._self, this._then);

  final StateChange_Group _self;
  final $Res Function(StateChange_Group) _then;

/// Create a copy of StateChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(StateChange_Group(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
