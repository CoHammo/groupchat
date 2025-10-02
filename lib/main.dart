import 'dart:io';
import 'package:flutter/material.dart';
import 'package:groupchat/api.dart';
import 'package:groupchat/database.dart';


void main() async {
  runApp(const GroupChat());

  var token = await File('token').readAsString();
  Api.setToken(token);
  await Db.init(memory: true);
}

class GroupChat extends StatelessWidget {
  const GroupChat({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
