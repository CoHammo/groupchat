import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'image_utils.dart';

class AnyImage extends StatefulWidget {
  const AnyImage(
    this.img, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.circle = false,
    this.circleRadius,
    this.child,
  });

  final Img img;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final bool circle;
  final double? circleRadius;
  final Widget? child;

  @override
  State<AnyImage> createState() => _AnyImageState();
}

class _AnyImageState extends State<AnyImage> {
  late Uint8List? bytes = widget.img.bytes;
  late double opacity;

  @override
  void initState() {
    if (bytes != null) {
      opacity = 1;
    } else if (widget.img.needsLoaded) {
      opacity = 0;
      widget.img.load((b) {
        if (mounted) {
          setState(() {
            bytes = b;
            opacity = 1;
          });
        }
      });
    } else {
      opacity = 0;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.img.isEmpty) ...[
          Center(child: widget.child ?? Icon(Icons.image, size: 20)),
        ] else if (widget.img.needsLoaded) ...[
          Center(
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(),
            ),
          ),
        ],
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: opacity,
            duration: Duration(milliseconds: 200),
            child: bytes != null
                ? widget.circle
                      ? CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          foregroundImage: MemoryImage(bytes!),
                          radius: widget.circleRadius,
                          child: widget.child,
                        )
                      : Image.memory(
                          bytes!,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded) {
                                  return child;
                                } else {
                                  return AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: Duration(milliseconds: 200),
                                    child: child,
                                  );
                                }
                              },
                          fit: widget.fit,
                          width: widget.width,
                          height: widget.height,
                        )
                : null,
          ),
        ),
      ],
    );
  }
}
