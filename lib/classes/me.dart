class Me {
  static final List<String> columns = [];

  final String id;
  String name;
  String? imageUrl;
  String phoneNumber;
  String email;
  String? bio;
  String? songUrl;
  String locale;
  int createdAt;
  int updatedAt;
  String shareUrl;
  String shareQrCodeUrl;

  Me({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.phoneNumber,
    required this.email,
    required this.bio,
    required this.songUrl,
    required this.locale,
    required this.createdAt,
    required this.updatedAt,
    required this.shareUrl,
    required this.shareQrCodeUrl,
  });

  factory Me.fromMap(Map<String, dynamic> map) {
    return Me(
      id: map['id'],
      name: map['name'],
      imageUrl: map['image_url'],
      phoneNumber: map['phone_number'],
      email: map['email'],
      bio: map['bio'],
      songUrl: map['song_url'],
      locale: map['locale'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      shareUrl: map['share_url'],
      shareQrCodeUrl: map['share_qr_code_url'],
    );
  }

  factory Me.fromRow(List row) {
    return Me(
      id: row[0],
      name: row[1],
      imageUrl: row[2],
      phoneNumber: row[3],
      email: row[4],
      bio: row[5],
      songUrl: row[6],
      locale: row[7],
      createdAt: row[8],
      updatedAt: row[9],
      shareUrl: row[10],
      shareQrCodeUrl: row[11],
    );
  }

  @override
  String toString() {
    return 'Me($id, $name)';
  }
}
