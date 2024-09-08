import 'package:flutter/material.dart';
//import 'package:signals/signals_flutter.dart';

class UserField extends StatelessWidget {
  const UserField(this.label, this.content, {this.maxLength, super.key});
  final String label;
  final String content;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var node = FocusNode();
        showAdaptiveDialog(
          context: context,
          builder: (context) {
            FocusScope.of(context).requestFocus(node);
            return AlertDialog.adaptive(
              title: Text('Edit $label'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              content: TextField(
                focusNode: node,
                maxLength: maxLength,
                maxLines: null,
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: content,
                    selection: TextSelection.collapsed(offset: content.length),
                  ),
                ),
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
                TextButton(child: const Text('Save'), onPressed: () {}),
              ],
            );
          },
        );
      },
      child: Card(
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
                    label,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(content, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
