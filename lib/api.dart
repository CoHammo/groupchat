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

  Future<List<dynamic>?> getAllGroups() async {
    try {
      List groups = [];
      bool fullPage = true;
      int pageNumber = 1;
      while (fullPage) {
        var rs = await _dio.get('/groups', queryParameters: {'page': pageNumber,'omit': 'memberships', 'per_page': 50});
        if (rs.statusCode == 200) {
          var pageList = rs.data['response'] as List;
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

  Future<List<dynamic>?> getAllChats() async {
    try {
      List chats = [];
      bool fullPage = true;
      int pageNumber = 1;
      while (fullPage) {
        var rs = await _dio.get('/chats', queryParameters: {'page': pageNumber, 'per_page': 50});
        if (rs.statusCode == 200) {
          var pageList = rs.data['response'] as List;
          chats.addAll(pageList);
          fullPage = pageList.length == 50;
          pageNumber++;
        } else {
          fullPage = false;
        }
        return chats;
      }
    } catch(e) {
      dev.log(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> uploadImage(Uint8List imageBinary) async {
    try {
      var rs = await _dioImage.post('/pictures', data: imageBinary, options: Options(contentType: Headers.contentTypeHeader));
      dev.log('got uploadImage response');
      if (rs.statusCode == 200) {
        return rs.data['payload'];
      }
    } catch (e) {
      dev.log(e.toString());
    }
    return null;
  }

  String prettyString(Object? data) {
    return _encoder.convert(data);
  }
}

// For testing the api on the command line
void main() async {
  String token = await File('${Directory.current.path}/token').readAsString();
  print(token);
  final api = ChatApi(token);
  var chats = await api.getAllGroups();
  print(api.prettyString(chats));
}
