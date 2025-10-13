import 'dart:convert';

class Me {
  static final List<String> columns = [];
  final List _row;

  final String id;
  String name;
  String? imageUrl;
  String phoneNumber;
  String email;
  String? bio;
  String? songUrl;
  int createdAt;
  int updatedAt;
  String shareUrl;
  String shareQrCodeUrl;

  Me.fromRow(this._row)
    : id = _row[0],
      name = _row[1],
      imageUrl = _row[2],
      phoneNumber = _row[3],
      email = _row[4],
      bio = _row[5],
      songUrl = _row[6],
      createdAt = _row[7],
      updatedAt = _row[8],
      shareUrl = _row[9],
      shareQrCodeUrl = _row[10];

  @override
  String toString() {
    var me = Map.fromIterables(columns, _row);
    return JsonEncoder.withIndent('  ').convert(me);
  }
}
