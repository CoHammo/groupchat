import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:developer' as dev;

class ChatApi {
  ChatApi(this.token);

  final String token;

  late final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.groupme.com/v3',
      headers: {'X-Access-Token': token},
    ),
  );

  late final _dioImage = Dio(
    BaseOptions(
      baseUrl: 'https://image.groupme.com',
      headers: {'X-Access-Token': token},
    ),
  );

  final _encoder = const JsonEncoder.withIndent('  ');

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      var rs = await _dio.get('/users/me');
      if (rs.statusCode == 200) {
        return rs.data['response'];
      }
    } catch (e) {
      dev.log(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateUserData(
      Map<String, dynamic> data) async {
    try {
      var rs = await _dio.post('/users/update', data: data);
      if (rs.statusCode == 200) {
        return rs.data['response'];
      }
    } catch (e) {
      dev.log(e.toString());
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getAllGroups() async {
    try {
      List<Map<String, dynamic>> groups = [];
      bool fullPage = true;
      int pageNumber = 1;
      while (fullPage) {
        var rs = await _dio.get('/groups', queryParameters: {
          'page': pageNumber,
          'omit': 'memberships',
          'per_page': 50,
        });
        if (rs.statusCode == 200) {
          var pageList =
              (rs.data['response'] as List).map<Map<String, dynamic>>(
            (item) => item as Map<String, dynamic>,
          );
          groups.addAll(pageList);
          fullPage = pageList.length == 50;
          pageNumber++;
        } else {
          fullPage = false;
        }
      }
      return groups;
    } catch (e) {
      dev.log(e.toString());
    }
    return null;
  }

  /// Gets [messages] messages that were sent before the [beforeId] from the group with the [groupId].
  /// If [messages] is 0 or isn't given, it will get all messages from the group.
  /// If [beforeId] isn't given, it will get the most recent messages.
  /// The most recent message will be at index 0, and the oldest one at the last index.
  Future<List<Map<String, dynamic>>?> getGroupMessages({
    required String groupId,
    int messages = 0,
    String beforeId = ''
  }) async {
    try {
      List<Map<String, dynamic>> messageList = [];
      bool fullPage = true;
      bool needsMore = true;
      int pageSize = 0;

      switch(messages) {
        case < 0:
          pageSize = 1;
          messages = 1;
          break;
        case > 100 || 0:
          pageSize = 100;
          break;
        default:
          pageSize = messages;
      }

      while (fullPage && needsMore) {
        var rs = await _dio.get(
          '/groups/$groupId/messages',
          queryParameters: {'limit': pageSize, 'before_id': beforeId},
        );
        if (rs.statusCode == 200) {
          var msgs = (rs.data['response']['messages'] as List).map(
            (item) => item as Map<String, dynamic>,
          );
          messageList.addAll(msgs);
          fullPage = msgs.length == pageSize;
          if (messages != 0) {
            needsMore = messageList.length < messages;
          }
          if (pageSize > messages - messageList.length && messages > 0) {
            pageSize = messages - messageList.length;
          }
          beforeId = msgs.last['id'];
        } else {
          fullPage = false;
        }
      }
      return messageList;
    } catch (e) {
      dev.log(e.toString());
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getAllChats() async {
    try {
      List<Map<String, dynamic>> chats = [];
      bool fullPage = true;
      int pageNumber = 1;
      while (fullPage) {
        var rs = await _dio.get(
          '/chats',
          queryParameters: {'page': pageNumber, 'per_page': 50},
        );
        if (rs.statusCode == 200) {
          var pageList = (rs.data['response'] as List).map(
            (item) => item as Map<String, dynamic>,
          );
          chats.addAll(pageList);
          fullPage = pageList.length == 50;
          pageNumber++;
        } else {
          fullPage = false;
        }
        return chats;
      }
    } catch (e) {
      dev.log(e.toString());
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getChatMessages(String userId) async {
    try {
      var rs = await _dio.get(
        '/direct_messages',
        queryParameters: {'other_user_id': userId},
      );
      if (rs.statusCode == 200) {
        return rs.data['response']['direct_messages'];
      }
    } catch (e) {
      dev.log(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> uploadImage(Uint8List imageBinary) async {
    try {
      var rs = await _dioImage.post('/pictures',
          data: imageBinary,
          options: Options(contentType: Headers.contentTypeHeader));
      dev.log('got uploadImage response');
      if (rs.statusCode == 200) {
        return rs.data['payload'];
      }
    } catch (e) {
      dev.log(e.toString());
    }
    return null;
  }

  void prettyPrint(Object? data) {
    print(_encoder.convert(data));
  }
}

// For testing the api on the command line
void main() async {
  String token = await File('${Directory.current.path}/token').readAsString();
  print(token);
  final api = ChatApi(token);
  var groups = await api.getAllGroups();
  var chats = await api.getAllChats();
  api.prettyPrint(chats?[0]);
}
