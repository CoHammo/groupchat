import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../chat_controller.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: FilledButton(
        onPressed: () async {
          await launchUrl(
            Uri.parse(
              "https://oauth.groupme.com/oauth/authorize?client_id=AN4x8tZwp28XvFE67ddPWGy2FJVrXl5uhmPAr2ccHytpClKL",
            ),
            mode: LaunchMode.inAppWebView,
          );
        },
        child: Text("Login"),
      ),
    );
  }
}
