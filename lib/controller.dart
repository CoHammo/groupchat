import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:realm/realm.dart';
import 'package:signals/signals_flutter.dart';
import 'api.dart';
import 'classes/models.dart';
import 'dart:developer' as dev;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

final ChatController controller = ChatController();

class ChatController {
  late Realm _realm;

  late ChatApi _api;

  static const _secureStore = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  static const _key = 'group_chat_token';

  static final _schemas = [
    MainUser.schema,
    ChatUser.schema,
    Chat.schema,
    Group.schema,
    Message.schema,
  ];

  late String _userId;

  HttpServer? _loginServer;

  final Signal<bool> hasToken = signal(false);

  void _saveToken(String token) {
    _secureStore.write(key: _key, value: token);
    hasToken.value = true;
  }

  void _deleteToken() {
    _secureStore.delete(key: _key);
    hasToken.value = false;
  }

  void _deleteData() {
    _realm.close();
    Realm.deleteRealm(_realm.config.path);
  }

  Future<void> startLoginServer(void Function() popFunction) async {
    _loginServer ??= await shelf_io.serve(
        logRequests().addHandler((request) {
          if (request.url.queryParameters.containsKey('access_token')) {
            controller.initUser(request.url.queryParameters['access_token']!);
            popFunction();
            _loginServer!.close();
            _loginServer = null;
            return Response.ok('Login successful, go back to app');
          } else {
            return Response.notFound('Login Unsuccessful');
          }
        }),
        'localhost',
        3000);
  }

  RealmResults<Group> allGroups() {
    return _realm.all<Group>();
  }

  MainUser get user =>
      hasToken.value ? _realm.find<MainUser>(_userId)! : MainUser('', '');

  Future<void> loadGroups() async {
    if (hasToken.value) {
      var groups = await _api.getGroups();
      List<Group> realmGroups = [];
      for (Map<String, dynamic> group in groups) {
        realmGroups.add(
          Group(
            group['id'],
            group['created_at'],
            group['updated_at'],
            group['name'],
            group['description'],
            group['creator_user_id'],
            imageUrl: group['image_url'],
          ),
        );
      }
      _realm.write(() => _realm.addAll(realmGroups));
      dev.log(_realm.all<Group>().toString());
    }
  }

  Future<void> loadUserData() async {
    if (hasToken.value) {
      var data = await _api.getUserData();
      _userId = data['id'];
      var user = MainUser(data['id'], data['name'],
          imageUrl: data['image_url'],
          shareUrl: data['share_url'],
          shareQrCodeUrl: data['share_qr_code_url'],
          email: data['email'],
          bio: data['bio'],
          locale: data['locale'],
          phoneNumber: data['phone_number'],
          createdAt: data['created_at'],
          updatedAt: data['updated_at']);
      _realm.write(() => _realm.add<MainUser>(user, update: true));
      dev.log(user.toString());
    }
  }

  void initUser(String token) {
    _saveToken(token);
    _deleteData();
    _realm = Realm(
        Configuration.inMemory(_schemas)); //TODO: change to local database
    _api = ChatApi(token);
    loadUserData();
    loadGroups();
  }

  void logout() {
    _deleteToken();
    _deleteData();
    dev.log('Logged Out');
  }

  Future<void> initState() async {
    if (await _secureStore.containsKey(key: _key)) {
      hasToken.value = true;
      _api = ChatApi((await _secureStore.read(key: _key))!);
      _realm = Realm(
          Configuration.inMemory(_schemas)); //TODO: change to local database
      await loadGroups();
      await loadUserData();
    }
    _realm = Realm(Configuration.inMemory(_schemas));
  }

  ChatController();
}
