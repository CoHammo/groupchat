import 'package:flutter/material.dart';

class ProfileTextField extends StatefulWidget {
  const ProfileTextField(
    this.text, {
    this.align = TextAlign.start,
    this.style,
    this.maxLines = 1,
    this.maxLength,
    this.pattern,
    this.onValidChange,
    this.onInvalidChange,
    this.decoration,
    super.key,
  });

  final String? text;
  final TextAlign align;
  final TextStyle? style;
  final int maxLines;
  final int? maxLength;
  final RegExp? pattern;
  final Function(String value)? onValidChange;
  final Function()? onInvalidChange;
  final InputDecoration? decoration;

  @override
  State<ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  late TextEditingController textController;
  Icon? error;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      textAlign: widget.align,
      style: widget.style,
      decoration: widget.decoration?.copyWith(
        error: error != null ? SizedBox() : null,
        suffixIcon: error,
      ),
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      onChanged: (value) {
        if (widget.pattern != null) {
          if (widget.pattern!.hasMatch(value)) {
            setState(() => error = null);
            widget.onValidChange?.call(value);
          } else {
            widget.onInvalidChange?.call();
            setState(
              () =>
                  error = Icon(Icons.error_outline, color: Colors.red.shade400),
            );
          }
        } else {
          widget.onValidChange?.call(value);
        }
      },
    );
  }
}
