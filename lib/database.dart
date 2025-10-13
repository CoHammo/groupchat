import 'dart:async';
import 'package:dart_duckdb/dart_duckdb.dart';
import 'package:path_provider/path_provider.dart';
import 'classes/classes.dart';

class _Columns {
  List<String> get me => Me.columns;
  List<String> get users => User.columns;
  List<String> get groups => Group.columns;
  List<String> get members => Member.columns;
  List<String> get messages => Message.columns;

  List<String> operator [](String table) {
    switch (table) {
      case 'me':
        return Me.columns;
      case 'users':
        return User.columns;
      case 'groups':
        return Group.columns;
      case 'members':
        return Member.columns;
      case 'messages':
        return Message.columns;
      default:
        return [];
    }
  }
}

class Db {
  static late final Database _db;
  static late final Connection _conn;
  static late final _Columns _columns;

  static Future<void> init({bool memory = false}) async {
    String dir;
    if (memory) {
      dir = ':memory:';
    } else {
      dir = (await getApplicationDocumentsDirectory()).path;
    }
    _db = await duckdb.open(dir);
    _conn = await duckdb.connect(_db);

    await _conn.execute('''
      CREATE TABLE IF NOT EXISTS me (
        id VARCHAR PRIMARY KEY,
        name VARCHAR,
        image_url VARCHAR,
        phone_number VARCHAR,
        email VARCHAR,
        bio VARCHAR,
        song_url VARCHAR,
        created_at BIGINT,
        updated_at BIGINT,
        share_url VARCHAR,
        share_qr_code_url VARCHAR,
      );

      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR PRIMARY KEY,
        name VARCHAR,
        image_url VARCHAR,
        bio VARCHAR,
        song_url VARCHAR,
        shared_groups VARCHAR[]
      );

      CREATE TABLE IF NOT EXISTS groups (
        id VARCHAR PRIMARY KEY,
        name VARCHAR,
        type VARCHAR,
        description VARCHAR,
        image_url VARCHAR,
        creator_user_id VARCHAR,
        created_at BIGINT,
        updated_at BIGINT,
        message_count BIGINT,
        last_message_id VARCHAR,
        last_message_created_at BIGINT,
        last_message_updated_at BIGINT,
        theme_name VARCHAR,
        requires_approval BOOLEAN,
        show_join_question BOOLEAN,
        join_question VARCHAR,
        message_deletion_mode VARCHAR[],
        share_url VARCHAR,
        share_qr_code_url VARCHAR,
        members_saved BOOLEAN,
        messages_saved BOOLEAN,
      );

      CREATE TABLE IF NOT EXISTS members (
        id VARCHAR REFERENCES users(id),
        group_id VARCHAR REFERENCES groups(id),
        member_id VARCHAR,
        nickname VARCHAR,
        roles VARCHAR[],
        muted BOOLEAN,
        autokicked BOOLEAN,
        PRIMARY KEY (id, group_id, member_id),
      );

      CREATE TYPE attachment_type AS ENUM ('image', 'reply', 'file', 'location', 'unsupported');

      CREATE TABLE IF NOT EXISTS messages (
        id VARCHAR PRIMARY KEY,
        group_id VARCHAR REFERENCES groups(id),
        sender_id VARCHAR REFERENCES users(id),
        system BOOLEAN,
        text VARCHAR,
        reactions STRUCT(unicode VARCHAR, user_ids VARCHAR[])[],
        attachments STRUCT(type attachment_type, id VARCHAR, lat VARCHAR, lng VARCHAR)[],
        source_guid VARCHAR,
        pinned_at BIGINT,
        pinned_by VARCHAR,
        created_at BIGINT,
        updated_at BIGINT,
      );
    ''');

    await _conn.execute(
      '''INSERT INTO users VALUES ('system', 'system', NULL, NULL, NULL, NULL);''',
    );

    Me.columns.addAll((await _conn.getColumnOrder('me')));
    User.columns.addAll((await _conn.getColumnOrder('users')));
    Member.columns.addAll((await _conn.getColumnOrder('members')));
    Group.columns.addAll((await _conn.getColumnOrder('groups')));
    Message.columns.addAll((await _conn.getColumnOrder('messages')));
    _columns = _Columns();
  }

  static Future<void> close() async {
    await _db.dispose();
    await _conn.dispose();
  }

  static String _values(int rows, int columns) {
    String template = '(${List.filled(columns, '?').join(',')})';
    StringBuffer values = StringBuffer();
    for (int i = 0; i < rows; i++) {
      values.write('$template,');
    }
    return values.toString();
  }

  static Future<(bool, Object?)> _save(
    List<Map<String, dynamic>> things,
    String table,
  ) async {
    try {
      final values = _values(things.length, _columns[table].length);
      var prep = await _conn.prepare(
        'INSERT OR REPLACE INTO $table VALUES $values',
      );
      List params = [];
      for (final thing in things) {
        for (final col in _columns[table]) {
          params.add(thing[col]);
        }
      }
      prep.bindParams(params);
      await prep.execute();
      prep.dispose();
      return (true, null);
    } catch (e) {
      rethrow;
    }
  }

  static Future<(bool, Object?)> saveMe(Map<String, dynamic> me) async {
    return _save([me], 'me');
  }

