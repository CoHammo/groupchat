import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../src/rust/api/rust.dart';

class LoginPage extends StatefulWidget {
  const LoginPage(this.controller, {super.key});

  final ChatController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).canvasColor,
      child: SizedBox(
        width: 275,
        height: 40,
        child: FilledButton(
          onPressed: () async {
            widget.controller.login().then((value) {
              widget.controller.loadGroups(loadAll: true);
            });
            await launchUrl(
              Uri.parse(
                "https://oauth.groupme.com/oauth/authorize?client_id=AN4x8tZwp28XvFE67ddPWGy2FJVrXl5uhmPAr2ccHytpClKL",
              ),
              mode: LaunchMode.inAppWebView,
            );
          },
          child: Text("Login"),
        ),
      ),
    );
  }
}
