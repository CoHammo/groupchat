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

  Future<List<dynamic>?> getGroups() async {
    try {
      var rs = await _dio.get('/groups?omit=memberships');
      if (rs.statusCode == 200) {
        return rs.data['response'];
      }
    } catch (e) {
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
  var image = File('${Directory.current.path}/crossroads-banner.jpg');
  print(token);
  final api = ChatApi(token);
  print(api.prettyString(await api.uploadImage(await image.readAsBytes())));
}
