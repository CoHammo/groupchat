import 'package:dart_duckdb/dart_duckdb.dart';
import 'package:path_provider/path_provider.dart';

class _Columns {
  final List<String> me;
  final List<String> users;
  final List<String> groups;
  final List<String> members;

  _Columns(this.me, this.users, this.groups, this.members);

  List<String> operator [](String table) {
    switch (table) {
      case 'me':
        return me;
      case 'users':
        return users;
      case 'groups':
        return groups;
      case 'members':
        return members;
      default:
        return [];
    }
  }
}

class Db {
  static late final Database _db;
  static late final Connection _conn;
  static late final _Columns _columns;

  static String _values(int rows, int columns) {
    String template = '(${List.filled(columns, '?').join(',')})';
    StringBuffer values = StringBuffer();
    for (int i = 0; i < rows; i++) {
      values.write('$template,');
    }
    return values.toString();
  }

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
        shared_groups BIGINT[]
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
        last_message_updated_at BIGINT,
        theme_name VARCHAR,
        requires_approval BOOLEAN,
        show_join_question BOOLEAN,
        join_question VARCHAR,
        message_deletion_mode VARCHAR[],
        share_url VARCHAR,
        share_qr_code_url VARCHAR,
      );
      
      CREATE TABLE IF NOT EXISTS members (
        group_id VARCHAR REFERENCES groups(id),
        user_id VARCHAR REFERENCES users(id),
        member_id VARCHAR,
        roles VARCHAR[],
        nickname VARCHAR,
        PRIMARY KEY (group_id, user_id, member_id)
      );
      ''');

    _columns = _Columns(
      (await _conn.getColumnOrder('me')).toList(),
      (await _conn.getColumnOrder('users')).toList(),
      (await _conn.getColumnOrder('groups')).toList(),
      (await _conn.getColumnOrder('members')).toList(),
    );
  }

  static Future<void> close() async {
    await _db.dispose();
    await _conn.dispose();
  }

  static Future<void> testMergeGroups(List<Map<String, dynamic>> things) async {
    return;
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

  static Future<Map<String, dynamic>?> getMe() async {
    try {
      final res = await _conn.query('SELECT * FROM me;');
      final me = res.fetchOne();
      if (me != null) {
        var map = Map.fromIterables(res.columnNames, me);
        return map;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<(bool, Object?)> saveUser(Map<String, dynamic> users) async {
    return _save([users], 'users');
  }

  static Future<Map<String, dynamic>?> getUser(String id) async {
    try {
      final res = await _conn.query('SELECT * FROM users WHERE id = $id');
      final user = res.fetchOne();
      if (user != null) {
        var map = Map.fromIterables(res.columnNames, user);
        return map;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<List>?> getAllUsers() async {
    try {
      final res = await _conn.query('SELECT * FROM users');
      final results = res.fetchAll();
      results.add(res.columnNames);
      return results;
    } catch (e) {
      return null;
    }
  }

  static Future<(bool, Object?)> saveMembers(
    List<Map<String, dynamic>> members,
    String group,
  ) async {
    try {
      var values = _values(members.length, _columns.users.length);
      final prepUsers = await _conn.prepare('''
        INSERT INTO users VALUES $values ON CONFLICT DO UPDATE
          SET name = EXCLUDED.name, image_url = EXCLUDED.image_url;
      ''');
      values = _values(members.length, 5);
      final saveMembers = await _conn.prepare(
        'INSERT OR REPLACE INTO members VALUES $values',
      );

      List userParams = [];
      List memberParams = [];
      for (final member in members) {
        for (final column in _columns.users) {
          userParams.add(member[column]);
        }

        memberParams.add(group);
        memberParams.add(member['id']);
        memberParams.add(member['member_id']);
        memberParams.add(member['roles']);
        memberParams.add(member['nickname']);
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

  static Future<List<List>?> getMembers(String group) async {
    try {
      final res = await _conn.query('''
        SELECT id, member_id, name, nickname, image_url, roles
        FROM members
        JOIN users ON members.user_id = users.id
        WHERE group_id = $group;
      ''');
      final results = res.fetchAll();
      results.add(res.columnNames);
      return results;
    } catch (e) {
      rethrow;
    }
  }

  static Future<(bool, Object?)> saveGroups(
    List<Map<String, dynamic>> groups,
  ) async {
    return _save(groups, 'groups');
  }

  static Future<ResultSet> getGroups() async {
    return _conn.query('SELECT * FROM groups');
  }
}
