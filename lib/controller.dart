import 'dart:io';
import 'dart:typed_data';
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
  late final userChanged = signal(0);

  late Realm _realm;

  late ChatApi _api;

  static const _secureStore = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

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

  void _deleteData() {
    _secureStore.delete(key: _key);
    hasToken.value = false;
    _realm.close();
    Realm.deleteRealm(_realm.config.path);
  }

  Future<void> startLoginServer(void Function() popFunction) async {
    _loginServer ??= await shelf_io.serve(
        logRequests().addHandler((request) {
          if (request.url.queryParameters.containsKey(Labels.accessToken)) {
            controller.initUser(request.url.queryParameters[Labels.accessToken]!);
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

  RealmResults<Group>? get groups => hasToken.value ? _realm.all<Group>() : null;

  MainUser? get user =>
      hasToken.value ? _realm.find<MainUser>(_userId)! : MainUser('', '');

  Future<bool> loadGroups() async {
    if (hasToken.value) {
      var groups = await _api.getGroups();
      if (groups != null) {
        List<Group> realmGroups = [];
        for (Map<String, dynamic> group in groups) {
          realmGroups.add(
            Group(
              group[Labels.id],
              group[Labels.createdAt],
              group[Labels.updatedAt],
              group[Labels.name],
              group[Labels.description],
              group[Labels.creatorUserId],
              imageUrl: group[Labels.imageUrl],
            ),
          );
        }
        _realm.write(() => _realm.addAll(realmGroups));
        dev.log(_realm.all<Group>().toString());
        return true;
      }
    }
    return false;
  }

  Future<bool> loadUserData() async {
    if (hasToken.value) {
      var data = await _api.getUserData();
      if (data != null) {
        _userId = data['id'];
        var user = MainUser(data[Labels.id], data[Labels.name],
            imageUrl: data[Labels.imageUrl],
            shareUrl: data[Labels.shareUrl],
            shareQrCodeUrl: data[Labels.shareQrCodeUrl],
            email: data[Labels.email],
            bio: data[Labels.bio],
            locale: data[Labels.locale],
            phoneNumber: data[Labels.phoneNumber],
            createdAt: data[Labels.createdAt],
            updatedAt: data[Labels.updatedAt]);
        _realm.write(() => _realm.add<MainUser>(user, update: true));
        dev.log(user.toString());
        userChanged.value++;
        return true;
      }
    }
    return false;
  }

  Future<bool> updateUserData(Map<String, dynamic> data) async {
    if (hasToken.value) {
      var uData = await _api.updateUserData(data);
      if (uData != null) {
        var usr = user;
        _realm.write(() {
          usr?.name = uData[Labels.name];
          usr?.email = uData[Labels.email];
          usr?.bio = uData[Labels.bio];
          usr?.phoneNumber = uData[Labels.phoneNumber];
          usr?.createdAt = uData[Labels.createdAt];
          usr?.updatedAt = uData[Labels.updatedAt];
          usr?.imageUrl = uData[Labels.imageUrl];
        });
        dev.log('User Updated');
        userChanged.value++;
        return true;
      }
    }
    return false;
  }

  Future<bool> changeAvatar(Uint8List imageBinary) async {
    if (hasToken.value) {
      var data = await _api.uploadImage(imageBinary);
      String url = data?[Labels.pictureUrl];
      if (await updateUserData({Labels.imageUrl: url})) {
        dev.log('Avatar Changed');
        return true;
      }
    }
    return false;
  }

  void initUser(String token) {
    _deleteData();
    _saveToken(token);
    _realm = Realm(
        Configuration.inMemory(_schemas)); //TODO: change to local database
    _api = ChatApi(token);
    loadUserData();
    loadGroups();
  }

  void logout() {
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

class Labels {
  static const accessToken = 'access_token';
  static const id = 'id';
  static const userId = 'user_id';
  static const creatorUserId = 'creator_user_id';
  static const name = 'name';
  static const email = 'email';
  static const phoneNumber = 'phone_number';
  static const zipCode = 'zip_code';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
  static const imageUrl = 'image_url';
  static const bio = 'bio';
  static const response = 'response';
  static const shareUrl = 'share_url';
  static const shareQrCodeUrl = 'share_qr_code_url';
  static const locale = 'locale';
  static const description = 'description';
  static const pictureUrl = 'picture_url';
}