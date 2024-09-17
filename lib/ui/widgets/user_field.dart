import 'package:flutter/material.dart';
import 'package:groupchat/controller.dart';
import 'package:signals/signals_flutter.dart';

class UserField extends StatefulWidget {
  const UserField({
    required this.label,
    required this.dataLabel,
    required this.content,
    this.maxLength,
    super.key,
  });
  final String label;
  final String dataLabel;
  final String content;
  final int? maxLength;

  @override
  State<UserField> createState() => _UserFieldState();
}

class _UserFieldState extends State<UserField> with SignalsMixin {

  late final Signal<String> content = super.createSignal(widget.content);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var node = FocusNode();
        var textController = TextEditingController.fromValue(
          TextEditingValue(
            text: content.value,
            selection: TextSelection.collapsed(offset: content.value.length),
          ),
        );
        showAdaptiveDialog(
          context: context,
          builder: (context) {
            FocusScope.of(context).requestFocus(node);
            return AlertDialog.adaptive(
              title: Text('Edit ${widget.label}'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              content: TextField(
                focusNode: node,
                maxLength: widget.maxLength,
                maxLines: null,
                controller: textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                ),
              ),
              actionsPadding: const EdgeInsets.only(right: 12, bottom: 5),
              actions: [
                TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context)),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    content.value = textController.text;
                    controller
                        .updateUserData({widget.dataLabel: content.value});
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Card(
        elevation: 0,
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(content.value, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
