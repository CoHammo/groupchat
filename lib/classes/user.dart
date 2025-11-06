class User {
  static final List<String> columns = [];

  String id;
  String name;
  String? imageUrl;
  String? bio;
  String? songUrl;
  List<String>? photoUrls;
  List<String>? sharedGroups;

  User({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.bio,
    required this.songUrl,
    required this.photoUrls,
    this.sharedGroups,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      imageUrl: map['avatar_url'],
      bio: map['bio'],
      songUrl: map['song_url'],
      photoUrls: map['photo_urls'],
    );
  }

  factory User.fromRow(List row) {
    return User(
      id: row[0],
      name: row[1],
      imageUrl: row[2],
      bio: row[3],
      songUrl: row[4],
      photoUrls: row[5],
      sharedGroups: row[6],
    );
  }

  @override
  String toString() {
    return 'User($id, $name)';
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

  Member({
    required super.id,
    required super.name,
    required super.imageUrl,
    super.bio,
    super.songUrl,
    super.photoUrls,
    super.sharedGroups,
    required this.groupId,
    required this.memberId,
    required this.nickname,
    required this.roles,
    required this.muted,
    this.autokicked = false,
  });

  factory Member.fromRow(List row) {
    return Member(
      id: row[0],
      name: row[1],
      imageUrl: row[2],
      groupId: row[3],
      memberId: row[4],
      nickname: row[5],
      roles: row[6],
      muted: row[7],
    );
  }

  @override
  String toString() {
    return 'Member($id, $groupId, $nickname)';
  }
}
