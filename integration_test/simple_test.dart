import 'package:flutter_test/flutter_test.dart';
import 'package:groupchat/chat_controller.dart';
import 'package:groupchat/main.dart';
import 'package:groupchat/src/rust/frb_generated.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await RustLib.init());
  testWidgets('Can call rust function', (WidgetTester tester) async {
    await tester.pumpWidget(GroupChat(await ChatController.make()));
    expect(find.textContaining('Result: `Hello, Tom!`'), findsOneWidget);
  });
}
