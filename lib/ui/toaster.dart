import 'dart:async';
import 'package:flutter/material.dart';
import '../src/rust/api/rust.dart';

class Toaster {
  static GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  static void push(
    BuildContext context,
    String text, {
    int seconds = 5,
    bool error = false,
  }) {
    Completer<OverlayEntry> overlayCompleter = Completer<OverlayEntry>();
    var overlay = OverlayEntry(
      builder: (context) =>
          Toast(text, seconds, error, overlayCompleter.future),
    );
    overlayCompleter.complete(overlay);
    Overlay.of(context).insert(overlay);
  }

  static void showError(Object error) {
    var context = scaffoldKey.currentContext;
    if (context != null) {
      if (error is ChatError) {
        Toaster.push(
          context,
          "Error: ${error.message}\n${error.data}",
          error: true,
        );
      } else {
        Toaster.push(context, error.toString(), error: true);
      }
    }
  }
}

class Toast extends StatefulWidget {
  const Toast(this.text, this.seconds, this.error, this.myOverlay, {super.key});
  final String text;
  final int seconds;
  final bool error;
  final Future<OverlayEntry> myOverlay;

  @override
  State<Toast> createState() => _ToastState();
}

class _ToastState extends State<Toast> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: widget.seconds), () {
      if (opacity == 1.0) {
        setState(() => opacity = 0.0);
      }
    });
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
        onEnd: () async {
          if (opacity == 0.0) {
            (await widget.myOverlay).remove();
          }
        },
        opacity: opacity,
        duration: Duration(milliseconds: 100),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: widget.error
                  ? Colors.red.shade200
                  : Theme.of(context).cardColor,
              shape: Theme.of(context).buttonTheme.shape,
              elevation: 4,
              child: InkWell(
                onTap: () {
                  if (opacity == 1.0) {
                    setState(() => opacity = 0.0);
                  }
                },
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
