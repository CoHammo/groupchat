import 'dart:async';
import 'package:flutter/material.dart';
import '../src/rust/api/rust.dart';

class Toast extends StatefulWidget {
  Toast(this.text, {this.seconds = 5, super.key}) : isError = false {
    BuildContext? context = scaffoldKey.currentContext;
    if (context != null) {
      overlay = OverlayEntry(builder: (context) => this);
      Overlay.of(context).insert(overlay);
    }
  }

  Toast.error(Object error, {this.seconds = 5, super.key}) : isError = true {
    BuildContext? context = scaffoldKey.currentContext;
    if (context != null) {
      if (error is ChatError) {
        text = "Error: ${error.message}\nData: ${error.data}";
      } else {
        text = error.toString();
      }
      overlay = OverlayEntry(builder: (context) => this);
      Overlay.of(context).insert(overlay);
    }
  }

  static GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  late final String text;
  late final int seconds;
  late final OverlayEntry overlay;
  final bool isError;

  @override
  State<Toast> createState() => _ToastState();
}

class _ToastState extends State<Toast> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: widget.seconds),
      () => opacity == 1.0 ? setState(() => opacity = 0.0) : null,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 60,
      child: AnimatedOpacity(
        onEnd: () => opacity == 0.0 ? widget.overlay.remove() : null,
        opacity: opacity,
        duration: Duration(milliseconds: 100),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: widget.isError
                  ? Colors.red.shade200
                  : Theme.of(context).cardColor,
              shape: Theme.of(context).buttonTheme.shape,
              elevation: 4,
              child: InkWell(
                onTap: () =>
                    opacity == 1.0 ? setState(() => opacity = 0.0) : null,
                child: Container(
                  padding: EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Text(widget.text, style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
