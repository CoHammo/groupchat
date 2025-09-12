import 'package:dio/dio.dart';

class Api {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.groupme.com/v3',
      responseType: ResponseType.json,
    ),
  );

  static Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/users/me');
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      _dio.options.baseUrl = 'https://v2.groupme.com';
      final response = await _dio.get('/users/$userId');
      _dio.options.baseUrl = 'https://api.groupme.com/v3';
      return response.data['response']['user'];
    } catch (e) {
      _dio.options.baseUrl = 'https://api.groupme.com/v3';
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateMe({
    String? name,
    String? avatarUrl,
    String? email,
    String? zipCode,
  }) async {
    try {
      final response = await _dio.post(
        '/users/update',
        data: {
          if (name != null) 'name': name,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (email != null) 'email': email,
          if (zipCode != null) 'zip': zipCode,
        },
      );
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List> getChats({String? page, String? pageSize}) async {
    try {
      final response = await _dio.get(
        '/chats',
        queryParameters: {'page': page, 'per_page': pageSize},
      );
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List> getGroups({String? page, String? pageSize}) async {
    try {
      final response = await _dio.get(
        '/groups',
        queryParameters: {
          'page': page,
          'per_page': pageSize,
          'omit': 'memberships',
        },
      );
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getMembers(String groupId) async {
    try {
      final response = await _dio.get('/groups/$groupId');
      final List<dynamic> members = response.data['response']['members'];
      return members.cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> addMembers(
    String conversationId,
    List<String> userIds,
  ) async {
    try {
      List<Map<String, dynamic>> members = [];
      for (var id in userIds) {
        var user = await getUser(id);
        members.add({
          'user_id': id,
          'nickname': user['name'],
          // 'guid': DateTime.now().millisecondsSinceEpoch.toString(), --- IGNORE --- might not be needed
        });
      }
      final response = await _dio.post(
        '/groups/$conversationId/members/add',
        data: {'members': members},
      );
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> removeMember(
    String conversationId,
    String memberId,
  ) async {
    try {
      final response = await _dio.post(
        '/groups/$conversationId/members/$memberId/remove',
      );
      if (response.data['meta']['code'] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getMessages(
    String conversationId, {
    String? beforeId,
    String? afterId,
    String? sinceId,
    String? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/groups/$conversationId/messages',
        queryParameters: {
          'before_id': beforeId,
          'after_id': afterId,
          'since_id': sinceId,
          'limit': limit,
        },
      );
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String text, {
    String? pictureUrl,
    String? attachment,
  }) async {
    try {
      final response = await _dio.post(
        '/groups/$conversationId/messages',
        data: {
          'message': {
            'source_guid': DateTime.now().millisecondsSinceEpoch.toString(),
            'text': text,
            if (pictureUrl != null) 'picture_url': pictureUrl,
            if (attachment != null) 'attachments': [attachment],
          },
        },
      );
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> likeMessage(
    String conversationId,
    String messageId,
    String code,
  ) async {
    try {
      final response = await _dio.post(
        '/messages/$conversationId/$messageId/like',
        data: {
          'like_icon': {'type': 'unicode', 'code': code},
        },
      );
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static void setToken(String token) {
    _dio.options.headers['X-Access-Token'] = token;
  }
}
