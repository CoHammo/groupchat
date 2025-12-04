// import 'package:signals/signals_flutter.dart';

// import 'message.dart';
// import 'user.dart';

// class Group {
//   static final List<String> columns = [];
//   final ListSignal<Message> messages = listSignal([]);
//   final ListSignal<Member> members = listSignal([]);

//   String id;
//   String name;
//   String type;
//   String? description;
//   String? imageUrl;
//   String creatorUserId;
//   int createdAt;
//   int updatedAt;
//   int messageCount;
//   String? lastMessageId;
//   int? lastMessageCreatedAt;
//   int? lastMessageUpdatedAt;
//   String? themeName;
//   bool requiresApproval = false;
//   bool showJoinQuestion = false;
//   String? joinQuestion;
//   List<String> messageDeletionMode = [];
//   String? shareUrl;
//   String? shareQrCodeUrl;
//   bool membersSaved = false;
//   bool messagesSaved = false;

//   Group({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.description,
//     required this.imageUrl,
//     required this.creatorUserId,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.messageCount,
//     required this.lastMessageId,
//     required this.lastMessageCreatedAt,
//     required this.lastMessageUpdatedAt,
//     required this.themeName,
//     required this.requiresApproval,
//     required this.showJoinQuestion,
//     required this.joinQuestion,
//     required this.messageDeletionMode,
//     required this.shareUrl,
//     required this.shareQrCodeUrl,
//     required this.membersSaved,
//     required this.messagesSaved,
//   });

//   factory Group.fromMap(Map<String, dynamic> map) {
//     return Group(
//       id: map['id'],
//       name: map['name'],
//       type: map['type'],
//       description: map['description'],
//       imageUrl: map['image_url'],
//       creatorUserId: map['creator_user_id'],
//       createdAt: map['created_at'],
//       updatedAt: map['updated_at'],
//       messageCount: map['messages']['count'],
//       lastMessageId: map['messages']['last_message_id'],
//       lastMessageCreatedAt: map['messages']['last_message_created_at'],
//       lastMessageUpdatedAt: map['messages']['last_message_updated_at'],
//       themeName: map['theme_name'],
//       requiresApproval: map['requires_approval'],
//       showJoinQuestion: map['show_join_question'],
//       joinQuestion: map['join_question']?['text'],
//       messageDeletionMode: map['message_deletion_mode'],
//       shareUrl: map['share_url'],
//       shareQrCodeUrl: map['share_qr_code_url'],
//       membersSaved: false,
//       messagesSaved: false,
//     );
//   }

//   factory Group.fromRow(List row) {
//     return Group(
//       id: row[0],
//       name: row[1],
//       type: row[2],
//       description: row[3],
//       imageUrl: row[4],
//       creatorUserId: row[5],
//       createdAt: row[6],
//       updatedAt: row[7],
//       messageCount: row[8],
//       lastMessageId: row[9],
//       lastMessageCreatedAt: row[10],
//       lastMessageUpdatedAt: row[11],
//       themeName: row[12],
//       requiresApproval: row[13],
//       showJoinQuestion: row[14],
//       joinQuestion: row[15],
//       messageDeletionMode: (row[16] as List).cast<String>(),
//       shareUrl: row[17],
//       shareQrCodeUrl: row[18],
//       membersSaved: row[19],
//       messagesSaved: row[20],
//     );
//   }

//   @override
//   String toString() {
//     return 'Group($id, $name)';
//   }
// }
