import 'package:flutter/material.dart';
import 'package:groupchat/controller.dart';
import 'package:groupchat/ui/user_field.dart';
import 'package:signals/signals_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  static const route = '/user';

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with SignalsMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('User Info'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        children: [
          CircleAvatar(
            radius: 100,
            child: CircleAvatar(
              radius: 100,
              foregroundImage: NetworkImage(controller.user.imageUrl!),
            ),
          ),
          const SizedBox(height: 20),
          UserField(
            label: 'Name',
            dataLabel: Labels.name,
            content: controller.user.name,
          ),
          UserField(
            label: 'Email',
            dataLabel: Labels.email,
            content: controller.user.email ?? '',
          ),
          UserField(
            label: 'Phone',
            dataLabel: Labels.phoneNumber,
            content: controller.user.phoneNumber ?? '',
          ),
          UserField(
            label: 'Bio',
            dataLabel: Labels.bio,
            content: controller.user.bio ?? '',
            maxLength: 191,
          ),
        ],
      ),
    );
  }
}
