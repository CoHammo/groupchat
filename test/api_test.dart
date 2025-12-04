// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:groupchat/api.dart';

// void main() async {
//   var token = await File('token').readAsString();
//   Api.init(token);

//   group('Api', () {
//     test('getMe returns user data', () async {
//       final me = await Api.getMe();
//       print(JsonEncoder.withIndent('  ').convert(me));
//       expect(me, isA<Map>());
//       expect(me.containsKey('id'), true);
//     });

//     test('getUser returns user data for valid userId', () async {
//       final me = await Api.getMe();
//       final userId = me['id'];
//       final user = await Api.getUser(userId);
//       print(JsonEncoder.withIndent('  ').convert(user));
//       expect(user, isA<Map>());
//       expect(user['id'], userId);
//     });

//     test('getChats returns a list of chats', () async {
//       final chats = await Api.getChats();
//       print(JsonEncoder.withIndent('  ').convert(chats));
//       expect(chats, isA<List>());
//     });

//     test('getGroups returns a list of groups', () async {
//       final groups = await Api.getGroups();
//       print(JsonEncoder.withIndent('  ').convert(groups));
//       expect(groups, isA<List>());
//     });

//     test('getGroup', () async {
//       final groups = await Api.getGroups();
//       final group = await Api.getGroup(groups.first['id']);
//       print(JsonEncoder.withIndent('  ').convert(group));
//     });

//     test('getMembers returns a list of members for a valid groupId', () async {
//       final groups = await Api.getGroups();
//       if (groups.isNotEmpty) {
//         final groupId = groups.first['id'];
//         final members = await Api.getMembers(groupId);
//         print(JsonEncoder.withIndent('  ').convert(members));
//         expect(members, isA<List>());
//       } else {
//         fail('No groups available to test getMembers');
//       }
//     });
//   });
// }
