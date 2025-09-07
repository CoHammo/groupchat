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
  late Realm _realm;

  late ChatApi _api;

  static const _secureStore = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  static const _key = 'group_chat_token';

  static final _schemas = [
    MainUser.schema,
    OtherUser.schema,
    GroupUser.schema,
    Chat.schema,
    Group.schema,
    Message.schema,
    Reaction.schema,
    Attachment.schema
  ];

  late String _userId;

  HttpServer? _loginServer;

  final Signal<bool> hasToken = signal(false);

  MainUser? get user => _realm.find<MainUser>(_userId);

  RealmResults<Group> get groups =>
      _realm.query<Group>('TRUEPREDICATE SORT(updatedAt DESC)');

  RealmResults<Chat> get chats =>
      _realm.query<Chat>('TRUEPREDICATE SORT(updatedAt DESC)');

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

  Future<bool> startLoginServer(void Function() popFunction) async {
    _loginServer ??= await shelf_io.serve(
      logRequests().addHandler(
        (request) async {
          if (request.url.queryParameters.containsKey(Labels.accessToken)) {
            await login(request.url.queryParameters[Labels.accessToken]!);
            popFunction();
            return Response.ok('Login successful, go back to app');
          } else {
            return Response.notFound('Login possibly went wrong?');
          }
        },
      ),
      'localhost',
      3000,
    );
    return true;
  }

  void ensureLoginServerClosed() {
    if (_loginServer != null) {
      _loginServer?.close();
      _loginServer = null;
      dev.log('Login Server Closed');
    }
  }

  MainUser _createMainUser(Map<String, dynamic> user) {
    return MainUser(
      user[Labels.id],
      name: user[Labels.name],
      imageUrl: user[Labels.imageUrl],
      shareUrl: user[Labels.shareUrl],
      shareQrCodeUrl: user[Labels.shareQrCodeUrl],
      email: user[Labels.email],
      bio: user[Labels.bio],
      locale: user[Labels.locale],
      phoneNumber: user[Labels.phoneNumber],
      createdAt: user[Labels.createdAt],
      updatedAt: user[Labels.updatedAt],
    );
  }

  Group _createGroup(Map<String, dynamic> group) {
    return Group(group[Labels.id],
        createdAt: group[Labels.createdAt],
        updatedAt: group[Labels.updatedAt],
        unreadCount: group[Labels.unreadCount] ?? 0,
        name: group[Labels.name],
        creatorUserId: group[Labels.creatorUserId],
        description: group[Labels.description],
        imageUrl: group[Labels.imageUrl],
        messageCount: group[Labels.messages][Labels.count]);
  }

  Chat _createChat(Map<String, dynamic> chat) {
    var otherUser = _creatOtherUser(chat[Labels.otherUser]);
    return Chat(
      otherUser.id,
      createdAt: chat[Labels.createdAt],
      updatedAt: chat[Labels.updatedAt],
      unreadCount: chat[Labels.unreadCount] ?? 0,
      messageCount: chat[Labels.messagesCount] ?? 0,
      otherUser: otherUser,
    );
  }

  OtherUser _creatOtherUser(Map<String, dynamic> user) {
    return OtherUser(
      user[Labels.id],
      name: user[Labels.name],
      imageUrl: user[Labels.avatarUrl],
    );
  }

  Message _createMessage(Map<String, dynamic> message) {
    List<Reaction> reactions = [];
    if ((message[Labels.favoritedBy] as List).isNotEmpty) {
      for (Map<String, dynamic> reaction in message[Labels.reactions]) {
        reactions.add(_createReaction(reaction));
      }
    }

    List<Attachment> attachments = [];
    for (Map<String, dynamic> attachment in message[Labels.attachments]) {
      attachments.add(_createAttachment(attachment));
    }

    return Message(
      message[Labels.id],
      senderId: message[Labels.senderId],
      text: message[Labels.text],
      createdAt: message[Labels.createdAt],
      system: message[Labels.system] ?? false,
      attachments: attachments,
      reactions: reactions,
    );
  }

  Attachment _createAttachment(Map<String, dynamic> attachment) {
    return Attachment(
        type: attachment[Labels.type],
        url: attachment[Labels.url],
        fileId: attachment[Labels.fileId]);
  }

  Reaction _createReaction(Map<String, dynamic> reaction) {
    return Reaction(
      code: reaction[Labels.code],
      type: reaction[Labels.type],
      users: (reaction[Labels.userIds] as List).map((item) => item as String),
    );
  }

  Future<bool> loadGroups({bool omitMemberships = false}) async {
    if (hasToken.value) {
      var groups = await _api.getAllGroups();
      if (groups != null) {
        List<Group> realmGroups = [];
        for (var group in groups) {
          realmGroups.add(_createGroup(group));
        }
        _realm.write(() => _realm.addAll<Group>(realmGroups, update: true));
        dev.log(_realm.all<Group>().toString());
        return true;
      }
    }
    return false;
  }

  Future<bool> loadGroupMessages({
    required Group group,
    int numMessages = 0,
    String beforeId = '',
  }) async {
    if (hasToken.value) {
      var messages = await _api.getGroupMessages(
        groupId: group.id,
        messages: numMessages,
        beforeId: beforeId,
      );
      if (messages != null) {
        List<Message> realmMessages = [];
        for (var message in messages) {
          realmMessages.add(_createMessage(message));
        }
        _realm.write(() {
          _realm.addAll(realmMessages, update: true);
          group.messages.clear();
          group.messages.addAll(realmMessages);
        });
        dev.log(
            '${group.name} has ${group.messages.length} local messages, ${group.messageCount} total messages');
        dev.log('${_realm.all<Message>().length} total local messages');
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
        for (var chat in chats) {
          realmChats.add(_createChat(chat));
        }
        _realm.write(() => _realm.addAll<Chat>(realmChats, update: true));
        dev.log(_realm.all<Chat>().toString());
        return true;
      }
    }
    return false;
  }

  Future<bool> loadChatMessages({
    required Chat chat,
    Message? before,
    Message? since,
  }) async {
    assert(
      !(before != null && since != null),
    );
    if (hasToken.value) {
      var messages = await _api.getChatMessages(
        userId: chat.otherUser?.id ?? '',
        beforeId: before?.id ?? '',
        sinceId: since?.id ?? '',
      );
      if (messages != null) {
        List<Message> realmMessages = [];
        for (var message in messages) {
          realmMessages.add(_createMessage(message));
        }
        _realm.write(() {
          _realm.addAll(realmMessages, update: true);
          chat.messages.clear();
          chat.messages.addAll(realmMessages);
        });
        dev.log(
            '${chat.name} has ${chat.messages.length} local messages, ${chat.messageCount} total messages');
        dev.log('${_realm.all<Message>().length} total local messages');
      }
    }
    return false;
  }

  Future<bool> loadUserData() async {
    if (hasToken.value) {
      var user = await _api.getUserData();
      if (user != null) {
        _userId = user[Labels.id];
        var newUser = _createMainUser(user);
        _realm.write(
          () => _realm.add<MainUser>(newUser, update: true),
        );
        dev.log(newUser.toString());
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

  Future login(String token) async {
    //_deleteData();
    _realm = Realm(
        Configuration.inMemory(_schemas)); //TODO: change to local database
    _api = ChatApi(token);
    _saveToken(token);
    await loadUserData();
    await loadGroups();
    await loadChats();
    _api.websocketConnect(userId: _userId);
  }

  void logout() {
    _deleteData();
    _api.websocketDisconnect();
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
      await _api.websocketConnect(userId: _userId);
    }
    _realm = Realm(Configuration.inMemory(_schemas));
  }
}

class Labels {
  static const accessToken = 'access_token';
  static const id = 'id';
  static const userId = 'user_id';
  static const userIds = 'user_ids';
  static const creatorUserId = 'creator_user_id';
  static const senderId = 'sender_id';
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
  static const otherUser = 'other_user';
  static const unreadCount = 'unread_count';
  static const avatarUrl = 'avatar_url';
  static const messages = 'messages';
  static const text = 'text';
  static const system = 'system';
  static const attachments = 'attachments';
  static const favoritedBy = 'favorited_by';
  static const reactions = 'reactions';
  static const code = 'code';
  static const type = 'type';
  static const url = 'url';
  static const fileId = 'file_id';
  static const messagesCount = 'messages_count';
  static const count = 'count';
}
