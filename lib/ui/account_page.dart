import 'package:flutter/material.dart';
import 'package:groupchat/controller.dart';
import 'package:groupchat/ui/widgets/user_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals/signals_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  static const route = '/account';

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with SignalsMixin {
  final imagePicker = ImagePicker();
  late final userChanged = super.createComputed(() => controller.userChanged.value);

  @override
  Widget build(BuildContext context) {
    var changed = userChanged.value;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        children: [
          CircleAvatar(
            radius: 110,
            child: CircleAvatar(
              radius: 110,
              foregroundImage: NetworkImage(controller.user?.imageUrl ?? ''),
            ),
          ),
          const SizedBox(height: 15),
          FilledButton(
            style: Theme.of(context).filledButtonTheme.style,
            child: const Text('Choose New Image'),
            onPressed: () async {
              var image =
                  await imagePicker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                var bytes = await image.readAsBytes();
                if (context.mounted) {
                  var success = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return FutureBuilder(
                        future: controller.changeAvatar(bytes),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            Navigator.pop<bool>(context, snapshot.data!);
                          }
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                  if (context.mounted) {
                    var message =
                        success! ? 'Avatar Changed' : 'Avatar Not Changed';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Center(child: Text(message))),
                    );
                  }
                }
              }
            },
          ),
          const SizedBox(height: 20),
          UserField(
            label: 'Name',
            dataLabel: Labels.name,
            content: controller.user?.name ?? '',
          ),
          UserField(
            label: 'Email',
            dataLabel: Labels.email,
            content: controller.user?.email ?? '',
          ),
          UserField(
            label: 'Phone',
            dataLabel: Labels.phoneNumber,
            content: controller.user?.phoneNumber ?? '',
          ),
          UserField(
            label: 'Bio',
            dataLabel: Labels.bio,
            content: controller.user?.bio ?? '',
            maxLength: 191,
          ),
        ],
      ),
    );
  }
}
