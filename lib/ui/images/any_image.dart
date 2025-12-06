import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'image_utils.dart';

class AnyImage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (img.bytes != null) {
      return circle
          ? CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundImage: MemoryImage(img.bytes!),
              radius: circleRadius,
              child: child,
            )
          : Image.memory(img.bytes!, fit: fit, width: width, height: height);
    } else if (img.file != null) {
      return circle
          ? CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundImage: FileImage(File(img.file!)),
              radius: circleRadius,
              child: child,
            )
          : Image.file(File(img.file!), fit: fit, width: width, height: height);
    } else if (img.url != null && img.url!.startsWith("https://")) {
      return circle
          ? CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundImage: CachedNetworkImageProvider(img.url!),
              radius: circleRadius,
              child: child,
            )
          : CachedNetworkImage(
              placeholder: child != null ? (context, url) => child! : null,
              fadeInDuration: Duration(milliseconds: 200),
              imageUrl: img.url!,
              fit: fit,
              width: width,
              height: height,
            );
    } else {
      return Expanded(child: Center(child: child ?? Text("No Image")));
    }
  }
}
