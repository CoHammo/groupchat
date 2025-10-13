import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'classes/message.dart';

class Api {
  static final Dio _api = Dio(
    BaseOptions(
      baseUrl: 'https://api.groupme.com/v3',
      responseType: ResponseType.json,
    ),
  );

  static void setToken(String token) {
    _api.options.headers['X-Access-Token'] = token;
  }

  static Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _api.get('/users/me');
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
      final response = await _api.post(
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
      final response = await _api.get('https://v2.groupme.com/users/$userId');
      final Map<String, dynamic> user = response.data['response']['user'];
      user['image_url'] = user['avatar_url'];
      user.remove('avatar_url');
      return user;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List> getChats({String? page, String? pageSize}) async {
    try {
      final response = await _api.get(
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
    int pageSize = 10,
  }) async {
    try {
      final response = await _api.get(
        '/groups',
        queryParameters: {
          'page': page,
          'per_page': pageSize,
          'omit': 'memberships',
        },
      );
      var groups = (response.data['response'] as List)
          .cast<Map<String, dynamic>>();
      _processGroups(groups);
      return groups;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getGroup(String groupId) async {
    try {
      final response = await _api.get('/groups/$groupId');
      Map<String, dynamic> group = response.data['response'];
      _processGroups([group]);
      group['members'] = (group['members'] as List)
          .cast<Map<String, dynamic>>();
      _processMembers(group['members'], groupId);
      return group;
    } catch (e) {
      rethrow;
    }
  }

  static void _processGroups(List<Map<String, dynamic>> groups) {
    for (final group in groups) {
      group['message_deletion_mode'] = (group['message_deletion_mode'] as List)
          .cast<String>();
      group['message_count'] = group['messages']['count'];
      group['last_message_id'] = group['messages']['last_message_id'];
      group['last_message_created_at'] =
          group['messages']['last_message_created_at'];
      group['last_message_updated_at'] =
          group['messages']['last_message_updated_at'];
      group['join_question'] = group['join_question']?['text'];
      group['members_saved'] = false;
      group['messages_saved'] = false;
    }
  }

  static Future<List<Map<String, dynamic>>> getMembers(String groupId) async {
    try {
      final response = await _api.get('/groups/$groupId');
      final members = (response.data['response']['members'] as List)
          .cast<Map<String, dynamic>>();
      _processMembers(members, groupId);
      return members;
    } catch (e) {
      rethrow;
    }
  }

  static void _processMembers(
    List<Map<String, dynamic>> members,
    String groupId,
  ) {
    for (final member in members) {
      member['member_id'] = member['id'];
      member['id'] = member['user_id'];
      member['group_id'] = groupId;
      member['roles'] = (member['roles'] as List).cast<String>();
    }
  }

  static Future<Map<String, dynamic>> addMembers(
    String groupId,
    List<String> userIds,
  ) async {
    try {
      List<Map<String, dynamic>> members = [];
      for (var id in userIds) {
        members.add({'user_id': id, 'nickname': 'Nickname'});
      }
      final response = await _api.post(
        '/groups/$groupId/members/add',
        data: {'members': members},
      );
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> removeMember(String groupId, String memberId) async {
    try {
      final response = await _api.post(
        '/groups/$groupId/members/$memberId/remove',
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
    String groupId, {
    String? beforeId,
    String? afterId,
    String? sinceId,
    int limit = 50,
    bool onlyPinned = false,
  }) async {
    try {
      Response response;
      if (onlyPinned) {
        response = await _api.get('/pinned/groups/$groupId/messages');
      } else {
        response = await _api.get(
          '/groups/$groupId/messages',
          queryParameters: {
            'before_id': beforeId,
            'after_id': afterId,
            'since_id': sinceId,
            'limit': limit,
          },
        );
      }
      final messages = (response.data['response']['messages'] as List)
          .cast<Map<String, dynamic>>();

      for (final message in messages) {
        _processAttachments(message);
        _processReactions(message);
      }

      return messages;
    } catch (e) {
      rethrow;
    }
  }

  static void _processAttachments(Map<String, dynamic> message) {
    List<Map<String, dynamic>> atts = [];
    for (Map<String, dynamic> att in message['attachments'] ?? []) {
      switch (att['type']) {
        case 'image':
          atts.add({
            'type': 'image',
            'id': att['url'],
            'lat': null,
            'lng': null,
          });
        case 'reply':
          atts.add({
            'type': 'reply',
            'id': att['reply_id'],
            'lat': null,
            'lng': null,
          });
        case 'file':
          atts.add({
            'type': 'file',
            'id': att['file_id'],
            'lat': null,
            'lng': null,
          });
        case 'location':
          atts.add({
            'type': 'location',
            'id': att['name'],
            'lat': att['lat'],
            'lng': att['lng'],
          });
        default:
          log(JsonEncoder.withIndent('  ').convert(att));
          atts.add({
            'type': 'unsupported',
            'id': 'none',
            'lat': null,
            'lng': null,
          });
      }
    }
    message['attachments'] = jsonEncode(atts);
  }

  static void _processReactions(Map<String, dynamic> message) {
    for (Map<String, dynamic> react in message['reactions'] ?? []) {
      if (react['type'] == 'unicode') {
        react['unicode'] = react['code'];
        react.remove('code');
      } else {
        react['unicode'] = '�';
        react.remove('pack_id');
        react.remove('pack_index');
      }
      react.remove('type');
    }
    message['reactions'] = jsonEncode(message['reactions']);
  }

  static Future<Map<String, dynamic>> sendMessage(Message message) async {
    try {
      // List<Map<String, String>> pic = [];
      // List<Map<String, String>> files = [];
      // for (final url in pictureUrls) {
      //   pic.add({'type': 'image', 'url': url});
      // }
      // for (final id in fileIds) {
      //   files.add({'type': 'file', 'file_id': id});
      // }
      final response = await _api.post(
        '/groups/${message.groupId}/messages',
        data: {
          'message': {
            'source_guid': message.sourceGuid,
            'text': message.text,
            'attachments': message.attachments,
          },
        },
      );
      Map<String, dynamic> mess = response.data['response']['message'];
      _processAttachments(mess);
      _processReactions(mess);
      return mess;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> editMessage(
    String groupId,
    String messageId,
    String text, {
    List<Map<String, String>>? attachments,
  }) async {
    try {
      final response = await _api.put(
        'https://api.groupme.com/v4/groups/$groupId/messages/$messageId',
        data: {'text': text, 'attachments': attachments},
      );
      return response.data['response']['message'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> deleteMessage(String groupId, String messageId) async {
    try {
      await _api.delete('/conversations/$groupId/messages/$messageId');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> likeMessage(
    String groupId,
    String messageId,
    String unicode,
  ) async {
    try {
      final response = await _api.post(
        '/messages/$groupId/$messageId/like',
        data: {
          'like_icon': {'type': 'unicode', 'code': unicode},
        },
      );
      return response.data['response'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> pinMessage(String groupId, String messageId) async {
    try {
      await _api.post('conversations/$groupId/messages/$messageId/pin');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> unpinMessage(
    String conversationId,
    String messageId,
  ) async {
    try {
      await _api.post(
        'conversations/$conversationId/messages/$messageId/unpin',
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> uploadImage(Uint8List image) async {
    try {
      final response = await _api.post(
        'https://image.groupme.com/pictures',
        data: image,
      );
      return response.data['payload']['url'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> uploadFile(
    String groupId,
    Uint8List file,
    String fileName,
  ) async {
    try {
      final response = await _api.post(
        'https://file.groupme.com/v1/$groupId/files?name=$fileName',
        data: file,
      );
      List<String> fileId = (response.data as String).split('?job=');
      return fileId[1].substring(0, fileId[1].length - 3);
    } catch (e) {
      rethrow;
    }
  }
}
