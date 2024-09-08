import 'package:flutter/material.dart';
import 'ui/home_page.dart';
import 'controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await controller.initState();
  runApp(const GroupChat());
}