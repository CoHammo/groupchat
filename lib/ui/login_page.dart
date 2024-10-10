import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const route = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SignalsMixin {
  late final Signal<Widget> _buttonChild =
      super.createSignal(const Text('Login to GroupMe'));

  void _changePage() {
    Navigator.pushReplacementNamed(context, HomePage.route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: FilledButton(
          style: Theme.of(context).filledButtonTheme.style,
          child: _buttonChild.value,
          onPressed: () async {
            _buttonChild.value = const CircularProgressIndicator();
            await controller.startLoginServer(_changePage);
            launchUrl(
              Uri.parse(
                'https://oauth.groupme.com/oauth/authorize?client_id=AN4x8tZwp28XvFE67ddPWGy2FJVrXl5uhmPAr2ccHytpClKL',
              ),
            );
          },
        ),
      ),
    );
  }
}
