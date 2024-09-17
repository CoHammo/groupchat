import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../classes/group.dart';

class GroupTile extends StatefulWidget {
  const GroupTile(this.group, {super.key});
  final Group? group;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
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
                imageUrl: widget.group?.imageUrl ?? '',
                errorWidget: (context, url, error) => const Icon(Icons.group),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.group?.name ?? 'No Group',
                  style: const TextStyle(fontSize: 20, height: 1.2),
                ),
                const SizedBox(height: 8),
                if (widget.group?.description != '') ...[
                  Text(
                    widget.group?.description ?? '',
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
