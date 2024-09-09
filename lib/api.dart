import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:developer' as dev;

class ChatApi {
  ChatApi(this.token);

  final String token;
  late final _dio = Dio(BaseOptions(
      baseUrl: 'https://api.groupme.com/v3',
      headers: {'X-Access-Token': token}));

  final _encoder = const JsonEncoder.withIndent('  ');

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      var rs = await _dio.get('/users/me');
      if (rs.statusCode == 200) {
        return rs.data['response'];
      } else {
        return null;
      }
    } catch (e) {
      dev.log(e.toString());
      return null;
    }
  }

  Future<Map<String,dynamic>?> updateUserData(Map<String, dynamic> data) async {
    try {
      var rs = await _dio.post('/users/update', data: data);
      if (rs.statusCode == 200) {
        return rs.data['response'];
      } else {
        return null;
      }
    } catch (e) {
      dev.log(e.toString());
      return null;
    }
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

  String prettyString(Response response) {
    return _encoder.convert(jsonDecode(response.toString()));
  }
}

void main() async {
  String token = 'YL5adURLQUmATab5V3z31cIl9MBKKER4DI80YhPs';
  final api = ChatApi(token);
  api.updateUserData({'bio': 'heyo'});
}
