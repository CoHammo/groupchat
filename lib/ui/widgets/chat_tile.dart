import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../classes/chat.dart';

class ChatTile extends StatefulWidget {
  const ChatTile(this.chat, {super.key});
  final Chat? chat;

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                imageUrl: widget.chat?.otherUser?.imageUrl ?? '',
                errorWidget: (context, url, error) => const Icon(Icons.chat),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat?.name ?? 'No Group',
                  style: const TextStyle(fontSize: 20, height: 1.2),
                ),
                const SizedBox(height: 8),
                if (widget.chat?.description != '') ...[
                  Text(
                    widget.chat?.description ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15)
                  ),
                ] else...[
                  const Text(
                    'No Messages Yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15)
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      onTap: () {},
    );
  }
}
