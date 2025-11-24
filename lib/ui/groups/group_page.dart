// import 'package:flutter/material.dart';
// import 'package:signals/signals_flutter.dart';
// import '../chat_controller.dart';
// import '../classes/classes.dart';
// import 'message_widget.dart';

// class GroupPage extends StatelessWidget {
//   const GroupPage(this.controller, this.group, {super.key});

//   final ChatController controller;
//   final Group group;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: [
//           IconButton(onPressed: () => {}, icon: Icon(Icons.restart_alt)),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Watch.builder(
//               builder: (context) {
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: group.messages.value.length,
//                   itemBuilder: (context, index) {
//                     return MessageWidget(controller, group.messages[index]);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
