import 'dart:typed_data';
import 'package:dio/dio.dart';

class Api {
  static void setToken(String token) {
    _dio.options.headers['X-Access-Token'] = token;
    _imageUpload.options.headers['X-Access-Token'] = token;
    _fileUpload.options.headers['X-Access-Token'] = token;
  }

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.groupme.com/v3',
      responseType: ResponseType.json,
    ),
  );

  static final Dio _imageUpload = Dio(
    BaseOptions(baseUrl: 'https://image.groupme.com', responseType: ResponseType.json),
  );

  static final Dio _fileUpload = Dio(
    BaseOptions(baseUrl: 'https://file.groupme.com/v1', responseType: ResponseType.json),
  );

  static Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/users/me');
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateMe({
    String? name,
    String? imageUrl,
    String? phoneNumber,
    String? email,
    String? bio,
    String? songUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/users/update',
        data: {
          if (name != null) 'name': name,
          if (imageUrl != null) 'avatar_url': imageUrl,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (email != null) 'email': email,
          if (bio != null) 'bio': bio,
          if (songUrl != null) 'song_url': songUrl,
        },
      );
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
      final Map<String, dynamic> user = response.data['response']['user'];
      user['image_url'] = user['avatar_url'];
      user.remove('avatar_url');
      return user;
    } catch (e) {
      _dio.options.baseUrl = 'https://api.groupme.com/v3';
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

  static Future<List<Map<String, dynamic>>> getGroups({
    int? page,
    int? pageSize,
  }) async {
    try {
      final response = await _dio.get(
        '/groups',
        queryParameters: {
          'page': page,
          'per_page': pageSize,
          'omit': 'memberships',
        },
      );
      final List g = response.data['response'];
      var groups = g.cast<Map<String, dynamic>>();
      for (var group in groups) {
        List delMode = group['message_deletion_mode'];
        group['message_deletion_mode'] = delMode.cast<String>();
        group['message_count'] = group['messages']['count'];
        group['last_message_id'] = group['messages']['last_message_id'];
        group['last_message_updated_at'] =
            group['messages']['last_message_updated_at'];
        group['join_question'] = group['join_question']?['text'];
      }
      return groups;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getMembers(String groupId) async {
    try {
      final response = await _dio.get('/groups/$groupId');
      List members = response.data['response']['members'];
      for (Map<String, dynamic> mem in members) {
        mem['member_id'] = mem['id'];
        mem['id'] = mem['user_id'];
        mem.remove('user_id');
        List roles = mem['roles'];
        mem['roles'] = roles.cast<String>();
      }
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
        // var user = await getUser(id);
        members.add({
          'user_id': id,
          'nickname': 'Nickname',
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

  static Future<List<Map<String, dynamic>>> getMessages(
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
      List messages = response.data['response']['messages'];
      return messages.cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String text, {
    List<Map<String, String>>? attachments,
  }) async {
    try {
      // List<Map<String, String>> pic = [];
      // List<Map<String, String>> files = [];
      // for (final url in pictureUrls) {
      //   pic.add({'type': 'image', 'url': url});
      // }
      // for (final id in fileIds) {
      //   files.add({'type': 'file', 'file_id': id});
      // }
      final response = await _dio.post(
        '/groups/$conversationId/messages',
        data: {
          'message': {
            'source_guid': DateTime.now().millisecondsSinceEpoch.toString(),
            'text': text,
            'attachments': attachments,
          },
        },
      );
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> editMessage(
    String conversationId,
    String messageId,
    String text, {
    List<Map<String, String>>? attachments,
  }) async {
    try {
      _dio.options.baseUrl = 'https://api.groupme.com/v4';
      final response = await _dio.post(
        '/groups/$conversationId/messages/$messageId',
        data: {
          'text': text,
          'attachments': attachments
        },
      );
      _dio.options.baseUrl = 'https://api.groupme.com/v3';
      return response.data['response']['message'];
    } catch (e) {
      _dio.options.baseUrl = 'https://api.groupme.com/v3';
      rethrow;
    }
  }

  static Future<Map> deleteMessage(String messageId, conversationId) async {
    try {
      return {};
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> likeMessage(
    String conversationId,
    String messageId,
    String unicode,
  ) async {
    try {
      final response = await _dio.post(
        '/messages/$conversationId/$messageId/like',
        data: {
          'like_icon': {'type': 'unicode', 'code': unicode},
        },
      );
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> uploadImage(Uint8List image) async {
    try {
      final response = await _imageUpload.post('/pictures', data: image);
      return response.data['payload']['url'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> uploadFile(String groupId, Uint8List file, String fileName) async {
    try {
      final response = await _fileUpload.post('/$groupId/files?name=$fileName', data: file);
      List<String> fileId = (response.data as String).split('?job=');
      return fileId[1].substring(0, fileId[1].length - 3);
    } catch (e) {
      rethrow;
    }
  }
}
