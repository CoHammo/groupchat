import 'dart:convert';

class User {
  static final List<String> columns = [];
  final List _row;

  String id;
  String name;
  String? imageUrl;
  String? bio;
  String? songUrl;
  List<String>? sharedGroups;

  User(this.id, this.name) : _row = [];

  User.fromRow(this._row)
    : id = _row[0],
      name = _row[1],
      imageUrl = _row[2],
      bio = _row[3],
      songUrl = _row[4],
      sharedGroups = _row[5];

  @override
  String toString() {
    var user = Map.fromIterables(columns, _row);
    return JsonEncoder.withIndent('  ').convert(user);
  }
}

class Member extends User {
  static final List<String> columns = [];

  String groupId;
  String memberId;
  String nickname;
  List<String> roles;
  bool muted;
  bool autokicked = false;

  Member.fromRow(List row)
    : groupId = row[2],
      memberId = row[3],
      nickname = row[4],
      roles = row[5],
      muted = row[6],
      super(row[0], row[1]) {
    imageUrl = _row[7];
    _row.clear();
    _row.addAll(row);
  }

  @override
  String toString() {
    var member = Map.fromIterables(columns, _row);
    return JsonEncoder.withIndent('  ').convert(member);
  }
}
