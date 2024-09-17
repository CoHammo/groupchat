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

  late final groups = computed<RealmResults<Group>?>(
      () => hasToken.value ? _realm.all<Group>() : null);

  late final chats = computed<RealmResults<Chat>?>(
      () => hasToken.value ? _realm.all<Chat>() : null);

  MainUser? get user => hasToken.value ? _realm.find<MainUser>(_userId) : null;

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
            controller.login(request.url.queryParameters[Labels.accessToken]!);
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

  Future<bool> loadGroups() async {
    if (hasToken.value) {
      var groups = await _api.getAllGroups();
      if (groups != null) {
        List<Group> realmGroups = [];
        for (Map<String, dynamic> group in groups) {
          realmGroups.add(
            Group(
              group[Labels.id],
              group[Labels.createdAt],
              group[Labels.updatedAt],
              group[Labels.unreadCount] ?? 0,
              group[Labels.name],
              group[Labels.creatorUserId],
              description: group[Labels.description],
              imageUrl: group[Labels.imageUrl],
            ),
          );
        }
        _realm.write(() => _realm.addAll<Group>(realmGroups));
        dev.log(_realm.all<Group>().toString());
        return true;
      }
    }
    return false;
  }

  Future<bool> loadChats() async {
    if (hasToken.value) {
      var chats = await _api.getAllChats();
      if (chats != null) {
        List<Chat> realmChats = [];
        for (Map<String, dynamic> chat in chats) {
          var otherUser = ChatUser(
            chat[Labels.otherUser][Labels.id],
            chat[Labels.otherUser][Labels.name],
            imageUrl: chat[Labels.otherUser][Labels.avatarUrl],
          );
          realmChats.add(
            Chat(
              otherUser.id,
              chat[Labels.createdAt],
              chat[Labels.updatedAt],
              chat[Labels.unreadCount] ?? 0,
              chat[Labels.messageCount] ?? 0,
              otherUser: otherUser,
            ),
          );
        }
        _realm.write(() => _realm.addAll<Chat>(realmChats));
        dev.log(_realm.all<Chat>().toString());
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

  void login(String token) {
    _deleteData();
    _realm = Realm(
        Configuration.inMemory(_schemas)); //TODO: change to local database
    _api = ChatApi(token);
    _saveToken(token);
    loadUserData();
    loadGroups();
    loadChats();
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
      await loadUserData();
      await loadGroups();
      await loadChats();
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
  static const messageCount = 'message_count';
  static const otherUser = 'other_user';
  static const unreadCount = 'unread_count';
  static const avatarUrl = 'avatar_url';
}
