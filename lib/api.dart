import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:signals/signals.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:developer' as dev;

class ChatApi {
  ChatApi(this._token);

  final String _token;

  late final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.groupme.com/v3',
      headers: {'X-Access-Token': _token},
    ),
  );

  late final _dioImage = Dio(
    BaseOptions(
      baseUrl: 'https://image.groupme.com',
      headers: {'X-Access-Token': _token},
    ),
  );

  WebSocketChannel? _socket;

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

  Future<List<Map<String, dynamic>>?> getAllGroups(
      {bool getMembers = false}) async {
    try {
      List<Map<String, dynamic>> groups = [];
      bool fullPage = true;
      int pageNumber = 1;
      while (fullPage) {
        var rs = await _dio.get('/groups', queryParameters: {
          'page': pageNumber,
          (getMembers ? '' : 'omit'): (getMembers ? '' : 'memberships'),
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

  Future<Map<String, dynamic>?> getGroup(String id) async {
    try {
      var rs = await _dio.get('/groups/$id');
      if (rs.statusCode == 200) {
        return rs.data['response'];
      }
    } catch (e) {
      dev.log(e.toString());
    }
    return null;
  }

  /// Gets [messages] messages that were sent before the [beforeId] from the group with the [groupId].
  /// If [messages] is 0 or isn't given, it will get all messages from the group.
  /// If [beforeId] isn't given, it will get the most recent messages.
  /// The most recent message will be at index 0, and the oldest one at the last index.
  Future<List<Map<String, dynamic>>?> getGroupMessages(
      {required String groupId, int messages = 0, String beforeId = ''}) async {
    try {
      List<Map<String, dynamic>> messageList = [];
      bool fullPage = true;
      bool needsMore = true;
      int pageSize = 0;

      switch (messages) {
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

  /// Returns 20 messages around the given parameters
  Future<List<Map<String, dynamic>>?> getChatMessages({
    required String userId,
    String beforeId = '',
    String sinceId = '',
  }) async {
    try {
      var rs = await _dio.get(
        '/direct_messages',
        queryParameters: {
          'other_user_id': userId,
          'before_id': beforeId,
          'since_id': sinceId
        },
      );
      if (rs.statusCode == 200) {
        var msgs = (rs.data['response']['direct_messages'] as List)
            .map(
              (item) => item as Map<String, dynamic>,
            )
            .toList();
        return msgs;
        //return rs.data['response']['direct_messages'];
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

  Future<bool> websocketConnect({required String userId}) async {
    try {
      dev.log('connecting websocket...');
      _socket = WebSocketChannel.connect(
          Uri.parse('wss://push.groupme.com/faye'));
      await _socket?.ready;
      StreamSubscription? sub;
      sub = _socket?.stream.listen((event) => _socketFinishHandshake(event, sub, userId));
      _socket?.sink.add('[{"channel":"/meta/handshake","version":"1.0","supportedConnectionTypes":["long-polling"],"id":"1"}]');
      return true;
    } catch (e) {
      dev.log(e.toString());
    }
    return false;
  }

  void _socketFinishHandshake(dynamic event, StreamSubscription? sub, String userId) {
    Map<String, dynamic> data = (jsonDecode(event))[0];
    prettyPrint(data);
    String clientId = data['clientId'];
    sub?.onData((data) => _socketOnData(data));
    _socket?.sink.add('[{"channel":"/meta/subscribe","clientId":"$clientId","subscription":"/user/$userId","id":"2","ext":{"access_token":"$_token","timestamp":1322556419}}]');
  }

  void _socketOnData(dynamic event) {
    Map<String, dynamic> data = jsonDecode(event)[0];
    //prettyPrint(data);
    if (data.containsKey('data')) {
      String message = data['data']['alert'];
      print(message);
    }
  }

  void websocketDisconnect() {
    _socket?.sink.close();
    _socket = null;
    dev.log('websocket closed');
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
  api.websocketConnect(userId: '40514102');
}