  static Future<Me> getMe() async {
    try {
      var res = (await _conn.query('SELECT * FROM me;')).fetchOne()!;
      return Me.fromRow(res);
    } catch (e) {
      rethrow;
    }
  }

  static Future<(bool, Object?)> saveUser(Map<String, dynamic> users) async {
    return _save([users], 'users');
  }

  static Future<User> getUser(String id) async {
    try {
      var row = (await _conn.query(
        'SELECT * FROM users WHERE id = $id',
      )).fetchOne()!;
      return User.fromRow(row);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<User>> getAllUsers() async {
    try {
      var rows = (await _conn.query('SELECT * FROM users')).fetchAll();
      List<User> users = [];
      for (var row in rows) {
        users.add(User.fromRow(row));
      }
      return users;
    } catch (e) {
      rethrow;
    }
  }

  static Future<(bool, Object?)> saveGroups(List<Map<String, dynamic>> groups) {
    return _save(groups, 'groups');
  }

  static Future<List<Group>> getGroups() async {
    try {
      var rows = (await _conn.query(
        'SELECT * FROM groups ORDER BY updated_at DESC',
      )).fetchAll();
      List<Group> groups = [];
      for (var row in rows) {
        groups.add(Group.fromRow(row));
      }
      return groups;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Group> getGroup(String groupId) async {
    try {
      var row = (await _conn.query(
        'SELECT * FROM groups WHERE id = $groupId',
      )).fetchOne()!;
      return Group.fromRow(row);
    } catch (e) {
      rethrow;
    }
  }

  static Future<(bool, Object?)> saveMembers(
    List<Map<String, dynamic>> members,
    String groupId,
  ) async {
    try {
      var values = _values(members.length, _columns.users.length);
      final prepUsers = await _conn.prepare('''
        INSERT INTO users VALUES $values ON CONFLICT DO UPDATE
          SET name = EXCLUDED.name, image_url = EXCLUDED.image_url;
      ''');
      values = _values(members.length, _columns.members.length);
      final saveMembers = await _conn.prepare(
        'INSERT OR REPLACE INTO members VALUES $values',
      );

      List userParams = [];
      List memberParams = [];
      for (final member in members) {
        for (final column in _columns.users) {
          userParams.add(member[column]);
        }

        for (final column in _columns.members) {
          memberParams.add(member[column]);
        }
      }

      prepUsers.bindParams(userParams);
      saveMembers.bindParams(memberParams);
      await prepUsers.execute();
      await saveMembers.execute();
      prepUsers.dispose();
      saveMembers.dispose();

      return (true, null);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Member>> getMembers(String groupId) async {
    try {
      final rows = (await _conn.query('''
        SELECT id, name, group_id, member_id, nickname, roles, muted, image_url
        FROM members
        JOIN users ON members.id = users.id
        WHERE group_id = $groupId
        ORDER BY nickname ASC;
      ''')).fetchAll();
      List<Member> members = [];
      for (var row in rows) {
        members.add(Member.fromRow(row));
      }
      return members;
    } catch (e) {
      rethrow;
    }
  }

  static Future<(bool, Object?)> saveMessages(
    List<Map<String, dynamic>> messages,
  ) async {
    try {
      StringBuffer values = StringBuffer();
      for (int i = 0; i < messages.length; i++) {
        values.write('(?, ?, ?, ?, ?, json(?), json(?), ?, ?, ?, ?, ?),\n');
      }

      final prep = await _conn.prepare(
        'INSERT OR REPLACE INTO messages VALUES $values',
      );
      final params = [];
      for (final message in messages) {
        for (final col in _columns.messages) {
          params.add(message[col]);
        }
      }
      prep.bindParams(params);
      await prep.execute();
      prep.dispose();
      return (true, null);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Message>> getMessages(
    String groupId, {
    bool onlyPinned = false,
  }) async {
    try {
      var rows = (await _conn.query('''
        SELECT
          messages.id, messages.group_id, sender_id, system, text, reactions, attachments,
          source_guid, pinned_at, pinned_by, created_at, updated_at, name, nickname, image_url,
        FROM messages
        LEFT JOIN members ON messages.group_id = members.group_id AND messages.sender_id = members.id
        LEFT JOIN users ON messages.sender_id = users.id
        WHERE messages.group_id = $groupId ${onlyPinned ? 'AND messages.pinned_at NOT NULL' : ''}
        ORDER BY created_at DESC;
      ''')).fetchAll();
      List<Message> messages = [];
      for (var row in rows) {
        messages.add(Message.fromRow(row));
      }
      return messages;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Message> getMessage(String messageId) async {
    try {
      var row = (await _conn.query('''
        SELECT
          messages.id, messages.group_id, sender_id, system, text, reactions, attachments,
          source_guid, pinned_at, pinned_by, created_at, updated_at, name, nickname, image_url,
        FROM messages
        LEFT JOIN members ON messages.group_id = members.group_id AND messages.sender_id = members.id
        LEFT JOIN users ON messages.sender_id = users.id
        WHERE messages.id = $messageId
      ''')).fetchOne()!;
      return Message.fromRow(row);
    } catch (e) {
      rethrow;
    }
  }
}
