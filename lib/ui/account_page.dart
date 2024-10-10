import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/controller.dart';
import 'package:groupchat/ui/widgets/user_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:developer' as dev;

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  static const route = '/account';

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with SignalsMixin {
  var user = controller.user;
  final imagePicker = ImagePicker();
  late final userChanged = super.createSignal(0);
  late StreamSubscription? sub;

  @override
  void initState() {
    super.initState();
    sub = controller.user?.changes.listen((event) => userChanged.value++);
  }

  @override
  void dispose() async {
    super.dispose();
    await sub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
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
              foregroundImage: user?.imageUrl != null && user?.imageUrl != ''
                  ? CachedNetworkImageProvider(
                      user!.imageUrl!,
                      errorListener: (p0) => dev.log(p0.toString()),
                    )
                  : null,
              onForegroundImageError: (e, stackTrace) => dev.log(e.toString()),
            ),
          ),
          const SizedBox(height: 15),
          FilledButton(
            style: Theme.of(context).filledButtonTheme.style,
            child: const Text('Choose New Image'),
            onPressed: () async {
              try {
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
              } catch (e) {
                print(e);
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
