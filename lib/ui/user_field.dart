import 'package:flutter/material.dart';
//import 'package:signals/signals_flutter.dart';

class UserField extends StatelessWidget {
  const UserField(this.label, this.content, {super.key});
  final String label;
  final String content;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAdaptiveDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text('Edit $label'),
          contentPadding: const EdgeInsets.all(25),
          children: [
            TextField(
              controller: TextEditingController(text: content),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
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
